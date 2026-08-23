"""
Database abstraction layer.

Supports two backends:
  - DynamoDB: set TABLE_NAME env var
  - PostgreSQL:
      - Local/dev: set DATABASE_URL
      - ECS/AWS: set DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD

The backend is selected automatically based on which env vars are set.
PostgreSQL configuration takes precedence over DynamoDB.
If DATABASE_URL is set, it takes precedence over the split DB_* variables.
"""

import os

_backend = None

_POSTGRES_ENV_VARS = (
    "DB_HOST",
    "DB_PORT",
    "DB_NAME",
    "DB_USER",
    "DB_PASSWORD",
)


def _has_postgres_config() -> bool:
    if os.environ.get("DATABASE_URL"):
        return True

    return all(os.environ.get(name) for name in _POSTGRES_ENV_VARS)


def _get_backend():
    global _backend
    if _backend is not None:
        return _backend

    if _has_postgres_config():
        _backend = _init_postgres()
    elif os.environ.get("TABLE_NAME"):
        _backend = _init_dynamodb()
    else:
        raise RuntimeError(
            "Set TABLE_NAME (DynamoDB), DATABASE_URL (PostgreSQL), "
            "or DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASSWORD (PostgreSQL)"
        )

    return _backend


# -- DynamoDB backend --

def _init_dynamodb():
    import boto3

    table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])

    def put(short_id: str, url: str):
        table.put_item(Item={"id": short_id, "url": url, "clicks": 0})

    def get(short_id: str):
        resp = table.get_item(Key={"id": short_id})
        return resp.get("Item")

    def incr(short_id: str):
        table.update_item(
            Key={"id": short_id},
            UpdateExpression="SET clicks = if_not_exists(clicks, :zero) + :one",
            ExpressionAttributeValues={":one": 1, ":zero": 0},
        )

    return {"put": put, "get": get, "incr": incr, "type": "dynamodb"}


# -- PostgreSQL backend --

def _init_postgres():
    import psycopg2
    from psycopg2.extras import RealDictCursor

    database_url = os.environ.get("DATABASE_URL")

    if database_url:
        conn = psycopg2.connect(database_url)
    else:
        conn = psycopg2.connect(
            host=os.environ["DB_HOST"],
            port=os.environ["DB_PORT"],
            dbname=os.environ["DB_NAME"],
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASSWORD"],
        )

    conn.autocommit = True

    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS urls (
                id     TEXT PRIMARY KEY,
                url    TEXT NOT NULL,
                clicks INTEGER NOT NULL DEFAULT 0,
                created_at TIMESTAMP DEFAULT NOW()
            )
        """)

    def put(short_id: str, url: str):
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO urls (id, url) VALUES (%s, %s) "
                "ON CONFLICT (id) DO UPDATE SET url = %s",
                (short_id, url, url),
            )

    def get(short_id: str):
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "SELECT id, url, clicks FROM urls WHERE id = %s",
                (short_id,),
            )
            return cur.fetchone()

    def incr(short_id: str):
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE urls SET clicks = clicks + 1 WHERE id = %s",
                (short_id,),
            )

    return {"put": put, "get": get, "incr": incr, "type": "postgres"}


def put_mapping(short_id: str, url: str):
    _get_backend()["put"](short_id, url)


def get_mapping(short_id: str):
    return _get_backend()["get"](short_id)


def increment_clicks(short_id: str):
    _get_backend()["incr"](short_id)


def get_backend_type() -> str:
    return _get_backend()["type"]