#/usr/bin/env python
#coding=utf8
 
import httplib
import md5
import urllib
import random

appid = '' #你的appid
secretKey = '' #你的密钥

 
httpClient = None
myurl = '/api/trans/vip/translate'
q = '没有用'
fromLang = 'zh'
toLang = 'en'
salt = random.randint(32768, 65536)

sign = appid+q+str(salt)+secretKey
m1 = md5.new()
m1.update(sign)
sign = m1.hexdigest()
myurl = myurl+'?appid='+appid+'&q='+urllib.quote(q)+'&from='+fromLang+'&to='+toLang+'&salt='+str(salt)+'&sign='+sign
 
try:
    httpClient = httplib.HTTPConnection('api.fanyi.baidu.com')
    httpClient.request('GET', myurl)
 
    #response是HTTPResponse对象
    response = httpClient.getresponse()
    print response.read()
except Exception, e:
    print e
finally:
    if httpClient:
        httpClient.close()
