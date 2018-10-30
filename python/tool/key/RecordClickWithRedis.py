from evdev import InputDevice
from select import select
import redis
import time
import os
from configparser import ConfigParser

file = '/main.conf'

def detectInputKey(eventNum, conn):
    ''' 记录每个按键次数以及总按键数 '''
    try:
        dev = InputDevice('/dev/input/event'+str(eventNum))
    except:
        logError('event config error')
    is_event_correct = False
    try:
        log('Ready to listen ... ')
        while True:
            today = time.strftime('%Y-%m-%d',time.localtime(time.time()))
            # 如果 event错了, 下面直接阻塞掉
            select([dev], [], [])
            if is_event_correct == False:
                log('\033[0;32mSuccessful startup\033[0m')
                is_event_correct = True
            for event in dev.read():
                if event.value == 1 and event.code != 0:
                    conn.zincrby(today, event.code)
                    conn.incr('all-'+today)
                    conn.zadd('detail-'+today, str(time.time()), event.code)
    except:
        logError('Error!! Device has been removed Or Application has been interrupted')

def get_conf():
    global file
    # 加载配置文件
    path = os.path.split(os.path.realpath(__file__))[0]
    mainConf = path + file
    if not os.path.exists(mainConf) :
        logError('Please refer to Readme.md initialization configuration')
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
    try:
        conn.ping()
        return conn
    except:
        logError('Redis connection failed')
        exit(1)

def logError(origin='', end=None):
    log('\033[0;31m'+origin+'\033[0m', end=end)

def log(origin=None, end=None):
    print(time.strftime('%Y-%m-%d',time.localtime(time.time())), origin, end=end)

def main():
    global redis
    eventNum = get_conf().get('event', 'key')
    detectInputKey(eventNum, get_conn())

if __name__=="__main__":
    main()