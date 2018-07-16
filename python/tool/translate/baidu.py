import os
import sys
import json
import hashlib
import urllib
import random
import requests
import fire

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

def configureIncorrect(configFile):
    logError("Please fill up the configuration infomation : appid & secretKey on \033[0;32m"+configFile)
    print("You can register an account on this : "+green+"http://api.fanyi.baidu.com/api/trans/product/index")
    sys.exit(1)

# load json file add init script dir 
def loadConfig():
    useDir = os.environ['HOME']
    configDir = useDir + '/.config/kuangcp'
    appConfigDir = configDir +'/baiduTrans'
    configFile = appConfigDir +'/main.json'

    if not os.path.exists(configDir):
        os.mkdir(configDir)
    if not os.path.exists(appConfigDir):
        os.mkdir(appConfigDir)

    if not os.path.exists(configFile):
        with open(configFile, 'w') as file:
            file.write('{\n    "appid"     : "",\n    "secretKey" : ""\n}')
        configureIncorrect(configFile)

    data = json.load(open(configFile))
    appid = data['appid'] 
    secretKey = data['secretKey']

    if appid is None or secretKey is None or appid == "" or secretKey == "" or appid == " " or secretKey == " " :
        configureIncorrect(configFile)

    return data

def sendRequest(query, fromLang='zh', toLang='en'):
    data = loadConfig()
    appid = data['appid'] 
    secretKey = data['secretKey'] 
    myurl = '/api/trans/vip/translate'
    salt = random.randint(32768, 65536)
    sign = appid+query+str(salt)+secretKey

    m1 = hashlib.md5()
    m1.update(sign.encode("utf-8"))
    sign = m1.hexdigest()
    myurl = myurl+'?appid='+appid+'&q='+urllib.parse.quote(query)+'&from='+fromLang+'&to='+toLang+'&salt='+str(salt)+'&sign='+sign
    # print('https://fanyi-api.baidu.com'+myurl)

    result = requests.get('https://fanyi-api.baidu.com'+myurl, timeout=4)
    resultJson = json.loads(result.text)
    try:
        logInfo(resultJson["trans_result"][0]["dst"])
    except :
        logError("Error: Please check main.json or baidu api")
        print(result.text)

def logError(msg):
    print("%s%s%s"%(red, msg, end))

def logInfo(msg):
    print("%s%s%s"%(green, msg, end))

def printParam(verb, args, comment):
    print("  %s%-5s %s%-6s %s%s"%(green, verb, yellow, args, end, comment))

def help():
    print('run: %s  %s <verb> %s <args>%s'%('python baidu.py', green, yellow, end))
    printParam("-h", "", "help")
    printParam("word", "", "Translating Chinese into English")
    printParam("ez", "word", "Translating English into Chinese")

def main(verb=None, args=None):
    if verb is None:
        logError("Please select a parameter")
        sys.exit(1)
    if verb == "-h":
        help()
        sys.exit(0)
    paramList = ['ez', 'ze']
    if verb in paramList:
        if verb == "ez":
            sendRequest(args, 'en', 'zh')
        if verb == "ze":
            sendRequest(args, 'zh', 'en')  
    else:        
        sendRequest(verb)

fire.Fire(main)

