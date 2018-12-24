import fire
import sys
import os
import time

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'   
white='\033[0;37m'
end='\033[0m'

ignore_list=[".", "【", "】", ":", "：", ",", "，", "/", "(", ")","《" ,"》", "*", "。", "?", "？"]

title='''---
title: %s
date: 
tags: 
categories: 
---

**目录 start**
**目录 end**

'''

def logError(msg):
    print('%s%s%s'%(red, msg, end))

def logInfo(msg):
    print('%s%s%s'%(green, msg, end))

def printParam(verb, args, comment):
    print('  %s%-5s %s%-6s %s%s'%(green, verb, yellow, args, end, comment))

def help():
    print('run: %s  %s <verb> %s <args>%s'%('generate_catalog.py', green, yellow, end))
    printParam('-h', '', 'help')
    printParam('filename', '', 'refresh catalog')
    printParam('-at', 'filename', 'append title and catalog')

def delete_char(strs, lists):
    ''' 删除指定的字符 '''
    for char in lists:
        strs = strs.replace(char, "")
    return strs

def generate_catalog(filename) -> []:
    files = open(os.path.abspath(filename), 'r+')
    lines = files.readlines()
    catalogs = ["**目录 start**\n \n"]
    nowTime = time.strftime('%Y-%m-%d %H:%M',time.localtime(time.time()))
    for line in lines:
        if not line.startswith("#"):
            continue
        line = line.strip('\n')
        weight = line.count("#")
        tab = "    "*(weight - 1)
        line = line.replace("#", "").strip()
        temp=line

        line = delete_char(line, ignore_list)
        line = line.replace(" ", "-").strip()
        result = line.lower()

        catalogs.append(tab + "1. [" + temp + "](#" + result + ")\n")
    
    catalogs.append("\n**目录 end**|_"+nowTime+"_| [码云](https://gitee.com/gin9) | [CSDN](http://blog.csdn.net/kcp606) | [OSChina](https://my.oschina.net/kcp1104) | [cnblogs](http://www.cnblogs.com/kuangcp)")
    catalogs.append("*"*40)
    return catalogs

def replace_catalog(filename, catalogs):
    origin_lines = open(filename, 'r').readlines()
    
    with open(filename, 'w+') as file:
        start_flag = False
        end_flag = False
        hr_line = False

        print(green, filename, end, ' ', end='')
        for line in origin_lines:
            if not end_flag:
                if "**目录 end**" in line:
                    start_flag = False
                    end_flag = True
                    for catalog in catalogs:
                        file.write(catalog.rstrip('\r\n') + '\n')
                    print('catalog end >> ', end='')
                    continue

                if start_flag :
                    continue

                if "**目录 start**" in line:
                    start_flag = True
                    print('catalog start >> ', end='')
                    continue
                file.write(line.rstrip('\r\n') + '\n')
            else:
                if not hr_line :
                    hr_line = True
                    continue
                file.write(line.rstrip('\r\n') + '\n')
        print('complete.')

def refresh_catalog(filename):
    catalogs = generate_catalog(filename)
    replace_catalog(filename, catalogs)

def append_title_and_catalog(filename):
    if filename is None:
        logError('filename is empty')
        return 
    files = open(os.path.abspath(filename), 'r')
    lines = files.readlines()

    with open(filename, 'r+') as file:
        if '---' != lines[0].strip() or len(lines) == 0:
            file.write(title%(filename.split('/')[-1]))
        for line in lines:
            file.write(line)
    
    refresh_catalog(filename)
    
def main(verb=None, args=None):
    if verb == '-h':
        help()
        sys.exit(0)
        
    if verb == '-at':
        # TODO 添加头信息 不完美
        append_title_and_catalog(args)
        sys.exit(0)

    if verb is None:
        logError('please input filename')
        sys.exit(1)
    
    refresh_catalog(verb)

fire.Fire(main)
