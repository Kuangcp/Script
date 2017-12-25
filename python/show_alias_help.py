'''
    输出帮助文档，命令长度最长25,保持整齐
'''
# 读取文件
def read_alias():
    contents = []
    alias = open('/home/kcp/.kcp_aliases')
    lines = alias.readlines()
    for line in lines:
        line = line.strip()
        contents.append(line)
    alias.close()
    return contents
# 切分每行的串
def divide_str():
    contents = read_alias()
    result = []
    for line in contents:
        #print(">>>"+line)
        if line.startswith('\n'):
            continue
        elif line.startswith('#') and not line.startswith('##'):
            result.append(line)
        elif line.startswith('alias') :
            temp = line.split('=\'')
            name = temp[0].split('alias')[1]
            comment = temp[1].split('#')[1]
            result.append(name+'$'+comment.strip())
    return result
# 格式化输出
def out_help():
    command_len = 26
    result = divide_str()
    for line in result:
        if line.startswith('#'):
            num = 40 - len(line)
            print('\033[1;35m'+' '*16+'[ '+line[2:]+' ]'+' '*num+'\033[0m')
        else:
            temp = line.split('$')
            space = command_len - len(temp[0])
            print(' \033[0;32m'+temp[0], ' '*space,'\033[0;36m'+temp[1]+'\033[0m')

def main():
    out_help()
        
main()
