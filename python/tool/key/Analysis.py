import datetime
import fire
import time
from RecordClickWithRedis import get_conf
from RecordClickWithRedis import get_conn

def show_timeline(days=None):
    date = caculate_day(days)
    global file
    conn = get_conn()
    result = conn.zrange('detail-'+date, 0, -1, withscores=True)
    if result is None or result == []:
        print('没有记录')
        return 
    else:
        all = get_key_map()
        for key,value in result:
            timestamp = key.decode()
            timestamp = time.localtime(float(timestamp))
            day = time.strftime('%Y-%m-%d_%H:%M:%S', timestamp)
            name = all.get(str(int(value)).encode())
            if name is not None:
                name = name.decode()
            else:
                name = 'Code Not Found!!'
            # TODO 结果是按按键来排序的, 如果按时间排序呢
            print(day, name)

def count_num(days=None):
    global file
    conn = get_conn()
    date = caculate_day(days)
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

def get_key_map():
    global file
    conn = get_conn()
    all = conn.hgetall('key_map')
    return all

def list_map():
    keys = []
    all = get_key_map()
    for key in all.keys():
        keys.append(int(key.decode()))
    keys.sort()
    for key in keys:
        value = all.get(str(key).encode())
        print(key,'=', value.decode())

def caculate_day(days=None):
    ''' 计算当天日期, 和前推日期''' 
    if days is None:
        result = datetime.datetime.now().strftime('%Y-%m-%d')
    else:
        now_time = datetime.datetime.now()
        yes_time = now_time + datetime.timedelta(days*-1)
        result = yes_time.strftime('%Y-%m-%d')
    return result

def show_help():
    start='\033[0;32m'
    end='\033[0m'
    print("%-26s %-20s"%(start+"-h"+end, "帮助"))
    print("%-26s %-20s"%(start+"-d <num>"+end, "缺省为今天, 展示 num 天前的详细时间线"))
    print("%-26s %-20s"%(start+"<num>"+end, "缺省为今天, 展示 num 天前的记录"))

def main(action=None, day=0):
    if action is None:
        count_num()
        return
    if action == '-h':
        show_help()
        return 
    if action == '-d':
        # print('详细', caculate_day(day))
        show_timeline(day)
        return 
    if type(action) == int:
        count_num(action)
    else:
        print('请输入正确的参数')

try:
    fire.Fire(main)
except(BrokenPipeError, IOError):
    # 是因为 print还没有输出完, 被less接管了, 输出流中断了??
    pass
