import datetime
import fire
from RecordClickWithRedis import get_conf
from RecordClickWithRedis import get_conn

file = '/main.conf'

def count_num(date):
    global file
    conn = get_conn(file)
    total_num = conn.get('all-'+date)
    if total_num is None:
        print(date, '没有记录')
        return 0
    
    print("%41s"%('\033[0;33m'+date+'\033[0m'))
    print("%25s%s"%('total',':\033[0;32m'+total_num.decode()+'\033[0m'))
    all = conn.zrevrange(date, 0, -1, True)
    map = conn.hgetall('key_map')
    for key in all:
        name = map.get(key[0])
        if not name == None:
            name = name.decode()
        print("%-6s -- \033[0;32m%s\033[0m"%(key[1], name))

def list_map():
    global file
    conn = get_conn(file)
    keys = []
    all = conn.hgetall('key_map')
    for key in all.keys():
        keys.append(int(key.decode()))
    keys.sort()
    for key in keys:
        value = all.get(str(key).encode())
        print(key,'=', value.decode())

def show_day(days=None):
    if days is None:
        today = datetime.datetime.now().strftime('%Y-%m-%d')
        count_num(today)
    else:
        now_time = datetime.datetime.now()
        yes_time = now_time + datetime.timedelta(days)
        new_time = yes_time.strftime('%Y-%m-%d')
        count_num(new_time)

def show_help():
    start='\033[0;32m'
    end='\033[0m'
    print("%-26s %-20s"%(start+"-h"+end, "帮助"))
    # print("%-26s %-20s"%(start+"-b num"+end, "展示 num 天前的记录"))
    print("%-26s %-20s"%(start+"num"+end, "展示 num 天前的记录"))

def main(action=None):
    if action is None:
        show_day()
        return
    if action == '-h':
        show_help()
        return 
    if type(action) == int:
        show_day(action*-1)
    else:
        print('请输入正确的参数')

fire.Fire(main)