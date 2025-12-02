import json
import boto3
import pymysql
import os
import socket
import logging

# Configuring logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

rds = boto3.client("rds")

def lambda_handler(event, context):
    logger.info("Lambda execution started")

    db_proxy_endpoint = os.environ["DB_PROXY_ENDPOINT"]

    logger.info("DB_PROXY_ENDPOINT: %s", db_proxy_endpoint)

    #IAM auth
    try:
        logger.info("Generating IAM authentication token...")
        region = os.environ["AWS_REGION"]

        db_user = os.environ["DB_USER"]

        token = rds.generate_db_auth_token(
            DBHostname=db_proxy_endpoint,
            Port=3306,
            DBUsername=db_user,
            Region=region
        )
        logger.info("IAM auth token generated")
    except Exception as e:
        logger.error("Failed to generate IAM auth token: %s", e, exc_info=True)
        raise

    #Connect to db proxy using IAM token
    try:
        logger.info("Attempting DB connection with IAM auth...")
        conn = pymysql.connect(
            host=db_proxy_endpoint,
            user=db_user,
            password=token,
            database="incident_logger_db",
            cursorclass=pymysql.cursors.DictCursor,
            ssl={"ssl": True}
        )
        logger.info("DB connection successful via IAM authentication")
    except Exception as e:
        logger.error("Failed to connect to DB using IAM auth: %s", e, exc_info=True)
        raise

    # Executing query
    try:
        with conn.cursor() as cursor:
            logger.info("Querying incidents...")
            cursor.execute("SELECT * FROM incidents ORDER BY created_at DESC;")
            rows = cursor.fetchall()
            logger.info("Query returned %d rows", len(rows))
    except Exception as e:
        logger.error("Query failed: %s", e, exc_info=True)
        raise
    finally:
        conn.close()
        logger.info("DB connection closed")

    return {
        "statusCode": 200,
        "body": json.dumps(rows, default=str)
    }