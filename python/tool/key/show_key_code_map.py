#  展示按键 , 需要 evdev 模块
import sys
import termios
import tty
from select import select

from evdev import InputDevice


def detect_input_key(count, event_num):
    """ 传入计数器, 事件号, 开始记录按键 """
    dev = InputDevice('/dev/input/event' + str(event_num))
    key_map = {}
    temp = [' ', ' ', ' ']
    while True:
        select([dev], [], [])
        ch = read()

        temp.append(ch)
        temp = temp[1:]
        if ''.join(temp) == 'off':
            for key, value in key_map.items():
                print(value, '=', key)
            exit(0)

        for event in dev.read():
            if event.value == 1 and event.code != 0:
                count += 1
                print(count, event.code)
                key_map[ch] = event.code


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
    print("please input listen event: ", end='')

    eventNum = input()
    detect_input_key(0, eventNum)
