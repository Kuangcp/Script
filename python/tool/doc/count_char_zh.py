# 统计中文字数
import fire
import os

count_file = 0
all_files = []

def count_file_zh(file_name):
    """
    统计文件文件中所有汉字, 目前还存在中文标点的误差
    原理是直接按字节读取文件, 三个连着的 大于 127 的就是汉字 和 中文标点(还不能确定是准确的判断)
    """
    ignore_char=[]
    # ignore_char.append([227, 128, 144]) # 【 
    # ignore_char.append([227, 128, 145]) # 】

    f = open(file_name, 'rb')
    count = 0
    # TODO 优化这个嵌套
    for line in f:
        temp = []
        for c in line:
            if(c > 127):
                temp.append(c)
            if(len(temp) == 3):
                # TODO 如何将 数字数组 看做byte 数组 从而转变为字符串
                # print('char : ', temp)
                
                if temp not in ignore_char:
                    count += 1
                temp = []
    # print("%-50s Total Chinese characters : %s "%(file_name, count))
    return count


def list_file(dir='.'):
    """递归列出当前目录所有文件"""
    global all_files
    global count_file
    files = os.listdir(dir)
    ignore_list = ['.git', 'SUMMARY.md.bak', 'LICENSE']

    for file in files:
        if file in ignore_list:
            continue
        if os.path.isdir(dir+'/'+file):
            # print('>> ', dir+'/'+file)
            list_file(dir+'/'+file)
        else:
            # print('-- ', dir, file)
            all_files.append(dir+'/'+file)
            count_file += 1

def show_sort(dict_file):
    """ 输出文件字数排行(存在覆盖的问题) """
    keys = dict_file.keys()
    temp = []
    for key in keys:
        temp.append(key)
    temp.sort(reverse=True)
    for key in temp:
        print(key, dict_file.get(key))

    #TODO  字典排序输出

    # dict_file= sorted(dict_file.items(), key=lambda d:d[1], reverse = True)
    # print(dict_file)
    # for key, value in dict_file:
    #     print("%-10s %s"%(key, value))

def main(verb=None):
    list_file()
    global count_file
    global all_files

    dict_file = {}
    # print('total file : ', count_file)
    total = 0
    for file in all_files:
        temp = count_file_zh(file)
        dict_file[temp] = file
        total += temp
    show_sort(dict_file)
    print('total char : ', total)

fire.Fire(main)