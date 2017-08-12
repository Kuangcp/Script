#!/usr/bin/python3

import urllib.parse
import sys
import getopt

#print("1 行首添加 - 符号 ")
#print("2 生成文档目录")
#print("3 测试  ")

'''
    处理 markdown 常用操作 
    目录采用的URL的编码，要用这个实现转码
'''

# 打开目标文件，找不到文件会一直等待重新输入
def openfile(first=True):
    if first:
        out = "请输入文件完整路径或者直接拖动md文件到终端\n"
    else:
        out = ""
    filepath = input(out)
    filepath = filepath.replace("'", " ").strip()
    #print("输入的是：", filepath)
    try:
        file = open(filepath, "r+")
    except FileNotFoundError:
        print("文件找不到请重新输入路径")
        return openfile(first=False)
    return file

# 行首添加 - 
def deal_line():
    file = openfile()
    file.write("\n")
    for line in file:
        print("- ", line)
        file.write("- " + line)
    file.close()

def append_title():
    file = openfile()
    file.write("\n\r")
    for line in file:
        if line.startswith("#"):
            line = line.strip('\n')
            weight = line.count("#")
            tab = ""
            # 空格格式的安排
            for i in range(weight - 1):
                tab += "    "
            line = line.replace("#", "").strip()
            temp = line
            line = line.replace(".", "").strip()
            line = line.replace(" ", "").strip()
            # 将中文和特殊字符进行URL编码
            result = urllib.parse.quote_from_bytes(line.lower().encode('utf-8'))
            file.write(tab + "- [" + temp + "](#" + result + ")\n")
            print(tab + "- [" + temp + "](#" + result + ")\n")

def test():
    print(urllib.parse.quote_from_bytes(".Redis资料篇".lower().encode('utf-8')))
    file = openfile()
    for line in file:
        print(line)
    file.close()
    # temp = "资料篇".encode('utf-8')
    # print(temp)
    # print(temp.encode('utf-8'))
    
def main():
    '''主函数'''
    opts,args = getopt.getopt(sys.argv[1:], 'htla')
    for op, value in opts:
        if op == '-h':
            print('''
    -h      帮助
    -t      测试
    -a      追加目录树索引
    -l      行首追加 -
                ''')
            break
        if op == '-t':
            test()
            break
        if op == '-l':
            deal_line()
            break
        if op == '-a':
            append_title()
            break
        

if __name__ == '__main__':
    main()


# 测试文件：/home/mythos/Documents/Notes/Myth_Notes/Python/zip.txt
# /home/mythos/Documents/Notes/Myth_Notes/TXT/Linux/Docker.md
