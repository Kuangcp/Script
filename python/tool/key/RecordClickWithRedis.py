from evdev import InputDevice
from select import select
import redis
import time

conn = redis.Redis(host='127.0.0.1', port=6666, db=2)

def detectInputKey(eventNum):
    ''' 传入计数器, 事件号, 开始记录按键 '''
    today = time.strftime('%Y-%m-%d',time.localtime(time.time()))
    dev = InputDevice('/dev/input/event'+str(eventNum))
    while True:
        select([dev], [], [])
        for event in dev.read():
            if event.value == 1 and event.code != 0:
                conn.zincrby(today, event.code)
                conn.incr(today+'-all')

print("please input listen event: ", end='')
eventNum=input()
detectInputKey(eventNum)