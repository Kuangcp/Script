from RecordClickWithRedis import get_conn
from configparser import ConfigParser
import os

# import key map from ini to a new redis 

pwd=os.path.split(os.path.realpath(__file__))[0]

path = pwd+'/pokerII.ini'
cf = ConfigParser()
cf.read(path)
conn = get_conn()
print(conn)

try:
    for i in range(1, 130):
        line = cf.get('key_map', str(i))

        print(i, ' = ', line)
        conn.hset('key_map', i, line)
except Exception as e:
    print(e)
    pass
