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
    print('%s%s%s%s' % (red, 'ERROR: ', msg, end))


def log_info(msg):
    print('%s%s%s%s' % (green, 'INFO: ', msg, end))


def print_param(verb, args, comment):
    print('  %s%-5s %s%-12s %s%s' % (green, verb, yellow, args, end, comment))


def help():
    print('run: python3 app.py %s %s<verb>%s <args>%s' % ('', green, yellow, end))
    print_param('-h', '', 'help')
    print_param('-a', 'group file', 'add host group')
    print_param('-r', 'group file', 'replace host group')
    print_param('-on', 'group', 'uncomment host group')
    print_param('-off', 'group', 'comment host group')


def get_group_start(value) -> str:
    return '## op [ ' + str(value) + ' ]'


def get_group_end(value) -> str:
    return '## ed [ ' + str(value) + ' ]'


def has_contain_group(group) -> bool:
    global host_file
    with open(host_file) as file: 
        lines = file.readlines()
        for line in lines:
            if get_group_start(group) in line:
                return True
    return False


def append_group(group, file_path):
    contained = has_contain_group(group)
    if contained:
        log_error('group already exist')
        return
    
    host = open(host_file, 'a')
    host.write('\n' + get_group_start(group) + '\n\n')
    with open(file_path) as file: 
        lines = file.readlines()
        for line in lines:
            host.write(line)
            print(line, end='')
    host.write('\n\n' + get_group_end(group) + '\n')
    print()
    log_info('append group sucessful')


def main(verb=None, *args):
    if verb == '-h':
        help()
        sys.exit(0)
    
    if verb == '-a':
        if len(args) != 2 or args[0] is None or args[1] is None:
            log_error('invalid param, at least need 2')
            sys.exit(0)
        
        append_group(group=args[0], file_path=args[1])
    
    if verb == '-r':
        pass

    if verb == '-on':
        pass

    if verb == '-off':
        pass

        
# docker11 start
# docker11 end

fire.Fire(main)
