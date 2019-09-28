import os
import sys
import termios
import tty
from select import select

#  展示按键 , 需要 evdev 模块
from evdev import InputDevice

pwd=os.path.split(os.path.realpath(__file__))[0]
key_map_config = pwd+'/key_map.conf'

def detect_input_key(count, event_num):
    """ 传入计数器, 事件号, 开始记录按键 off 退出"""
    dev = InputDevice('/dev/input/event' + str(event_num))
    key_map = {}
    temp = [' ', ' ', ' ']
    while True:
        select([dev], [], [])
        ch = read()

        temp.append(ch)
        temp = temp[1:]

        if ''.join(temp) == 'off':
            exit_and_save_map(temp, key_map)

        for event in dev.read():
            if event.value == 1 and event.code != 0:
                count += 1
                print(count, event.code)
                key_map[ch] = event.code

def exit_and_save_map(temp,key_map):
    print('\nlist input key map \n')
    with open(key_map_config, 'w+') as file: 
        for key, value in key_map.items():
            print(value, '=', key)
            file.write(str(value)+' = '+ str(key)+'\n')
    exit(0)


def read():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        return ch
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


if __name__ == "__main__":
    print("please input listen event for keyboard: ", end='')

    eventNum = input()
    detect_input_key(0, eventNum)
