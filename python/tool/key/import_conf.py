from RecordClickWithRedis import get_conn
from configparser import ConfigParser

# import key map from ini to a new redis 

path = '/home/kcp/Application/script/python/tool/key/pokerII.ini'
cf = ConfigParser()
cf.read(path)
conn = get_conn()
print(conn)

try:
    for i in range(1, 130):
        line = cf.get('poker', str(i))

        print(i, ' = ', line)
        conn.hset('key_map', i, line)
except Exception as e:
    print(e)
    pass
