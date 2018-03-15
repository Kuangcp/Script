import sys
import subprocess
import os

# 依赖于一个配置文件格式如下: 绝对路径#注释
# 执行命令,如果仓库没有变动就不输出
def command(cmd, content_line, count):
    # 执行命令，后面的都是处理输出内容
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return p.stdout.readlines()

# 输出标题 计数， 配置文件的一行
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
    # name = line.split("#")[1]
    result=[]
    commands = 'cd '+path+' && git status'
    for element in command(commands, line, count):
        element = element.decode()
        if(element != "无文件要提交，干净的工作区\n"):
            if element.count("使用") < 1 and element.count("变更") < 1:
                result.append(element.rstrip())
        else:
            return 0 # 如果git仓库没有变动就直接退出，不输出了   
    # 输出所有结果 以及仓库信息
    hang(count, line)
    for ele in result:
        print("",ele)

def push_repo(line, count):
    ''' 推送仓库中的commit '''
    path = line.split("#")[0]
    commands = 'cd '+path+' && git status'
    flag = False
    for element in command(commands, line, count):
        element = element.decode()
        if element.count('领先') > 0:
            flag = True
    if flag:
        # print('cd '+path+' && git push\n',line , count)
        commands = 'cd '+path+' && git push'
        for temp in command(commands,line , count):
            temp = temp.decode()
            print(temp)

def append_line(path, current=False):
    repos_path = os.getcwd()
    if not current:
         repos_path = input("请输入项目地址 : ")
    comments = input("请输入项目注释 : ")
    print(repos_path,' # ', comments)
    with open(path, 'a') as config:
        config.write("\n"+repos_path+" # "+comments)

def show_help():
    print('''
    -h      帮助说明
    -l 		列出所有的仓库
    -a      添加Repos目录以及注释
    -ac     添加当前目录作为Repos，输入注释即可
    -f      打开配置文件,方便修改
    -p      推送所有的仓库到远程
    -i <image> 图片仓库：在当前目录方便得到图片URL
    ''')

def out_image():
    '''将当前图片仓库的目录转化成仓库的URL '''
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

def read_file(path, do):
    with open(path, encoding='UTF-8') as config:
        paths = config.readlines()
    #print(paths)
    count = 0
    for path in paths:    
        count = count+1
        if path.startswith('/'):
            do(path, count)
        
# 我希望的是按位置来确定参数。
def read_param(path):
    ''' 返回 0中断 1继续'''
    for param in sys.argv:
        if param == '-h':
            show_help()
            return 0
        if param == '-l':
        	paths = []
        	with open(path, encoding='UTF-8') as config:
        		paths = config.readlines()
        		for line in paths:
	        		if line.startswith('/'):
	        			print(line, end='')
        	return 0
        if param == '-a':
            print("添加仓库:")
            append_line(path)
            return 0
        if param == '-ac':
            print("添加当前目录作为仓库:")
            append_line(path, True)
            return 0
        if param == '-p':
            print("推送所有代码:")
            read_file(path, push_repo)
            return 0 
        if param == '-f':
            subprocess.call("gedit ~/Application/Script/python/config/repos.md",shell=True)
            return 0 
        if param == '-i':
            print("得到图片仓库对应图片的URL")
            out_image()
            return 0
    # 如果没有参数就执行这个，阅读仓库状态
    read_file(path, deal_repo)



def main():
    # 如果使用相对路径，是相对于当前终端的路径的
    path = '/home/kcp/Application/Script/python/config/repos.md'
    read_param(path)

main()

