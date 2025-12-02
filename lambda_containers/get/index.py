import json
import boto3
import pymysql
import os
import socket

rds = boto3.client("rds")

def lambda_handler(event, context):
    print("Lambda execution started")

    db_proxy_endpoint = os.environ["DB_PROXY_ENDPOINT"]

    print(f"DB_PROXY_ENDPOINT: {db_proxy_endpoint}")

    #Getting db
    try:
        db_ip = socket.gethostbyname(db_proxy_endpoint)
        print(f"DB proxy hostname resolved to IP: {db_ip}")
    except Exception as e:
        print(f"[ERROR] DNS resolution failed for DB_PROXY_ENDPOINT: {e}")
        raise

    #IAM auth
    try:
        print("Generating IAM authentication token...")
        region = os.environ["AWS_REGION"]

        # A DB felhasználó neve ugyanaz mint amit eddig a Secret Managerben tároltál
        # → a proxy továbbra is azt fogja használni passworddel
        db_user = "appuser"  # <- Tedd ide a korábbi creds['username'] értékét

        token = rds.generate_db_auth_token(
            DBHostname=db_proxy_endpoint,
            Port=3306,
            DBUsername=db_user,
            Region=region
        )
        print("IAM auth token generated.")
    except Exception as e:
        print(f"[ERROR] Failed to generate IAM auth token: {e}")
        raise

    # Step 3: Connect using IAM token (ÚJ)
    try:
        print("Attempting DB connection with IAM auth...")
        conn = pymysql.connect(
            host=db_proxy_endpoint,
            user=db_user,
            password=token,
            database="incident_logger_db",
            cursorclass=pymysql.cursors.DictCursor,
            ssl={"ssl": True}
        )
        print("DB connection successful via IAM authentication")
    except Exception as e:
        print(f"[ERROR] Failed to connect to DB using IAM auth: {e}")
        raise

    # Step 4: Query execution (változatlan)
    try:
        with conn.cursor() as cursor:
            print("Querying incidents...")
            cursor.execute("SELECT * FROM incidents ORDER BY created_at DESC;")
            rows = cursor.fetchall()
            print(f"Query returned {len(rows)} rows")
    except Exception as e:
        print(f"[ERROR] Query failed: {e}")
        raise
    finally:
        conn.close()
        print("DB connection closed")

    return {
        "statusCode": 200,
        "body": json.dumps(rows, default=str)
    }