import requests
from bs4 import BeautifulSoup
import sys, os
from time import sleep

# 需要安装 requests bs4 lxml 模块
class ReadURL:
    ''' 读取URL并解析'''
    def __init__(self, url):
        self.url = url

    def readhtml(self):
        ''' 将url解析成soup对象 '''
        headers = {
            'User-Agent' : 'Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0',
            'Accept' : 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' : 'zh-CN,en-US;q=0.7,en;q=0.3',
            'Referer' : 'http://blog.csdn.net/kcp606',
            'Upgrade-Insecure-Requests' : '1'
            }
        print('-'*30)
        print('尝试读取 URL',self.url, end='')
        # 这个逻辑就是, 如果读取超时,就重新发起一次,如果还是失败,直接终止
        try:
            result = requests.get(self.url, timeout=4, headers=headers)
        except Exception:
            print("!!!!!!!! 请求超时, 正在等待5s后重试 !!!!!!!!", self.url)
            try:    
                sleep(5)
                result = requests.get(self.url, timeout=5, headers=headers)
            except Exception:
                print("第二次重试失败 程序自动退出")
                sys.exit(1)
        
        print("  -> 读取结果: ",result)
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

    def getelement(self, block, element):
        ''' 对代码块 block 查找 element属性的值 找不到就返回 none'''
        # log = open('debug.log','w+')
    
        elements = block.split(' ')
        for ele in elements:
            if ele.startswith(element):
                return ele.split('"')[1]
        # log.write("------ "+line+"没有属性"+element+"\n")
        # print(">>>>>>> "+block+"没有属性"+element+"\n")
        return 'none'
