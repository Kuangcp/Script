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

host_file = '/etc/hosts'
# host_file = 'hosts.test'

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


def comment_content(result_lines, line, content_flag):
    if content_flag and not line.startswith('#'):
        # print('#', line)
        result_lines.append('#' + line)
    else : 
        result_lines.append(line)


def uncomment_content(result_lines, line, content_flag):
    if content_flag and line.startswith('#'):
        # print(line[1:])
        result_lines.append(line[1:])
    else:
        result_lines.append(line)

def replace_content_at_end(result_lines, file_path):
    with open(file_path, 'r') as file: 
        lines = file.readlines()
        for line in lines:
            result_lines.append(line)


def handle_group_content(group, content_func=None):
    if not has_contain_group(group):
        log_error('group not exist')
        return
    
    result_lines = []
    with open(host_file) as file: 
        lines = file.readlines()
        content_flag = False
        for line in lines:
            if get_group_start(group) in line:
                content_flag = True
                result_lines.append(line)
                continue

            if get_group_end(group) in line:
                content_flag = False
                result_lines.append(line)
                continue
            
            content_func(result_lines, line, content_flag)

    write_to_hosts(result_lines)


def write_to_hosts(lines):
    total_content = ''.join(lines)
    with open(host_file, 'w+') as file: 
        file.write(total_content)


def main(verb=None, *args):
    if verb == '-h':
        help()
        sys.exit(0)
    
    if len(args) < 2 or args[0] is None or args[1] is None:
        log_error('invalid param, at least need 2')
    else:
        if verb == '-a':
            append_group(group=args[0], file_path=args[1])
        # if verb == '-r':
        #     handle_group_content(group=args[0], replace=True, file_path=args[1])

    if len(args) < 1:
        log_error('group not exist')
    else: 
        if verb == '-on':
            handle_group_content(group=args[0], content_func=uncomment_content)

        if verb == '-off':
            handle_group_content(group=args[0], content_func=comment_content)


fire.Fire(main)
