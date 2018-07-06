#  展示按键 , 需要 evdev 模块
from evdev import InputDevice
from select import select
import time

def detectInputKey(count, eventNum):
    ''' 传入计数器, 事件号, 开始记录按键 '''
    dev = InputDevice('/dev/input/event'+str(eventNum))
    while True:
        select([dev], [], [])
        for event in dev.read():
            if event.value == 1 and event.code != 0:
                count+=1
                print(count, event.code)
                print(str(time.time()))

print("please input listen event: ", end='')
eventNum=input()
detectInputKey(0, eventNum)
