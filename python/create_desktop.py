import sys
import os
'''
    创建一个简单的desktop文件
    :name 新建文件
    [name 复制过去
'''

params = sys.argv
for param in params:
    if param == '-h':
        print('\n   -h 帮助，：文件名 [文件名 复制过去   文件名没有后缀')
    if param.startswith(':'):
        filename=param[1:]
        # filename = params[1]
        path = os.getcwd()
        # types = params[2]
        print('创建文件',filename+'.desktop')
        with open(filename+'.desktop', 'w+') as files:
            files.write('[Desktop Entry]\nCategories=Development;\n')
            files.write('Exec='+path+'\nIcon='+path+'\nName=\n')
            files.write('Terminal=false\nType=Application\n')

    if param.startswith('['):
        filename = param[1:]
        path = os.getcwd()
        origin = open(path+'/'+filename+'.desktop')
        target = open('/usr/share/applications/'+filename+'.desktop','w+')
        for line in origin:
            target.write(line)


#     files.write(
# '''[Desktop Entry]
# Categories = Development;
# Exec=
# Icon=
# Name=
# Terminal=false
# Type=Application
# ''')