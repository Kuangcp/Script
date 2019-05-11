from RecordClickWithRedis import get_conf,get_conn

# import key map from ini to a new redis 

path='/home/kcp/Application/script/python/tool/key/pokerII.ini'
cf = get_conf()

for i in range(1, 130):
    try:
        line = cf.get('poker', str(i))
        print(i, ' = ', line)
        conn = get_conn()
        # print(conn)
        conn.hset('key_map', i, line)
    except Exception:
        pass
    

