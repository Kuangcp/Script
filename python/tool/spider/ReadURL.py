import logging

import requests
from bs4 import BeautifulSoup
import sys
import time
from base.logger import log


class ReadURL:
    def __init__(self, url, headers):
        self.url = url
        self.headers = headers

    def read_html(self) -> BeautifulSoup:
        log.setLevel(logging.INFO)
        """ 将url解析成soup对象 """
        log.info("Read %s" % (self.url))

        # now = '\033[0;33m' + time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + '\033[0m'
        # print(now, 'Read → \033[0;34m', self.url, '\033[0m', end='')
        result = self.read_url()
        # print(" → Result : ", end='')
        status_type = result.status_code / 100
        if status_type == 2:
            self.success('Success')
        elif status_type == 4:
            self.error('Page not found')
            sys.exit(1)
        elif status_type == 5:
            self.error('Server Error 5**')
            sys.exit(1)

        result.encoding = "utf-8"
        soup = BeautifulSoup(result.text, 'lxml')
        return soup

    @staticmethod
    def success(content=''):
        log.info(content)

    @staticmethod
    def error(content=''):
        log.error(content)

    @staticmethod
    def get_element(block, element):
        """ 对代码块 block 查找 element属性的值 找不到就返回 None"""
        elements = block.split(' ')
        for ele in elements:
            if ele.startswith(element):
                return ele.split('"')[1]
        log.debug("%s 没有 %s 属性" % (block, element))
        return None

    def read_url(self):
        try:
            result = self.get(4)
        except Exception as e:
            print(e)
            self.error('Request timed out, Wait 5s to try again : ' + self.url)
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
