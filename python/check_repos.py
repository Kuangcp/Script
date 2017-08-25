import sys
import subprocess
import os


# 执行命令,如果仓库没有变动就不输出
def command(cmd, content_line, count):
    result=[]
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

def hang(count,name):
    print('\033[1;35;40m')
    # print("-"*50,count,"\n"+'-'*10,name)
    print('-'*4,name.rstrip(),count)
    print('\033[1;31;0m')

def print_info(line,count):
    path = line.split("#")[0]
    name = line.split("#")[1]
    command('cd '+path+' && git status', line, count)

def append_line(path):
    repos_path = input("请输入项目地址 : ")
    comments = input("请输入项目注释 : ")
    with open(path, 'a') as config:
        config.write(repos_path+" # "+comments)
    
def main():
    #if len(sys.argv) <= 1:
        #return 0
        
    # 如果使用相对路径，是相对于当前终端的路径的
    path = '/home/kcp/Application/Script/python/config/repos.md'
    for param in sys.argv:
        if param == '-h':
            print('''
    -h      帮助说明
    -a      添加Git Repos目录
    -f      打开配置文件,方便修改
    -i      图片仓库：在当前目录方便得到图片URL
            ''')
            return 0
        if param == '-a':
            print("添加仓库")
            append_line(path)
            return 0
        if param == '-f':
            subprocess.call("gedit ~/Application/Script/python/config/repos.md",shell=True)
            return 0
        if param == '-i':
            # 将当前图片仓库的目录转化成仓库的URL
            image_path = os.getcwd()
            temp = image_path.split('ImageRepo')
            if len(temp) > 1:
                #print(temp[1])
                image_path = temp[1]+'\n'
            else:
                print("请在图片仓库运行该命令")
                return 0 
            URL = '\nhttps://raw.githubusercontent.com/Kuangcp/ImageRepos/master'
            print(URL+image_path)
            return 0
    
    with open(path, encoding='UTF-8') as config:
        paths = config.readlines()
    #print(paths)
    # 主要部分
    count = 0
    for path in paths:    
        count = count+1
        if path.startswith('/'):
            print_info(path,count)
    #print('\033[1;33;40m')
    #print('-'*70)
    #print('\033[1;31;0m')
main()
