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

    def analysis_html(self) -> BeautifulSoup:
        log.setLevel(logging.INFO)
        """ 将url解析成soup对象 """
        log.info("Read %s" % self.url)

        result = self.read_url()
        status_type = result.status_code / 100
        if status_type == 2:
            pass
        elif status_type == 4:
            self.error('Page not found')
            sys.exit(1)
        elif status_type == 5:
            self.error('Server Error 5**')
            sys.exit(1)
        else:
            self.error('Other code %s' % status_type)
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
        """ 对 html block 查找 element属性的值 找不到就返回 None"""

        if element is None or block is None:
            return None

        try:
            start_index = block.index(element + '=')
            value = block[len(element) + 2 + start_index:].split('"')[0]
            return value
        except ValueError:
            log.debug("%s 没有 %s 属性" % (block, element))
            return None

    def read_url(self):
        try:
            result = self.get()
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
        """发起get请求"""
        return requests.get(self.url, timeout=timeout, headers=self.headers)
