import fire
import sys
import json

red = '\033[0;31m'
green = '\033[0;32m'
yellow = '\033[0;33m'
blue = '\033[0;34m'
purple = '\033[0;35m'
cyan = '\033[0;36m'
white = '\033[0;37m'
end = '\033[0m'


def log_error(msg):
    print('%s%s%s' % (red, msg, end))


def logInfo(msg):
    print('%s%s%s' % (green, msg, end))


def printParam(verb, args, comment):
    print('  %s%-5s %s%-12s %s%s' % (green, verb, yellow, args, end, comment))


def help_info():
    print('run: python3 app.py %s %s<verb>%s <args>%s' % ('', green, yellow, end))
    printParam('-h', '', 'help')
    printParam('-a', 'name file', 'add host group')
    printParam('-r', 'name file', 'replace host group')


def main(verb=None, *args):
    if verb == '-h':
        help_info()
        sys.exit(0)
    if verb == '-a':
        if len(args) != 2 or args[0] is None or args[1] is None:
            log_error('invalid param, at least need 2')
            return
        name = args[0]
        file_path = args[1]
        print(name, file_path)

    if verb == '-r':
        pass

# docker11 start
# docker11 end


fire.Fire(main)
