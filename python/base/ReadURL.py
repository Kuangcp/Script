import requests
from bs4 import BeautifulSoup
import sys
import time


class ReadURL:
    def __init__(self, url):
        self.url = url
        self.headers = {
            'Host': 'blog.csdn.net',
            'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
            'Accept-Encoding': 'gzip, deflate, br',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Cache-Control': 'max-age=0',

            # 'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0',
            # 'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            # 'Accept-Language': 'zh-CN,en-US;q=0.7,en;q=0.3',
            # 'Referer': 'http://blog.csdn.net/kcp606',
            # 'Upgrade-Insecure-Requests': '1'
        }

    def read_html(self) -> BeautifulSoup:
        """ 将url解析成soup对象 """
        now = '\033[0;33m' + time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + '\033[0m'
        print(now, 'Read → \033[0;34m', self.url, '\033[0m', end='')
        result = self.read_url()
        print(" → Result : ", end='')
        if str(result) == '<Response [200]>':
            self.success(str(result))
        elif str(result).startswith('<Response [4'):
            self.error('Page not found')
            sys.exit(1)
        elif str(result).startswith('<Response [5'):
            self.error('Server Error 5**')
            sys.exit(1)
        result.encoding = "utf-8"
        soup = BeautifulSoup(result.text, 'lxml')
        return soup

    @staticmethod
    def success(content=''):
        print('\033[0;32m', content, '\033[0m')

    @staticmethod
    def error(content=''):
        print('\033[0;31m', content, '\033[0m')

    @staticmethod
    def get_element(block, element):
        """ 对代码块 block 查找 element属性的值 找不到就返回 None"""
        elements = block.split(' ')
        for ele in elements:
            if ele.startswith(element):
                return ele.split('"')[1]
        # print(">>>>>>> "+block+"没有属性"+element+"\n")
        return None

    def read_url(self):
        try:
            result = self.get(4)
        except Exception as e:
            print(e)
            self.error('\n Request timed out, Wait 5s to try again : ' + self.url)
            try:
                time.sleep(5)
                result = self.get(5)
            except Exception as e:
                print(e)
                self.error('Retry failed')
                sys.exit(1)
        return result

    def get(self, timeout=5):
        return requests.get(self.url, timeout=timeout, headers=self.headers)
