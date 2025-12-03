import json
import boto3
import pymysql
import os
import logging

# Configuring logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

rds = boto3.client("rds")

def lambda_handler(event, context):
    logger.info("Lambda execution started")

    # Validate required environment variables
    try:
        db_proxy_endpoint = os.environ["DB_PROXY_ENDPOINT"]
        region = os.environ["AWS_REGION"]
        db_user = os.environ["DB_USER"]
        db_name = os.environ.get("DB_NAME", "incident_logger_db")
    except KeyError as e:
        logger.error("Missing required environment variable: %s", e)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"Configuration error: Missing {e}"})
        }

    logger.info("DB_PROXY_ENDPOINT: %s", db_proxy_endpoint)

    # Parse and validate request body
    try:
        body = json.loads(event.get("body", "{}"))
        logger.info("Parsed request body: %s", body)
    except Exception as e:
        logger.error("Failed to parse body: %s", e)
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid request body"})
        }

    required_fields = ["title", "description", "severity"]
    if not all(field in body for field in required_fields):
        return {
            "statusCode": 400,
            "body": json.dumps({"error": f"Missing required fields: {required_fields}"})
        }

    # Generate IAM authentication token
    try:
        logger.info("Generating IAM authentication token...")
        token = rds.generate_db_auth_token(
            DBHostname=db_proxy_endpoint,
            Port=3306,
            DBUsername=db_user,
            Region=region
        )
        logger.info("IAM auth token generated")
    except Exception as e:
        logger.error("Failed to generate IAM auth token: %s", e, exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Failed to generate database authentication token"})
        }

    # Connect to database via RDS Proxy using IAM authentication
    try:
        logger.info("Attempting DB connection with IAM auth...")
        conn = pymysql.connect(
            host=db_proxy_endpoint,
            user=db_user,
            password=token,
            database=db_name,
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=5,
            ssl={'ssl_mode': 'REQUIRED'}
        )
        logger.info("DB connection successful via IAM authentication")

    except Exception as e:
        logger.error("Failed to connect to DB using IAM auth: %s", e, exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Database connection failed"})
        }

    # Execute insert query
    try:
        with conn.cursor() as cursor:
            logger.info("Inserting new incident...")
            insert_sql = """
                INSERT INTO incidents (title, description, severity, status, created_at)
                VALUES (%s, %s, %s, %s, NOW())
            """
            cursor.execute(insert_sql, (
                body["title"],
                body["description"],
                body["severity"],
                "OPEN"
            ))
            conn.commit()
            new_id = cursor.lastrowid
            logger.info("Inserted new incident with ID: %d", new_id)

            cursor.execute("SELECT * FROM incidents WHERE id = %s", (new_id,))
            result = cursor.fetchone()
            logger.info("Fetched new incident row: %s", result)
    except Exception as e:
        logger.error("Insert query failed: %s", e, exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Database insert failed"})
        }
    finally:
        conn.close()
        logger.info("DB connection closed")

    logger.info("Lambda execution completed successfully")
    return {
        "statusCode": 201,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(result, default=str)
    }
