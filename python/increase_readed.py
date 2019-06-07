#!/usr/bin/python3
import fire
from tool.spider.ReadURL import ReadURL
from time import sleep


# 增加某用户的CSDN阅读量, 发现是每天都能去增加一次

def read_blog(list_url):
    read_url = ReadURL(list_url, {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Cache-Control': 'max-age=0',
    })
    soup = read_url.read_html()

    print(soup)

    title_list = soup.find_all('h4')
    for line in title_list:
        tag = ReadURL.get_element(str(line), 'target')
        if tag == '_blank':
            line = str(line)
            temp = line.split('a href="')[1]
            url = temp.split('" target=')[0]
            if "kcp606" not in url:
                continue
            read_url.url = url
            read_url.read_html()


def show_info(info_url):
    """ 展示用户信息 """
    read_url = ReadURL(info_url, {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Cache-Control': 'max-age=0',
    })
    soup = read_url.read_html()

    print(soup)
    title_list = soup.find_all('div')
    for line in title_list:
        class_type = ReadURL.get_element(str(line), 'class')
        print(class_type)
        if class_type == 'item-tiling':
            print(line)
            # first_temp = str(line).split('class="count"')
            # print('    原创\033[0;32m', first_temp[1].split('</')[0][1:], '\033[0m', end='')
            # print('粉丝\033[0;32m', first_temp[2].split('</')[0][10:], '\033[0m', end='')
            # print('喜欢\033[0;32m', first_temp[3].split('</')[0][1:], '\033[0m', end='')
            # print('评论\033[0;32m', first_temp[4].split('</')[0][1:], '\033[0m', end='')
            # print('等级\033[0;32m', str(line).split(',点击查看等级说明')[0].split('target="_blank" title="')[1], '\033[0m', end='')
            # print('访问\033[0;32m', str(line).split('<dd title="')[1].split('">')[0], '\033[0m', end='')
            # print('积分\033[0;32m', str(line).split('<dd title="')[2].split('">')[0], '\033[0m', end='')
            # print('排名\033[0;32m', str(line).split('<dl title="')[1].split('">')[0], '\033[0m')


def loop():
    # read_blog('http://blog.csdn.net/kcp606/article/list/1')
    # 三个参数: [n,m) delta
    for i in range(1, 4, 1):
        list_url = 'http://blog.csdn.net/kcp606/article/list/' + str(i)
        print(list_url)
        read_blog(list_url)


def show_help():
    start = '\033[0;32m'
    end = '\033[0m'
    print("%-26s %-20s" % (start + "-h" + end, "帮助"))
    print("%-26s %-20s" % (start + "-l " + end, "死循环刷阅读量"))
    print("%-26s %-20s" % (start + "-s" + end, "展示个人信息"))


def main(action=None):
    """ 如果脚本后的参数为空就只执行一次, 否则死循环 """
    # print(action)
    if action == '-l':
        while True:
            loop()
            sleep(600)

    if action is None:
        loop()

    if action == '-h':
        show_help()

    if action == '-s':
        show_info('https://blog.csdn.net/kcp606')


fire.Fire(main)
