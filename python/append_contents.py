import urllib.parse
import os
import sys
import getopt

'''
    处理 markdown 常用操作：
         添加目录（注意出现的字母要全部小写） 目录采用的URL的编码可以不转码，但是要确定不能有空格
         目录中的 【】. 在跳转路径中视为没有  即 [【.d】](#d) 不允许出现空格以及逗号感叹号， `前不能有空格
         使用shell实现更好
'''

def repalces(line, *lists):
    for key in lists:
        line = line.replace(key, "").strip()
    return line

# 打开目标文件，找不到文件会一直等待重新输入
def openfile(first=True):
    if first:
        out = "请输入文件完整路径或者直接拖动md文件到终端\n"
    else:
        # 第二次输入不输出提示
        out = ""
    filepath = input(out)
    filepath = filepath.replace("'", " ").strip()
    #print("输入的是：", filepath)
    try:
        file = open(filepath, "r+")
    except :
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

def append_title(CodeFlag, filename=None):
    if filename == None:
        files = openfile()
    else:
        files = open(os.path.abspath(filename), 'r+')
    files.write("\n`目录`\n")
    lines = files.readlines()
    for line in lines:
        if line.startswith("#"):
            line = line.strip('\n')
            weight = line.count("#")
            tab = ""
            # 空格格式的安排
            for i in range(weight - 1):
                tab += "    "
            line = line.replace("#", "").strip()
            temp = line
            line = repalces(line, ".", " ", "【", "】")
            # line = line.replace(".", "").strip()
            # line = line.replace(" ", "").strip()
            # line = line.replace("【","").strip()
            # line = line.replace("】","").strip()
            
            if CodeFlag:
                # 将中文和特殊字符进行URL编码
                result = urllib.parse.quote_from_bytes(line.lower().encode('utf-8'))
            else:
                result = line.lower()

            files.write(tab + "- [" + temp + "](#" + result + ")\n")
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
    opts,args = getopt.getopt(sys.argv[1:], 'htla:')
    for op, value in opts:
        if op == '-h':
            print('''
    -h      帮助
    -t      测试
    -a      追加目录树索引 n 不转码
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
            filename = None
            if len(sys.argv) > 3:
                filename = sys.argv[3]
            if value == 'n':
                append_title(False, filename)
            else:
                append_title(True, filename)
            break
        

if __name__ == '__main__':
    main()


# 测试文件：/home/mythos/Documents/Notes/Myth_Notes/Python/zip.txt
# /home/mythos/Documents/Notes/Myth_Notes/TXT/Linux/Docker.md
