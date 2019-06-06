#  展示按键 , 需要 evdev 模块
import  os 
import  sys
import  tty, termios

from evdev import InputDevice
from select import select
import time

def detectInputKey(count, eventNum):
    ''' 传入计数器, 事件号, 开始记录按键 '''
    dev = InputDevice('/dev/input/event'+str(eventNum))
    dict={}
    temp=[' ', ' ', ' ']
    while True:
        select([dev], [], [])
        ch = read()
        
        temp.append(ch)
        temp = temp[1:]
        if ''.join(temp) == 'off':
            for key,value in dict.items():
                print(value, '=', key)
            exit(0)

        for event in dev.read():
            if event.value == 1 and event.code != 0:
                count+=1
                print(count, event.code)
                dict[ch] = event.code

def read():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try :
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        return ch
    finally :
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


if __name__ == "__main__":
    print("please input listen event: ", end='')
    
    eventNum = input()
    detectInputKey(0, eventNum)
