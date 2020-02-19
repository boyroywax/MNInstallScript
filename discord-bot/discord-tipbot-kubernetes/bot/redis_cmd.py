import asyncio
import asyncio_redis
from asyncio_redis.encoders import BytesEncoder

REDIS_HOST = 'redis-redis-ha'
REDIS_PORT = 6379


class Redis:
    # Redis KV Store
    ###
    async def setValue(self, my_key, my_value) -> bool:
        try:
            # Create Redis connection
            connection = await asyncio_redis.Connection.create(
                host=REDIS_HOST,
                port=REDIS_PORT)
            # Increment a key
            await connection.set(my_key, my_value)
            # When finished, close the connection.
            connection.close()
            return True
        except Exception:
            return False

    async def incValue(self, my_key) -> bool:
        try:
            # Create Redis connection
            connection = await asyncio_redis.Connection.create(
                host=REDIS_HOST,
                port=REDIS_PORT)
            # Increment a key
            await connection.incr(my_key)
            # When finished, close the connection.
            connection.close()
            return True
        except Exception:
            return False

    async def getValue(self, my_key) -> str:
        try:
            # Create Redis connection
            connection = await asyncio_redis.Connection.create(
                host=REDIS_HOST,
                port=REDIS_PORT)
            # Get a key
            retrievedValue = await connection.get(my_key)
            # When finished, close the connection.
            connection.close()
        except Exception:
            retrievedValue is None
        return retrievedValue

    async def setHash(self, my_key, my_field, my_value) -> int:
        # Create Redis connection
        connection = await asyncio_redis.Connection.create(
            host=REDIS_HOST,
            port=REDIS_PORT)
        # Set a hash field
        hashResponse = await connection.hset(my_key, my_field, my_value)
        # When finished, close the connection.
        connection.close()
        return hashResponse

    async def setHashMaps(self, my_key, my_dict) -> bool:
        try:
            # Create Redis connection
            connection = await asyncio_redis.Connection.create(
                host=REDIS_HOST,
                port=REDIS_PORT)
            # Get a key
            await connection.hmset(my_key, my_dict)
            # When finished, close the connection.
            connection.close()
            return True
        except Exception:
            return False

    async def getHash(self, my_key, my_field) -> str:
        try:
            # Create Redis connection
            connection = await asyncio_redis.Connection.create(
                host=REDIS_HOST,
                port=REDIS_PORT)
            # Get a key
            retrievedValue = await connection.hget(my_key, my_field)
            # When finished, close the connection.
            connection.close()
        except Exception:
            retrievedValue is None
        return retrievedValue

    async def existsHash(self, my_key, my_field) -> bool:
        try:
            # Create Redis connection
            connection = await asyncio_redis.Connection.create(
                host=REDIS_HOST,
                port=REDIS_PORT)
            # Get a key
            valueExists = await connection.hexists(my_key, my_field)
            # When finished, close the connection.
            connection.close()
        except Exception:
            valueExists is False
        return valueExists

    async def hashScan(self) -> list:
        user_list = []
        try:
            connection = await asyncio_redis.Connection.create(
                host=REDIS_HOST,
                port=REDIS_PORT)
            cursor = await connection.scan(match='user:*')
            while True:
                item = await cursor.fetchone()
                if item is None:
                    break
                else:
                    user_list.append(str(item))
        except Exception:
            user_list.append("No Keys")
        return user_list
