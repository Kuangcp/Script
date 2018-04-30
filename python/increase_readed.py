#!/usr/bin/python3
import fire
from base.ReadURL import ReadURL
from time import sleep
# 增加某用户的CSDN阅读量, 发现是每天都能去增加一次

def read_blog(list_url):
    readUrl = ReadURL(list_url)
    soup = readUrl.readhtml()
    titleList = soup.find_all('h4')
    for line in titleList:
        classType = readUrl.getelement(str(line), 'class')
        if classType == 'text-truncate':
            line = str(line)
            # print(">>"+line);
            temp = line.split('a href="')[1];
            # print("<<"+temp)
            url = temp.split('" target=')[0]
            readUrl.url = url
            readUrl.readhtml()
def loop():
    for i in range(1, 3, 1):
        list_url = 'http://blog.csdn.net/kcp606/article/list/'+str(i)
        print(list_url)
        read_blog(list_url)
    
def main(flag=0):
    ''' 如果脚本后的参数为空就只执行一次, 否则死循环 '''
    if flag == 1:
        while (1):
            loop()
            sleep(600)
    else:
        loop()    
       
fire.Fire(main)