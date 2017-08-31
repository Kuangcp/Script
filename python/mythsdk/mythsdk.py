import os
import sys
import time
import json
import shlex
import datetime
import subprocess

# json_url = " https://raw.githubusercontent.com/Kuangcp/Script/master/python/mythsdk/config.json"
json_url = " http://git.oschina.net/kcp1104/script/raw/master/python/mythsdk/config.json"

'''
2017-08-30 16:19:16
    配置sdk的环境，因为用sdkman用的很不爽，就用这个来做到大致的功能，自动下载的话，用的github网太慢体验不好
        1.自动配置环境变量  
        2.更改当前的sdk版本 
        3.列出所以可以下载的sdk 
        4.自动下载指定版本的sdk 
        
'''
def execute_command(cmdstring, cwd=None, timeout=None, shell=False):
    """执行一个SHELL命令
            封装了subprocess的Popen方法, 支持超时判断，支持读取stdout和stderr
           参数:
        cwd: 运行命令时更改路径，如果被设定，子进程会直接先更改当前路径到cwd
        timeout: 超时时间，秒，支持小数，精度0.1秒
        shell: 是否通过shell运行
    Returns: return_code
    Raises:  Exception: 执行超时"""
    if shell:
        cmdstring_list = cmdstring
    else:
        cmdstring_list = shlex.split(cmdstring)
    if timeout:
        end_time = datetime.datetime.now() + datetime.timedelta(seconds=timeout)
    #没有指定标准输出和错误输出的管道，因此会打印到屏幕上；
    sub = subprocess.Popen(cmdstring_list, cwd=cwd, stdin=subprocess.PIPE,shell=shell,bufsize=4096)
    #subprocess.poll()方法：检查子进程是否结束了，如果结束了，设定并返回码，放在subprocess.returncode变量中 
    while sub.poll() is None:
        time.sleep(0.1)
        if timeout:
            if end_time <= datetime.datetime.now():
                raise Exception("Timeout：%s"%cmdstring)
    return str(sub.returncode)

def shell(cmd):
    execute_command(cmd, shell=True)

def loadconfig():
    jsonfile = init()+'/.mythsdk/config.json'
    if not os.path.exists(jsonfile):
        print("下载配置文件")
        shell("curl -o "+jsonfile+json_url)

    data = json.load(open(jsonfile))
    return data
                
def list_all(sdk=None):
    ''' 列出所有sdk '''
    if sdk == None:
        print("\033[1;33mAll can install SDK list:\n    \033[1;32mused is green     \033[1;35minstalled is purple     \033[0maviable is white")
    data = loadconfig()
    sdks = data["sdks"]
    root_path = init()+"/.mythsdk/sdk"
    for one in sdks:
        if sdk!=None and sdk!=one:
                continue
        print(""+one+":")
        version = data["sdks"][one]
        count = 1
        for ver in version:
            if os.path.exists(root_path+"/"+one+"/"+ver+"/bin/current"):
                print("\033[1;32m    "+ver+"\033[0m")
            elif os.path.exists(root_path+"/"+one+"/"+ver):
                print("\033[1;35m    "+ver+"\033[0m")
            else:
                count += 1
                ver = "    "+ver+"  "
                print(ver, end="")
                if count%7 == 0 :
                    print("")
        print("")
def auto():
    ''' 使用规定的目录结构放置zip包 自动化配置sdk环境''' 
    current = os.getcwd()
    print(current)

def download(url, sdk, version):
    if not os.path.isdir(init()+"/.mythsdk/zip/"+sdk):
        shell("mkdir ~/.mythsdk/zip/"+sdk)
    if not os.path.exists(init()+"/.mythsdk/zip/"+sdk+"/"+version+".zip"):
        # down = "curl  -o ~/.mythsdk/zip/"+sdk+"/"+version+".zip "+url+sdk+"/"+sdk+"-"+version+".zip"
        cmd = "curl  -o ~/.mythsdk/zip/"+sdk+"/"+version+".zip "+url
        print("开始下载" + cmd)
        # subprocess.call(down, shell=True)
        shell(cmd)
        print("下载完成" )

def download_fromgit(sdk, version):
    url = "https://raw.githubusercontent.com/kuangcp/Apps/master/zip/"+sdk+"/"+sdk+"-"+version+".zip"
    download(url, sdk, version)

def down_fromqiniu(sdk, version):
    url = "http://oscenptok.bkt.clouddn.com/"+sdk+"-"+version+".zip"
    download(url, sdk, version)
    

def unzip_file(sdk, version=None):
    ''' 解压到对应的目录'''
    if not os.path.isdir(init()+"/.mythsdk/sdk/"+sdk):
        shell("mkdir ~/.mythsdk/sdk/"+sdk)
        # execute_command("mkdir ~/.mythsdk/sdk/"+sdk+"/"+version, shell=True)
    if not os.path.isdir(init()+"/.mythsdk/sdk/"+sdk+"/"+version):
        unzip = "unzip ~/.mythsdk/zip/"+sdk+"/"+version+".zip -d ~/.mythsdk/sdk/"+sdk
        # shell(unzip)
        subprocess.call(unzip, shell=True)
        print("解压完成")
    # 如果软链接不存在就新建，并设置环境变量，如果有就说明已经安装过一个版本，就只要解压就行了
    if not os.path.exists(init()+"/.mythsdk/sdk/"+sdk+"/current"):
        print("建立软链接")
        shell("ln -s ~/.mythsdk/sdk/"+sdk+"/"+version+" ~/.mythsdk/sdk/"+sdk+"/current")
        shell("touch ~/.mythsdk/sdk/"+sdk+"/"+version+"/bin/current") # 建立当前使用的标记
        config(sdk)
    

def config(sdk):
    ''' 配置环境变量 '''
    if sdk == 'java':
        shell("echo '\n "+sdk.upper()+"_HOME=~/.mythsdk/sdk/"+sdk+"/current' >> ~/.bash_aliases")
        ENV = '''\nexport JRE_HOME=${JAVA_HOME}/jre\nexport CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib\nexport PATH=${JAVA_HOME}/bin:$PATH'''
        shell("echo '"+ENV+"' >> ~/.bash_aliases")
    else:
        shell("echo '\n"+sdk.upper()+"_HOME=~/.mythsdk/sdk/"+sdk+"/current' >> ~/.bash_aliases")
        shell("echo 'export PATH=$PATH:$"+sdk.upper()+"_HOME/bin' >> ~/.bash_aliases")
    refresh()

def refresh():
    ''' 刷新配置 命令运行无效？？？？'''
    print("\033[1;33m请运行 source ~/.bashrc 即可立即生效 或者重启终端\033[0m")
    shell(". ~/.bashrc")

def install(sdk, version=None):
    ''' verison为空就是安装最新版，JSON里的最后一个版本'''
    data = loadconfig()
    sdks = data['sdks']
    if not sdk in sdks:
        print("当前仓库没有该sdk! \n收纳的sdk:")
        list_all()
        return 0
    if version != None:
        # print(version, data[sdk])
        if version not in data["sdks"][sdk]:
            print("没有该版本! \n收纳的sdk:")
            list_all()
            return 0 
    if version == None:
        version = data["sdks"][sdk][-1]
    down_fromqiniu(sdk, version)
    # download_fromgit(sdk, version)
    unzip_file(sdk, version)

def handle():
    ''' 手动添加bin目录来配置sdk '''
    path = input("bin目录的绝对路径")
    print(path)

def change(sdk, version):
    '''更改sdk版本 只要更改软链接就可以了'''
    datas = loadconfig()
    if not sdk in datas["sdks"]:
        print("仓库没有安装该sdk"+sdk)
        return 0 
    ed_version = os.listdir(init()+"/.mythsdk/sdk/"+sdk)

    if not version in ed_version:
        print("仓库没有安装该 sdk"+sdk+"的版本")
        return 0
    if os.path.exists(init()+"/.mythsdk/sdk/"+sdk+"/current"):
        shell("rm ~/.mythsdk/sdk/"+sdk+"/current/bin/current")
        shell("rm -rf ~/.mythsdk/sdk/"+sdk+"/current")
        
        shell("ln -s ~/.mythsdk/sdk/"+sdk+"/"+version+" ~/.mythsdk/sdk/"+sdk+"/current")
        shell("touch ~/.mythsdk/sdk/"+sdk+"/current/bin/current")
    else:
        print("\n该SDK "+sdk+" 没有安装任何版本，切换失败 \n    安装请使用命令 python mythsdk.py i "+sdk+" <version>\n")
    
def help():
    print('''python \033[1;33m myth.py <params>：
    l|list <sdk>： \033[0m
        输出所有可安装的sdk,指定则输出指定sdk信息
    \033[1;33mu|use sdk version :\033[0m
        使用已安装的指定sdk的版本
    \033[1;33mi|install sdk <version> : \033[0m
        安装指定版本，不指定则安装最新版''')
def update_config():
    ''' 升级配置文件 '''
    jsonfile = init()+'/.mythsdk/config.json'
    print("更新配置文件")
    shell("rm "+jsonfile)
    shell("curl -o "+jsonfile+json_url)


def two_param(action):
    # 放在同级目录下，自动配置
    # if action == 'auto' or action == 'a':
    #     auto()
    if action == 'list' or action == 'l':
        list_all()
    if action == "help" or action == 'h':
        help()
    if action == "update" or action =='up':
        update_config()

def thr_param(action, sdk):
    if action == 'install' or action == 'i':
        install(sdk)
    if action == 'list' or action == 'l':
        list_all(sdk)

def four_param(action, sdk, version):
    if action == 'install' or action == 'i':
        install(sdk, version)
    if action == 'use' or action == 'u':
        change(sdk, version)

def readparam():
    ''' 读取参数 调用对应的方法 '''
    length = len(sys.argv)
    if length < 2:
        print("请输入参数！！！")
        help()
        return 0
    action = sys.argv[1]
    if length == 2: # 一个参数
        two_param(action)
    elif length == 3: # 两个参数
        sdk = sys.argv[2]
        thr_param(action, sdk)
    elif length == 4: # 三个参数
        sdk = sys.argv[2]
        version = sys.argv[3]
        four_param(action, sdk, version)
        
def init():
    ''' 初始化目录结构 并返回用户目录的绝对路径 '''
    user = os.getcwd()
    user = user.split('/')
    user = '/'+user[1]+'/'+user[2]
    # print(user+"/.mythsdk")
    if not os.path.isdir(user+"/.mythsdk"):
        print("初始化目录")
        subprocess.call("mkdir ~/.mythsdk", shell=True)
        subprocess.call("mkdir ~/.mythsdk/zip & mkdir ~/.mythsdk/sdk", shell=True)
    return user

def main():
    init()
    readparam()
    
main()

