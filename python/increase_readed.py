#!/usr/bin/python3
import fire
from tool.spider.ReadURL import ReadURL
from time import sleep

# 增加某用户的CSDN阅读量, 发现是每天都能去增加一次
header = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
    'Accept-Encoding': 'gzip, deflate, br',
    'DNT': '1',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
    'Cache-Control': 'max-age=0',
}

pattern = ' \033[0;32m%s\033[0m '

username = 'kcp606'
root_url = 'https://blog.csdn.net/' + username
blog_root_url = root_url + '/article/list'


def read_blog(list_url) -> bool:
    """读取页的URL得到每个博客URL 返回是否有该页存在"""
    print(list_url)
    read_url = ReadURL(list_url, header)
    soup = read_url.analysis_html()

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
            read_url.analysis_html()

    return len(title_list) != 0


def show_info(info_url):
    """ 展示用户信息 """
    read_url = ReadURL(info_url, header)
    soup = read_url.analysis_html()

    title_list = soup.find_all('div')
    for line in title_list:
        class_type = ReadURL.get_element(str(line), 'class')
        if class_type is None:
            continue
            
        if 'item-tiling' in class_type:
            first_temp = str(line).split('class="count"')
            print_info('\t原创', first_temp[1].split('</')[0][1:])
            print_info('粉丝', first_temp[2].split('</')[0][10:])
            print_info('喜欢', first_temp[3].split('</')[0][1:])
            print_info('评论', first_temp[4].split('</')[0][1:])

        if 'grade-box clearfix' in class_type:
            print_info('等级', str(line).split(',点击查看等级说明')[0].split('target="_blank" title="')[1])
            print_info('访问', str(line).split('<dd title="')[1].split('">')[0])
            print_info('积分', str(line).split('<dd title="')[2].split('">')[0])
            print_info('排名', str(line).split('<dl title="')[1].split('">')[0])
    print()


def print_info(msg, value):
    print(msg + pattern % value, end='')


def seek_every_blog():
    """遍历所有的page"""

    count = 1
    list_url = blog_root_url + '/' + str(count)
    while read_blog(list_url):
        count += 1
        list_url = blog_root_url + '/' + str(count)


def show_help():
    start = '\033[0;32m'
    end = '\033[0m'
    print("%-26s %-20s" % (start + "-h" + end, "帮助"))
    print("%-26s %-20s" % (start + "-l " + end, "死循环刷阅读量"))
    print("%-26s %-20s" % (start + "-s" + end, "展示个人信息"))


def main(action=None):
    if action is None:
        seek_every_blog()

    if action == '-l':
        while True:
            seek_every_blog()
            sleep(600)

    if action == '-h':
        show_help()

    if action == '-s':
        show_info(root_url)


fire.Fire(main)
