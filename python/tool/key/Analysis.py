import time
from RecordClickWithRedis import get_conf
from RecordClickWithRedis import get_conn

def count_num(date):
    conn = get_conn()
    print('total : ', conn.get('all-'+date).decode())
    all = conn.zrevrange(date, 0, -1, True)
    map = conn.hgetall('key_map')
    for key in all:
        name = map.get(key[0])
        if not name == None:
            name = name.decode()
        # print(key[0],'#', name,'|', key[1])
        print(key[1], '==', name)

def list_map():
    conn = get_conn()
    keys = []
    all = conn.hgetall('key_map')
    for key in all.keys():
        keys.append(int(key.decode()))
    keys.sort()
    for key in keys:
        value = all.get(str(key).encode())
        print(key,'=', value.decode())

def show_today():
    today = time.strftime('%Y-%m-%d',time.localtime(time.time()))
    count_num(today)

if __name__=="__main__":
    show_today()
    # count_num('2018-05-26')
    # list_map()