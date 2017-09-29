import sys
import subprocess
import os

# 应该使用shell来写的

# 执行命令,如果仓库没有变动就不输出
def command(cmd, content_line, count):
    result=[]
    # 执行命令，后面的都是处理输出内容
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    
    for line in p.stdout.readlines():
        line = line.decode()
        if(line != "无文件要提交，干净的工作区\n"):
            if line.count("使用") < 1 and line.count("变更") < 1:
                result.append(line.rstrip())
        else:
            return 0 # 如果git仓库没有变动就直接退出，不输出了   
    # 输出所有结果 以及仓库信息
    hang(count, content_line)
    for re in result:
        print("",re)
    
    return result

# 输出标题
def hang(count, name):
    black = '30'
    yellow = '33'
    blue = '34'
    purple = '35'
    cyan = '36'

    pathcolor = '\033[0;'+purple+'m'
    titlecolor = '\033[1;'+purple+'m'
    reback = '\033[0m'
    space = 50
    result = name.split("#")
    path = result[0].rstrip()
    title = result[1].rstrip()
    print(pathcolor, path, ' '*(space-len(path)), titlecolor,count, title, reback)

def deal_repo(line, count):
    ''' line 是配置文件的每一行 查看git仓库的状态 以及提交未提交的仓库 '''    
    path = line.split("#")[0]
    name = line.split("#")[1]
    return command('cd '+path+' && git status', line, count)

def push_repo(line, count):
    ''' 推送仓库中的commit '''
    path = line.split("#")[0]
    status = deal_repo(line, count)
    # print(status)
    if status != 0:
        # repo = status['dir']
        flag = False
        for value in status:
            if value.count('领先') > 0:
                flag = True
            # print(value, flag)
    
        if flag:
            command('cd '+path+' && git push',line , count)

def append_line(path):
    repos_path = input("请输入项目地址 : ")
    comments = input("请输入项目注释 : ")
    with open(path, 'a') as config:
        config.write(repos_path+" # "+comments)
    
def exit():
    sys.exit(0)

def read_param(path):
    ''' 返回 0中断 1继续'''
    for param in sys.argv:
        if param == '-h':
            print('''
    -h      帮助说明
    -a      添加Git Repos目录
    -f      打开配置文件,方便修改
    -i <image> 图片仓库：在当前目录方便得到图片URL
            ''')
            exit()
        if param == '-a':
            print("添加仓库")
            append_line(path)
            exit()
        if param == '-p':
            print("提交代码")
            read_file(path, push_repo)
            exit()
        if param == '-f':
            subprocess.call("gedit ~/Application/Script/python/config/repos.md",shell=True)
            exit()
        # 将当前图片仓库的目录转化成仓库的URL
        if param == '-i':
            image_path = os.getcwd()
            temp = image_path.split('ImageRepo')
            if len(temp) > 1:
                #print(temp[1])
                image_path = temp[1]
            else:
                print("请在图片仓库运行该命令")
                exit() 
            URL = '\nhttps://raw.githubusercontent.com/Kuangcp/ImageRepos/master'
            if len(sys.argv) == 3:
                image_path = image_path+"/"+sys.argv[2] 
            print(URL+image_path+"\n")
            exit()

def read_file(path, do):
    with open(path, encoding='UTF-8') as config:
        paths = config.readlines()
    #print(paths)
    count = 0
    for path in paths:    
        count = count+1
        if path.startswith('/'):
            do(path, count)
def read_status(path):
    # 主要部分 查看仓库的缓存状态
    # with open(path, encoding='UTF-8') as config:
    #     paths = config.readlines()
    # #print(paths)
    # count = 0
    # for path in paths:    
    #     count = count+1
    #     if path.startswith('/'):
    #         deal_repo(path, count)
    read_file(path, deal_repo)

def main():
    # 如果使用相对路径，是相对于当前终端的路径的
    path = '/home/kcp/Application/Script/python/config/repos.md'
    read_param(path)
    read_status(path)

main()

    
    #print('\033[1;33;40m')
    #print('-'*70)
    #print('\033[1;31;0m')
