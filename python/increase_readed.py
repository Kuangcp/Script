from base.ReadURL import ReadURL

# 增加某用户的CSDN阅读量, 发现是每天都能去增加一次

def read_blog(list_url):
    readUrl = ReadURL(list_url)
    soup = readUrl.readhtml()
    li_list = soup.find_all('li')
    for li_element in li_list:
        li_class = readUrl.getelement(str(li_element), 'class')
        
        if li_class == "blog-unit":
            # print(li_element)
            a_href = readUrl.getelement(str(li_element), 'href')
            # print("http://blog.csdn.net/"+a_href)
            readUrl.url = "http://blog.csdn.net/"+a_href
            readUrl.readhtml()
            # print("*"*40)


for i in range(1, 3, 1):
    list_url = 'http://blog.csdn.net/kcp606/article/list/'+str(i)
    read_blog(list_url)
