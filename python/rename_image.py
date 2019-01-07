import os
import random
import subprocess
import getopt
import sys


# 配置实用脚本 TODO 重构优化

url='![](/'
list = []
# 图片目标目录
image_folder = "Back"
# 索引目录
index_folder = 'Indexs'
# 随机种子
random_alpt = 17

######################################

'''
    对文件进行操作，读取图片，生成目录输出
'''
# ”“” 将目录下的文件和文件夹排序  判断路径，要加上头
def sort_folder_files(folder_head, path):
    # 问题在这里,这里的排序是 UTF8排序的
    list = os.listdir(path)
    list.sort()
    result = []
    files = []
    folder = []
    for member in list:
        if os.path.isdir(path+'/'+member):
            folder.append(member)
        else:
            files.append(member)
    #print("文件夹",folder)
    #print("文件",files)
    if folder_head:
        result = folder+files
    else:
        result = files+folder
    return result
    

# 递归读取目录,把文件的路径装载进list
def read_folder(path):
    list.append('$'+path) # 标记文件夹
    files = sort_folder_files(False,path)
    #count = 0
    for file in files:
        #count += 1
        if os.path.isdir(path+'/'+file):
            read_folder(path+'/'+file)
        else:
            list.append(path+'/'+file)
    #print('-'*50,path ,'当前目录是',' 下有 ',count)
    return list
            
# 如果没有文件夹，应该创建文件夹，然后依次添加到对应的md文件中 index以及分页
def out_file(path, index_folder):
    list.clear()
    # 执行完这个函数就得到了所有图片的集合
    read_folder(path)
    count = 0
    print('重命名后文件数量',len(list))
    
    for line in list :
        count += 1
        #print('*',line)
        # 如果是目录，就进去，新建一系列文件
        if line.startswith('$'):
            folder = line[len(path)+1:]
            #print('目录是',line,folder)
            # 如果没有这个目录，就新建
            if not os.path.isdir(index_folder+'/'+folder):
                os.makedirs(index_folder+'/'+folder)
            # 有了目录后，就新建总索引文件，将计数归零，因为是进入了一个新目录
            index = open(index_folder+'/'+folder+'/INDEX.md','w+')
            readme = open(index_folder+'/'+folder+'/README.md','w+')
            readme.write('- [All](/'+index_folder+folder+'/INDEX.md)\n')
            count = 0

        # 写入文件的每一行 图片
        content = ''+url+line+')\n'
        index.write(content)
        # 写入单个文件
        if(count % 37 == 0):
            # 将分页文件添加到README
            readme.write('- ['+str(count)+'](/'+index_folder+folder+'/page_'+str(count)+'.md)\n')
            page = open(index_folder+'/'+folder+'/page_'+str(count)+'.md','w+')
        page.write(content)


#      重命名策略  

# 比较文件名的大小,取大的
def compare_num(bigger, name):
    if not name.startswith('$'):
        result = os.path.split(name)
        # 分成文件名和后缀
        files = os.path.splitext(result[1])
        file_value = 0
        try:
            file_value = int(files[0])
        except ValueError:
            print('遇到新文件 : ', files[0])
        else:
            if bigger < file_value:
                bigger = file_value
    return bigger

# 得到文件列表中 文件名最大的那个 数值
def get_bigger(list):
    bigger = 0
    for name in list:
        bigger = compare_num(bigger, name)
    return bigger
      
# 只是重命名新文件
def rename(path):
    read_folder(path)
    print('原有文件数量',len(list))
    # 得到最大标号 以及长度 判断依据就是长度相同,是个数值,且开头相同,就不是新加入的文件
    bigger = get_bigger(list)
    name_length = len(str(bigger))
    print('文件名称最大值:',bigger, '长度:',name_length)
    for line in list:
        if line.startswith('$'):
            continue
        result = os.path.split(line)# 分成路径和文件
        files = os.path.splitext(result[1])# 分成文件名和后缀
        is_num = False
        try:
            int(files[0])
            is_num = True
        except ValueError:
            #print('遇到新文件 : ', files[0])
            pass
        
        # 如果长度不对, 不是数值, 若开头前三位不一致
        if (not len(files[0]) == name_length) or (not is_num) or (not str(bigger)[0:3] == files[0][0:3]):
            bigger += 1
            target = result[0]+'/'+str(bigger)+files[1]
            print(line+'--->'+target)
            os.rename(line, target)
            
# 全部文件重命名
def init_rename(path, random_alpt):
    random_alpt += random.randint(3, 57)
    sed = random.randint(4, 7)
    # 得到所有图片的集合
    read_folder(path)
    # 存在 重复然后覆盖的情况,所以就需要每次随机?
    count = 10 ** sed
    print('原有数量',len(list))
    for line in list:
        count += 1
        if line.startswith('$'):
            pass
        else:
            result = os.path.split(line)
            files = os.path.splitext(result[1])
            target = result[0]+'/'+str(random_alpt)+str(count)+files[1]
            print(line +'--->'+target)
            os.rename(line, target)


###########################################################################################################
'''
    创建index html目录
'''

def out_index(path, index_folder):
    print(path)
    lists = read_folder(path)
    index = None
    root = open('index.html','w+')
    root.write('<html><title></title><body>')
    # 当目录只有文件，要追加最后一行
    folder_num = 1
    for image in lists:
        if image.startswith('$'):
            folder_num += 1
            folder = image[len(path)+1:]
            target = index_folder+folder
            root.write('<li><a href=\"'+target+'\">'+target+'</a></li>\n')
            if not os.path.isdir(target):
                os.makedirs(target)
            if not index == None:
                index.write('</body></html>')
            index = open(target+'/index.html','w+')
            index.write('<html><title>'+target+'</title><body>')
            continue
        
        index.write('<img src=/img/'+image+' style=\"float:left\"/>\n')
    if folder_num < 3:
        index.write('</body></html>')
    root.write('</body></html>')
    print('生成索引文件成功')


###########################################################################################################


'''
    使用之前最好是现将Indexs目录删掉,再生成
    最后的解决方法是使用大数做头,然后对文件名进行判断,不是这个标准的就重命名,就不会对原有文件进行影响,但是这样就会导致文件名不连续,显然这影响不大,但是程序计算要先得到最大的号,缓存起来才可以, 初始化使用file.py 脚本,之后的使用这个脚本,或许应该整合下
    -n 选项重新生成命名方式, 不加就是修改新文件名字
'''

def delete():
     # 得到当前目录,删除原有索引文件夹
    current = os.getcwd()
    subprocess.call('rm -rf '+current+'/Indexs/ && rm index.html', shell=True)

def main():  
    image = image_folder
    # 处理参数 缺省是只修改新加入文件 -n 就全部重新命名  -i 输出index
    opts, args = getopt.getopt(sys.argv[1:], "nihp:d")
    init_flag = False
    index_flag = False
    for op,value in opts:
        if op == "-n":
            init_flag = True
            break
        if op == "-d":
            print("删除所有索引文件")
            delete()
            return 0
        if op == "-i":
            index_flag = True
            break
        if op == "-h":
            print('''
            -h      帮助 
            -n      使用新的命名顺序
            -i      生成html文件 以及md文件
            -d      删除所有索引文件
            -p      指定图片目录
            缺省      对新加入文件的重命名''')
            sys.exit(0)
        if op == "-p":
            print("使用定义图片目录", value)
            image = value
        
  
    # 全部重命名还是部分命名
    if init_flag:
        init_rename(image, random_alpt)
    else:
        rename(image)
        
    if index_flag:
        delete()
        out_index(image, index_folder)
        
        # 都更新md索引
        out_file(image, index_folder)
    

main()
