import requests
from bs4 import BeautifulSoup
import sys, os
from time import sleep

# 增加某用户的CSDN阅读量, 发现是每天都能去增加一次

def getelement(line, element):
    # log = open('debug.log','w+')
    
    elements = line.split(' ')
    for ele in elements:
        if ele.startswith(element):
            return ele.split('"')[1]
    # log.write("------ "+line+"没有属性"+element+"\n")
    print("------ "+line+"没有属性"+element+"\n")
    return 'none'

def readhtml(url):
    headers = {'User-Agent' : 'Mozilla/5.0 (X11; Linux x86_64; rv:53.0) Gecko/20100101 Firefox/53.0',
               'Accept' : 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
               'Accept-Language' : 'zh-CN,en-US;q=0.7,en;q=0.3'
                #'' : '',
                #'' : '',
               }
    print('-'*30)
    print('尝试读取 URL',url)
    # 这个逻辑就是, 如果读取超时,就重新发起一次,如果还是失败,直接终止
    try:
        result = requests.get(url, timeout=4, headers=headers)
    except Exception:
        print("!!!!!!!! 超时等待5s后重试 ......", url)
        try:    
            sleep(5)
            result = requests.get(url, timeout=5, headers=headers)
        except Exception:
            print("第二次重试失败 程序退出")
            sys.exit(1)
    
    print("  ->读取返回状态码",result)
    if str(result) == '<Response [200]>':
        pass
    elif str(result).startswith('<Response [4'):
        print("页面不存在,请检查输入") # 无法继续
        sys.exit(1)
    elif str(result).startswith('<Response [5'):
        print("服务器连接超时, 请等待....")
        sleep(10)
    result.encoding = "utf-8"
    soup = BeautifulSoup(result.text, 'lxml')
    return soup

def read_blog(list_url):
    soup = readhtml(list_url)
    li_list = soup.find_all('li')
    for li_element in li_list:
        li_class = getelement(str(li_element), 'class')
        
        if li_class == "blog-unit":
            # print(li_element)
            a_target = getelement(str(li_element), 'target')
            a_href = getelement(str(li_element), 'href')
            print("http://blog.csdn.net/"+a_href)
            readhtml("http://blog.csdn.net/"+a_href)
            print("*"*40)


for i in range(1, 3, 1):
    list_url = 'http://blog.csdn.net/kcp606/article/list/'+str(i)
    read_blog(list_url)