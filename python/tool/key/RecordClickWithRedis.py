from evdev import InputDevice
from select import select
import redis
import time
import os
from configparser import ConfigParser

def detectInputKey(eventNum, conn):
    ''' 记录每个按键次数以及总按键数 '''
    dev = InputDevice('/dev/input/event'+str(eventNum))
    while True:
        today = time.strftime('%Y-%m-%d',time.localtime(time.time()))
        select([dev], [], [])
        for event in dev.read():
            if event.value == 1 and event.code != 0:
                conn.zincrby(today, event.code)
                conn.incr(today+'-all')

def get_conf():
    # 加载配置文件
    path = os.path.split(os.path.realpath(__file__))[0]
    mainConf = path + '/main.conf'
    if not os.path.exists(mainConf) :
        print('请参考readme 配置初始化文件')
        return 0 
    cf = ConfigParser()
    cf.read(mainConf)
    return cf

def get_conn():
    cf = get_conf()
    host = cf.get('redis', 'host')
    port = cf.get('redis', 'port')
    db = cf.get('redis', 'db')
    password = cf.get('redis', 'password')
    if password == '':
        conn = redis.Redis(host=host, port=port, db=db)
    else:
        conn = redis.Redis(host=host, port=port, db=db, password=password)
    return conn

def main():
    eventNum = get_conf().get('event', 'key')
    detectInputKey(eventNum, get_conn())

if __name__=="__main__":
    main()