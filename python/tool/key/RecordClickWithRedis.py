from evdev import InputDevice
from select import select
import redis
import time
import os
from configparser import ConfigParser

file = '/main.conf'

def detectInputKey(eventNum, conn):
    ''' 记录每个按键次数以及总按键数 '''
    dev = InputDevice('/dev/input/event'+str(eventNum))
    is_event_correct = False
    try:
        log('Ready to listen ... ')
        while True:
            today = time.strftime('%Y-%m-%d',time.localtime(time.time()))
            # 如果 event错了, 下面直接阻塞掉
            select([dev], [], [])
            if is_event_correct == False:
                print('\033[0;32mSuccessful startup\033[0m')
                is_event_correct = True
            for event in dev.read():
                if event.value == 1 and event.code != 0:
                    conn.zincrby(today, event.code)
                    conn.incr('all-'+today)
                    conn.zadd('detail-'+today, str(time.time()), event.code)
    except:
        log('\033[0;31mError!! Device has been removed Or Application has been interrupted\033[0m')

def get_conf(file):
    # 加载配置文件
    path = os.path.split(os.path.realpath(__file__))[0]
    mainConf = path + file
    if not os.path.exists(mainConf) :
        print('Please refer to Readme.md initialization configuration')
        return 0 
    cf = ConfigParser()
    cf.read(mainConf)
    return cf

def get_conn(file):
    cf = get_conf(file)
    host = cf.get('redis', 'host')
    port = cf.get('redis', 'port')
    db = cf.get('redis', 'db')
    password = cf.get('redis', 'password')
    if password == '':
        conn = redis.Redis(host=host, port=port, db=db)
    else:
        conn = redis.Redis(host=host, port=port, db=db, password=password)
    return conn

def log(origin=None, end=None):
    print(time.strftime('%Y-%m-%d',time.localtime(time.time())), origin, end=end)

def main():
    global redis
    eventNum = get_conf(file).get('event', 'key')
    detectInputKey(eventNum, get_conn(file))

if __name__=="__main__":
    main()