from evdev import InputDevice
from select import select
import redis
import time
import os
from configparser import ConfigParser

def detectInputKey(eventNum, conn):
    ''' 记录每个按键次数以及总按键数 '''
    today = time.strftime('%Y-%m-%d',time.localtime(time.time()))
    dev = InputDevice('/dev/input/event'+str(eventNum))
    while True:
        select([dev], [], [])
        for event in dev.read():
            if event.value == 1 and event.code != 0:
                conn.zincrby(today, event.code)
                conn.incr(today+'-all')


def main():
    # 加载配置文件
    path = os.path.split(os.path.realpath(__file__))[0]
    mainConf = path + '/main.conf'
    if not os.path.exists(mainConf) :
        print('请参考readme 配置初始化文件')
        return 0 
    cf = ConfigParser()
    cf.read(mainConf)
    host = cf.get('redis', 'host')
    port = cf.get('redis', 'port')
    db = cf.get('redis', 'db')
    password = cf.get('redis', 'password')
    eventNum = cf.get('event', 'key')
    if password == '':
        conn = redis.Redis(host=host, port=port, db=db)
    else:
        conn = redis.Redis(host=host, port=port, db=db, password=password)
    detectInputKey(eventNum, conn)

main()