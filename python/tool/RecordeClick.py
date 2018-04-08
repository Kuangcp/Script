# 实现 每天的计数
from evdev import InputDevice
from select import select

def detectInputKey(count):
    dev = InputDevice('/dev/input/event4')
    while True:
        select([dev], [], [])
        for event in dev.read():
            if event.value == 1 and event.code != 0:
                count+=1
                print(count)

count = 0
detectInputKey(count)

# def detectInputKey():
#     dev = InputDevice('/dev/input/event4')
#     while True:
#         select([dev], [], [])
#         for event in dev.read():
#             if (event.value == 1 or event.value == 0) and event.code != 0:
#                 print("Key: %s Status: %s" % (event.code, "pressed" if event.value else "release"))
