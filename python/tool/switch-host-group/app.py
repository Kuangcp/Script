#!/ust/bin/python3

import fire
import sys
from functools import reduce
import os.path

red = '\033[0;31m'
green = '\033[0;32m'
yellow = '\033[0;33m'
blue = '\033[0;34m'
purple = '\033[0;35m'
cyan = '\033[0;36m'
white = '\033[0;37m'
end = '\033[0m'

host_file = '/etc/hosts'

new_file_path = None

def log_error(*msg):
    if msg is None:
        msg_str = ''
    else:
        msg_str = reduce(lambda x, y: str(x) + ' ' + str(y), msg)
    print('%s%s%s%s' % (red, 'ERROR | ', msg_str, end))


def log_info(msg):
    print('%s%s%s%s' % (green, 'INFO  | ', msg, end))


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
    with open(host_file) as file: 
        lines = file.readlines()
        for line in lines:
            if get_group_start(group) in line:
                return True
    return False


def append_group(group, file_path):
    contained = has_contain_group(group)
    if contained:
        log_error('group already exist', group)
        return
    
    assert_file(file_path)

    host = open(host_file, 'a')
    host.write('\n' + get_group_start(group) + '\n\n')
    with open(file_path) as file: 
        lines = file.readlines()
        for line in lines:
            host.write(line)
            print(line, end='')
        print()
    host.write('\n\n' + get_group_end(group) + '\n')
    log_info('append group sucessful')


# add # for content in group
def comment_content(result_lines, line, content_flag):
    if content_flag and not line.startswith('#'):
        result_lines.append('#' + line)
    else : 
        result_lines.append(line)


# remove # for content in group
def uncomment_content(result_lines, line, content_flag):
    if content_flag and line.startswith('#'):
        result_lines.append(line[1:])
    else:
        result_lines.append(line)


# read origin file, write back origin file with the result list 
def replace_content(group, content_func=None, logic_func=None):
    if not has_contain_group(group):
        log_error('group not exist')
        return
    
    result_lines = []
    with open(host_file) as file: 
        lines = file.readlines()
        result_lines = content_func(group, lines, logic_func)
    
    write_to_hosts(result_lines)


# func value, trans into  replace_content
def open_close_group(group, lines, logic_func) -> []:
    content_flag = False
    result_lines=[]
    for line in lines:
        if get_group_start(group) in line:
            content_flag = True
            result_lines.append(line)
            continue 

        if get_group_end(group) in line:
            content_flag = False
            result_lines.append(line)
            continue

        if logic_func is None:
            log_error('must have logic func')
            sys.exit()
        logic_func(result_lines, line, content_flag)
    return result_lines


# func value , trans into  replace_content
def replace_group_content(group, lines, logic_func=None):
    result_lines = []
    content_flag = False
    for line in lines:
        if get_group_start(group) in line:
            content_flag = True
            result_lines.append(line)
            continue 

        if get_group_end(group) in line:
            content_flag = False
            print(new_file_path)
            with open(new_file_path, 'r') as file:
                new_lines = file.readlines()
                for new_line in new_lines:
                    result_lines.append(new_line)
                result_lines.append('\n')
            result_lines.append(line)
            continue
        
        if not content_flag:
            result_lines.append(line)

    return result_lines


def write_to_hosts(lines):
    if lines is None:
        return
    total_content = ''.join(lines)
    with open(host_file, 'w+') as file: 
        file.write(total_content)


def assert_file(file_path):
    if not os.path.exists(file_path):
        log_error('file not found:', file_path)
        sys.exit(1)


def assert_param(args, count):
    if len(args) < count:
        log_error('invalid param, at least need', count)
        sys.exit(1)
    

def main(verb=None, *args):
    assert_file(host_file)

    if verb == '-h':
        help()
        sys.exit(0)
    
    if verb == '-a':
        assert_param(args, 2);
        append_group(group=args[0], file_path=args[1])
    
    if verb == '-r':
        assert_param(args, 2);
        global new_file_path
        new_file_path=args[1]
        replace_content(group=args[0], content_func=replace_group_content)

    if verb == '-on':
        assert_param(args, 1);
        replace_content(group=args[0], content_func=open_close_group, logic_func=uncomment_content)

    if verb == '-off':
        assert_param(args, 1);
        replace_content(group=args[0], content_func=open_close_group, logic_func=comment_content)


fire.Fire(main)
