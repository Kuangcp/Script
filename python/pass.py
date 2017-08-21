import zipfile
import os

path = '/home/kcp/Documents/DocFiles/12.zip'

def try_extract(path, password):
    print(path, password)
    if path[-4:] == '.zip':
        zip = zipfile.ZipFile(path, 'r', zipfile.zlib.DEFLATED)
        try:
            zip.extractall(path = '/home/kcp/test/', members=zip.namelist(), pwd=password)
            print('--success:'+ password)
            zip.close()
            return True
        except:
            print("Error")
            pass
    print("?")


try_extract(path, '1234')

