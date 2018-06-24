import os
import sys
import getopt
import time

'''
处理 markdown 常用操作：
    添加目录（注意出现的字母要全部小写） 目录采用的URL的编码可以不转码
'''

def repalces(line, *lists):
    ''' 删除指定的字符 '''
    for key in lists:
        line = line.replace(key, "")
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

def line_prepender(filename, resultList):
    ''' 将集合追加到文件头部'''
    # 将读写分开,就没有那种诡异的bug了
    origin_lines = open(filename, 'r').readlines()
    with open(filename, 'w+') as f:
        f.seek(0, 0)
        for line in resultList:
            f.write(line.rstrip('\r\n') + '\n')
        # 加上一个逻辑 将目录结构不进行拼接,这样就实现了自动更新目录
        start_flag=False
        hr_line=0
        for single in origin_lines:
            # print("输出", single)
            if("`目录 start`" in single):
                print("  目录开始>>", end='')
                start_flag=True
            if("`目录 end`" in single):
                print("  目录结束>>", end='')
                start_flag=False
                hr_line = hr_line + 1
                continue
            if start_flag:
                continue
            # 不插入分割线  并且防止没有目录的文件被删除两行
            if hr_line <= 1 and hr_line != 0:
                hr_line = hr_line + 1
                continue
            f.write(single)
    print("   更新目录完成")
    

def append_title(CodeFlag, filename=None):
    if filename == None:
        # files = openfile()
        return 0 
    else:
        files = open(os.path.abspath(filename), 'r+')
    # files.write("\n`目录`\n")
    lines = files.readlines()
    results = []
    nowTime = time.strftime('%Y-%m-%d',time.localtime(time.time()))
    results.append("`目录 start`\n \n")
    for line in lines:
        if line.startswith("#"):
            line = line.strip('\n')
            weight = line.count("#")
            tab = "    "*(weight - 1)
            # 空格格式的安排
            line = line.replace("#", "").strip()
            temp = line
            # 删除字符 TODO标题最后一个空格（在去除字符前）会被忽略掉 引发bug
            line = repalces(line, ".", "【", "】", ":", "：", ",", "，", "/", "(", ")", "*", "。", "?", "？")
            line = line.replace(" ", "-").strip()
            result = line.lower()
            # files.write(tab + "- [" + temp + "](#" + result + ")\n")
            results.append(tab + "- [" + temp + "](#" + result + ")\n")
    results.append("\n`目录 end` |_"+nowTime+"_| [码云](https://gitee.com/kcp1104) | [CSDN](http://blog.csdn.net/kcp606) | [OSChina](https://my.oschina.net/kcp1104)")
    results.append("*"*40)
    line_prepender(filename, results)

def test():
    file = openfile()
    for line in file:
        print(line)
    file.close()
    # temp = "资料篇".encode('utf-8')
    # print(temp)
    # print(temp.encode('utf-8'))
    
def main():
    '''主函数'''
    ignoreList = [
        'SUMMARY.md', 'README.md', 'CODE_OF_CONDUCT.md','Process.md'
        ]
    opts,args = getopt.getopt(sys.argv[1:], 'htla:')
    for op, value in opts:
        if op == '-h':
            print('''
    -h      帮助
    -t      测试
    -a      追加目录树索引 n 不转码
                ''')
            break
        if op == '-t':
            test()
            break
        if op == '-a':
            filename = None
            if len(sys.argv) > 3:
                filename = sys.argv[3]
                if filename in ignoreList:
                    return 0
            if value == 'n':
                append_title(False, filename)
            else:
                append_title(True, filename)
            break
        

if __name__ == '__main__':
    main()


# 测试文件：/home/mythos/Documents/Notes/Myth_Notes/Python/zip.txt
# /home/mythos/Documents/Notes/Myth_Notes/TXT/Linux/Docker.md
