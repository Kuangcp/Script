import os
import sys
import json
import getpass
import subprocess

# json_url = " https://raw.githubusercontent.com/Kuangcp/Script/master/python/mythsdk/config.json"
# 默认的配置文件的地址
json_url = " http://git.oschina.net/kcp1104/script/raw/master/python/mythsdk/config.json"
# 存放了sdk的七牛云的域名
cloud_url = None
## 这个github 上 sdk 只有几个，大多数没有
github_url = "https://raw.githubusercontent.com/kuangcp/Apps/master/zip/"

'''
2017-08-30 16:19:16
    配置sdk的环境，因为用sdkman用的很不爽，就用这个来做到大致的功能，自动下载的话，用的github网太慢体验不好
        1.自动配置环境变量  
        2.更改当前的sdk版本 
        3.列出所以可以下载的sdk 
        4.自动下载指定版本的sdk 
2017-10-02 21:07:02
    新添加了几个sdk，优化了代码规范
2017-11-12 12:50:27
    增加域名解析，编辑主页
'''

def shell(cmd):
    subprocess.call(cmd, shell=True)

def loadconfig():
    ''' 加载配置文件，如果没有就去默认的URL下载'''
    jsonfile = init()+'/.mythsdk/config.json'
    if not os.path.exists(jsonfile):
        print("下载配置文件")
        shell("curl -o "+jsonfile+json_url)
    data = json.load(open(jsonfile))
    return data

def create_index():
    data = loadconfig()
    sdks = data["sdks"]
    for sdk in sdks:
        print("<h3>", sdk, "</h3>")
        for version in sdks[sdk]:
            print("<a href='/"+sdk+"-"+version+".zip'>"+sdk+"-"+version+"</a><br/>")

def list_all(sdk=None):
    ''' 列出所有sdk以及版本号 '''
    # if sdk == None:
    print("="*70)
    print("\033[1;33mAll can install SDK list:\n       \033[1;32mused is green     \033[1;35minstalled is purple     \033[0maviable is white")
    print("="*70)
    data = loadconfig()
    sdks = data["sdks"]
    result_list = []
    root_path = init()+"/.mythsdk/sdk"
    for one in sdks:
        result = ''
        if sdk!=None and sdk!=one:
                continue
        # print(""+one+":")
        result = result + "\033[1;33m>>\033[1;36m"+one+"\033[0m\n"
        version = data["sdks"][one]
        count = 0
        for ver in version:
            count += 1
            if os.path.exists(root_path+"/"+one+"/"+ver+"/bin/current"):
                # print("\033[1;32m    "+ver+"\033[0m", end="")
                result = result+"\033[1;32m    "+ver+"\033[0m  "
            elif os.path.exists(root_path+"/"+one+"/"+ver):
                # print("\033[1;35m    "+ver+"\033[0m", end="")
                result = result +"\033[1;35m    "+ver+"\033[0m  "
            else:
                ver = "    "+ver+"  "
                # print(ver, end="")
                result = result + ver
                if count%8 == 7 :
                    # print("")
                    result = result +"\n"
        # print("\n")
        result = result + "\n"
        result_list.append(result)
    result_list.sort()
    for result in result_list:
        print(result)
# TODO 还没开始写
def auto():
    ''' 使用规定的目录结构放置zip包 自动化配置sdk环境''' 
    current = os.getcwd()
    print(current)

def download(url, sdk, version):
    ''' 只是负责将URL对应的文件下载到默认目录'''
    if not os.path.isdir(init()+"/.mythsdk/zip/"+sdk):
        shell("mkdir ~/.mythsdk/zip/"+sdk)
    if not os.path.exists(init()+"/.mythsdk/zip/"+sdk+"/"+version+".zip"):
        cmd = "curl  -o ~/.mythsdk/zip/"+sdk+"/"+version+".zip "+url
        shell(cmd)
        print("下载完成" )
    else:
        print(sdk+" "+version+" 已经安装 !")
        sys.exit(0)

def download_fromgit(sdk, version):
    ''' 使用github 作为存储 '''
    url = github_url+sdk+"/"+sdk+"-"+version+".zip"
    download(url, sdk, version)

def down_fromqiniu(sdk, version):
    ''' 使用七牛云作为存储 '''
    config_md = init()+"/.mythsdk/config.md"
    global cloud_url
    if os.path.exists(config_md):
        cloud_url = open(config_md).readline().rstrip()
    if cloud_url == None:
        print("请配置七牛的URL 命令格式： q URL")
        return 0
    url = cloud_url+sdk+"-"+version+".zip"
    download(url, sdk, version)
    

def unzip_file(sdk, version=None):
    ''' 将下载的zip包解压到默认目录'''
    if not os.path.isdir(init()+"/.mythsdk/sdk/"+sdk):
        shell("mkdir ~/.mythsdk/sdk/"+sdk)
    if not os.path.isdir(init()+"/.mythsdk/sdk/"+sdk+"/"+version):
        unzip = "unzip -q ~/.mythsdk/zip/"+sdk+"/"+version+".zip -d ~/.mythsdk/sdk/"+sdk
        shell(unzip)
        print("解压完成")
    # 如果软链接不存在就新建，并设置环境变量，如果有就说明已经安装过一个版本，就只要解压就行了
    if not os.path.exists(init()+"/.mythsdk/sdk/"+sdk+"/current"):
        print("建立软链接")
        shell("ln -s ~/.mythsdk/sdk/"+sdk+"/"+version+" ~/.mythsdk/sdk/"+sdk+"/current")
        shell("touch ~/.mythsdk/sdk/"+sdk+"/"+version+"/bin/current") # 建立当前使用的标记
        config(sdk)
    else:
        choose = input("需要将"+sdk+" "+version+"设为默认吗? y/n ")
        if choose == 'y':
            change(sdk, version)

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
        if version not in data["sdks"][sdk]:
            print("没有该版本! \n收纳的sdk:")
            list_all()
            return 0 
    if version == None:
        version = data["sdks"][sdk][-1]
    down_fromqiniu(sdk, version)
    # download_fromgit(sdk, version)
    unzip_file(sdk, version)

# TODO 并未开始写
def handle():
    ''' 手动添加bin目录来配置sdk '''
    path = input("bin目录的绝对路径")
    print(path)

def check(sdk, version):
    ''' 检查命令中的 sdk 版本 '''
    datas = loadconfig()
    if not sdk in datas["sdks"]:
        print("仓库没有安装该sdk"+sdk)
        return 0 
    ed_version = os.listdir(init()+"/.mythsdk/sdk/"+sdk)

    if not version in ed_version:
        print("仓库没有安装该 sdk"+sdk+"的版本")
        return 0
    return 1

def change(sdk, version):
    '''更改sdk版本 只要更改软链接就可以了'''
    if check(sdk, version) == 0 :
        return 0
    if os.path.exists(init()+"/.mythsdk/sdk/"+sdk+"/current"):
        shell("rm ~/.mythsdk/sdk/"+sdk+"/current/bin/current")
        shell("rm -rf ~/.mythsdk/sdk/"+sdk+"/current")
        shell("ln -s ~/.mythsdk/sdk/"+sdk+"/"+version+" ~/.mythsdk/sdk/"+sdk+"/current")
        shell("touch ~/.mythsdk/sdk/"+sdk+"/current/bin/current")
    else:
        print("\n该SDK "+sdk+" 没有安装任何版本，切换失败 \n    安装请使用命令 python mythsdk.py i "+sdk+" <version>\n")
    
def help():
    print('''python \033[1;32m myth.py <params> \033[0m：
    \033[1;32m l|list <sdk>： \033[0m
        输出所有可安装的sdk,指定则输出指定sdk信息
    \033[1;32m h|help :\033[0m
        帮助信息
    \033[1;32m q domain :\033[0m
        配置存放了sdk的七牛云地址 http://xxx/
    \033[1;32m up|update :\033[0m
        更新配置文件，即sdk库
    \033[1;32m u|use sdk version :\033[0m
        使用已安装的指定sdk的版本
    \033[1;32m i|install sdk <version> : \033[0m
        安装指定版本，不指定则安装最新版
    ''')

def update_config():
    ''' 升级配置文件 '''
    jsonfile = init()+'/.mythsdk/config.json'
    print("更新配置文件")
    shell("rm "+jsonfile)
    shell("curl -o "+jsonfile+json_url)


def one_param(action):
    ''' 一个参数 只有操作的动作'''
    if action == 'list' or action == 'l':
        list_all()
    if action == "help" or action == 'h':
        help()
    if action == "update" or action =='up':
        update_config()
    if action == "index":
        create_index()

def two_param(action, sdk):
    ''' 两个参数 操作 sdk'''
    if action == 'install' or action == 'i':
        install(sdk)
    if action == 'list' or action == 'l':
        list_all(sdk)
    if action == 'q':
        shell("echo '"+sdk+"'> "+init()+"/.mythsdk/config.md")

def tri_param(action, sdk, version):
    ''' 三个参数 操作 sdk 版本'''
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
        one_param(action)
    elif length == 3: # 两个参数
        sdk = sys.argv[2]
        two_param(action, sdk)
    elif length == 4: # 三个参数
        sdk = sys.argv[2]
        version = sys.argv[3]
        tri_param(action, sdk, version)
        
def init():
    ''' 初始化目录结构 并返回用户目录的绝对路径 '''
    user = getpass.getuser()
    if user == 'root':
        user = '/'+user
    else:
        user = '/home/'+user
    if not os.path.isdir(user+"/.mythsdk"):
        print("初始化目录")
        subprocess.call("mkdir ~/.mythsdk", shell=True)
        subprocess.call("mkdir ~/.mythsdk/zip & mkdir ~/.mythsdk/sdk", shell=True)
    return user

def main():
    init()
    readparam()
    
main()