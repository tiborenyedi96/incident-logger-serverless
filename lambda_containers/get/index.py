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
            connect_timeout=5
        )
        logger.info("DB connection successful via IAM authentication")
    except Exception as e:
        logger.error("Failed to connect to DB using IAM auth: %s", e, exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Database connection failed"})
        }

    # Execute query
    try:
        with conn.cursor() as cursor:
            logger.info("Querying incidents...")
            cursor.execute("SELECT * FROM incidents ORDER BY created_at DESC;")
            rows = cursor.fetchall()
            logger.info("Query returned %d rows", len(rows))
    except Exception as e:
        logger.error("Query failed: %s", e, exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Database query failed"})
        }
    finally:
        conn.close()
        logger.info("DB connection closed")

    logger.info("Lambda execution completed successfully")
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({"incidents": rows}, default=str)
    }