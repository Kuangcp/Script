# 实现 每天的计数 需要 evdev
from evdev import InputDevice
from select import select

def detectInputKey(count, eventNum):
    ''' 传入计数器, 事件号, 开始记录按键 '''
    dev = InputDevice('/dev/input/event'+str(eventNum))
    while True:
        select([dev], [], [])
        for event in dev.read():
            if event.value == 1 and event.code != 0:
                count+=1
                print(count, event.code)

print("please input listen event: ", end='')
eventNum=input()
detectInputKey(0, eventNum)

# TODO 结合redis的zset,每天的敲击都记录下来
# 原函数,按压动作的监听和对应动作
# def detectInputKey():
#     dev = InputDevice('/dev/input/event5')
#     while True:
#         select([dev], [], [])
#         for event in dev.read():
#             if (event.value == 1 or event.value == 0) and event.code != 0:
#                 print("Key: %s Status: %s" % (event.code, "pressed" if event.value else "release"))
                
# detectInputKey()

