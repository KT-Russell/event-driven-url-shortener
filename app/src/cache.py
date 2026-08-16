import os
import redis


client = redis.Redis.from_url(
    os.environ["REDIS_URL"],
    decode_responses=True,
)


def get_url(short_id: str):
    try:
        return client.get(f"url:{short_id}")
    except redis.RedisError:
        return None


def set_url(short_id: str, url: str):
    try:
        client.set(f"url:{short_id}", url, ex=3600)
    except redis.RedisError:
        pass


        ##get_url() → check Redis for a URL
        ##set_url() → put a URL into Redis for 1 hour
        ##Redis down → don't crash API
        ##Redis is the cache. PostgreSQL remains the source of truth.