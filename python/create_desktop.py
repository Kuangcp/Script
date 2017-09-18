import sys
import os
import subprocess
'''
    创建一个简单的desktop文件
    :name 新建文件
    [name 复制过去
'''

params = sys.argv
param = params[1]
if param == '-h':
    print('''    -h        帮助
    add name  根据当前目录创建一个name.desktop文件，自行修改启动以及图标目录
    cp name   复制到启动菜单栏里 ''')

if param.startswith('add'):
    filename=params[2]
    path = os.getcwd()
    # types = params[2]
    print('创建文件',filename+'.desktop')
    with open(filename+'.desktop', 'w+') as files:
        files.write('[Desktop Entry]\nCategories=Development;\n')
        files.write('Exec='+path+'\nIcon='+path+'\nName='+filename+'\n')
        files.write('Terminal=false\nType=Application\n')

if param.startswith('cp'):
    filename = params[2]
    path = os.getcwd()
    subprocess.call('sudo cp '+path+'/'+filename+'.desktop /usr/share/applications/'+filename+'.desktop', shell=True)

#     files.write(
# '''[Desktop Entry]
# Categories = Development;
# Exec=
# Icon=
# Name=
# Terminal=false
# Type=Application
# ''')
