import os
import sys
import time
import json
import shlex
import datetime
import subprocess

'''
    this script can management sdk 
'''

def execute_command(cmdstring, cwd=None, timeout=None, shell=False):
    if shell:
        cmdstring_list = cmdstring
    else:
        cmdstring_list = shlex.split(cmdstring)
    if timeout:
        end_time = datetime.datetime.now() + datetime.timedelta(seconds=timeout)
    sub = subprocess.Popen(cmdstring_list, cwd=cwd, stdin=subprocess.PIPE,shell=shell,bufsize=4096)
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
        print("Download config file ...")
        shell("curl -o "+jsonfile+" https://raw.githubusercontent.com/Kuangcp/Script/master/python/mythsdk/config.json")

    data = json.load(open(jsonfile))
    return data
                
def list_all(sdk=None):
    ''' list all avaliable sdk '''
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
        for ver in version:
            if os.path.exists(root_path+"/"+one+"/"+ver+"/bin/current"):
                print("\033[1;32m    "+ver+"\033[0m")
            elif os.path.exists(root_path+"/"+one+"/"+ver):
                print("\033[1;35m    "+ver+"\033[0m")
            else:
                print("    "+ver)
        
def auto():
    ''' auto installed by target dict ''' 
    current = os.getcwd()
    print(current)

def download(url, sdk, version):
    if not os.path.isdir(init()+"/.mythsdk/zip/"+sdk):
        shell("mkdir ~/.mythsdk/zip/"+sdk)
    if not os.path.exists(init()+"/.mythsdk/zip/"+sdk+"/"+version+".zip"):
        cmd = "curl  -o ~/.mythsdk/zip/"+sdk+"/"+version+".zip "+url
        print("Start download: " + cmd)
        shell(cmd)
        print("Download finished!" )

def download_fromgit(sdk, version):
    url = "https://raw.githubusercontent.com/kuangcp/Apps/master/zip/"+sdk+"/"+sdk+"-"+version+".zip"
    download(url, sdk, version)

def down_fromqiniu(sdk, version):
    url = "http://oscenptok.bkt.clouddn.com/"+sdk+"-"+version+".zip"
    download(url, sdk, version)

def unzip_file(sdk, version=None):
    ''' unzip file to target '''
    if not os.path.isdir(init()+"/.mythsdk/sdk/"+sdk):
        shell("mkdir ~/.mythsdk/sdk/"+sdk)
    if not os.path.isdir(init()+"/.mythsdk/sdk/"+sdk+"/"+version):
        unzip = "unzip ~/.mythsdk/zip/"+sdk+"/"+version+".zip -d ~/.mythsdk/sdk/"+sdk
        shell(unzip)
    if not os.path.exists(init()+"/.mythsdk/sdk/"+sdk+"/current"):
        print("establish link ...")
        shell("ln -s ~/.mythsdk/sdk/"+sdk+"/"+version+" ~/.mythsdk/sdk/"+sdk+"/current")
        shell("touch ~/.mythsdk/sdk/"+sdk+"/"+version+"/bin/current")
        config(sdk)
    

def config(sdk):
    if sdk == 'java':
        shell("echo '\n "+sdk.upper()+"_HOME=~/.mythsdk/sdk/"+sdk+"/current' >> ~/.bash_aliases")
        ENV = '''\nexport JRE_HOME=${JAVA_HOME}/jre\nexport CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib\nexport PATH=${JAVA_HOME}/bin:$PATH'''
        shell("echo '"+ENV+"' >> ~/.bash_aliases")
    else:
        shell("echo '\n"+sdk.upper()+"_HOME=~/.mythsdk/sdk/"+sdk+"/current' >> ~/.bash_aliases")
        shell("echo 'export PATH=$PATH:$"+sdk.upper()+"_HOME/bin' >> ~/.bash_aliases")
    refresh()

def refresh():
    print("\033[1;33mRun  \033[1;35msource ~/.bashrc \033[1;33mcan used just now or restart terminal \033[0m")
    shell(". ~/.bashrc")

def install(sdk, version=None):
    data = loadconfig()
    sdks = data['sdks']
    if not sdk in sdks:
        print("haven't this sdk! \navaliable sdk:")
        list_all()
        return 0
    if version != None:
        if version not in data["sdks"][sdk]:
            print("haven't this version ! \navaliable sdk:")
            list_all()
            return 0 
    if version == None:
        version = data["sdks"][sdk][-1]
    down_fromqiniu(sdk, version)
    unzip_file(sdk, version)

def handle():
    path = input("input bin realpath")
    print(path)

def change(sdk, version):
    datas = loadconfig()
    if version in datas["sdks"][sdk]:
        print("Repository haven't this sdk version!")
        return 0
    if os.path.exists(init()+"/.mythsdk/sdk/"+sdk+"/current") :
        shell("rm ~/.mythsdk/sdk/"+sdk+"/current/bin/current")
        shell("rm -rf ~/.mythsdk/sdk/"+sdk+"/current")
        shell("ln -s ~/.mythsdk/sdk/"+sdk+"/"+version+" ~/.mythsdk/sdk/"+sdk+"/current")
        shell("touch ~/.mythsdk/sdk/"+sdk+"/current/bin/current")
    else:
        print("\nthis SDK "+sdk+" doesn't install any version，turn version faild \n    install please use this commander: python mythsdk.py i "+sdk+" <version>\n")
    
def help():
    print('''python \033[1;33m myth.py <params>：
    l|list <sdk>： \033[0m
        show all avaliable sdk , if specified sdk then show that sdk infomation 
    \033[1;33mu|use sdk version :\033[0m
        use installed specified sdk version 
    \033[1;33mi|install sdk <version> : \033[0m
        install specified version。otherwise install lastst version ''')
def update_config():
    jsonfile = init()+'/.mythsdk/config.json'
    print("Update config file get more sdk")
    shell("rm "+jsonfile)
    shell("curl -o "+jsonfile+" https://raw.githubusercontent.com/Kuangcp/Script/master/python/mythsdk/config.json")

def two_param(action):
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
    length = len(sys.argv)
    if length < 2:
        print("Please input param !!!")
        help()
        return 0
    action = sys.argv[1]
    if length == 2: 
        two_param(action)
    elif length == 3: 
        sdk = sys.argv[2]
        thr_param(action, sdk)
    elif length == 4: 
        sdk = sys.argv[2]
        version = sys.argv[3]
        four_param(action, sdk, version)
        
def init():
    user = os.getcwd()
    user = user.split('/')
    user = '/'+user[1]+'/'+user[2]
    if not os.path.isdir(user+"/.mythsdk"):
        print("init root directory ")
        subprocess.call("mkdir ~/.mythsdk", shell=True)
        subprocess.call("mkdir ~/.mythsdk/zip & mkdir ~/.mythsdk/sdk", shell=True)
    return user

def main():
    init()
    readparam()
    
main()

