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

# host_file = '/etc/hosts'
host_file = 'hosts.test'

def log_error(msg):
    print('%s%s%s' % (red, msg, end))


def log_info(msg):
    print('%s%s%s' % (green, msg, end))


def print_param(verb, args, comment):
    print('  %s%-5s %s%-12s %s%s' % (green, verb, yellow, args, end, comment))


def help():
    print('run: python3 app.py %s %s<verb>%s <args>%s' % ('', green, yellow, end))
    print_param('-h', '', 'help')
    print_param('-a', 'name file', 'add host group')
    print_param('-r', 'name file', 'replace host group')

def has_contain_host_block(block):
    global host_file
    with open(host_file) as file: 
        lines = file.readlines()
        for line in lines:
            if str(block) in line:
                return True
    return False

def append_block(block, file_path):
    contained = has_contain_host_block(block)
    if contained:
        log_info('block already exist')
        return
    
    with open(file_path) as file: 
        lines = file.readlines()
        for line in lines:
            print(line, end='')


def main(verb=None, *args):
    if verb == '-h':
        help()
        sys.exit(0)
    if verb == '-a':
        if len(args) != 2 or args[0] is None or args[1] is None:
            log_error('invalid param, at least need 2')
            return
        append_block(block=args[0], file_path=args[1])
    if verb == '-r':
        pass

# docker11 start
# docker11 end

fire.Fire(main)
