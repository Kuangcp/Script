from RecordClickWithRedis import get_conf,get_conn

# import key map from ini to a new redis 

cf = get_conf('/pokerII.ini')

for i in range(1, 130):
    try:
        line = cf.get('poker', str(i))
        print(i, ' = ', line)
        conn = get_conn('/main.conf')
        # print(conn)
        conn.hset('key_map', i, line)
    except Exception:
        pass
    

