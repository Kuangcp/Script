from datetime import date, timedelta
from random import randint
from time import sleep
import sys
import subprocess
import os
# 参考自 https://github.com/angusshire/greenhat  吐槽下里面的Tab符


'''
    运行在 python3.5
    参数1 必须  从输入的日期的开始往前总共多少天(含输入的日期)
    参数2 缺省为今天 , 输入的日期 日期有错误?不是当前,而是前一天(原因是 0点的问题,0点github认为是前一天 0点过1秒才算今天.....)
    参数3 缺省为1 , 每天的提交量

    最终运行的命令, 如果要用shell重写, 时间的计算就是问题了
    echo 'Mon Feb 12 12:00:00 2018  -0400101291' > realwork.txt;
    git add realwork.txt;
    GIT_AUTHOR_DATE='Mon Feb 12 12:00:00 2018  -0400' GIT_COMMITTER_DATE='Mon Feb 12 12:00:00 2018  -0400' git commit -m 'update';

'''
# 修改日期关键在这条命令 GIT_AUTHOR_DATE='Sun Feb 14 00:00:00 2016' GIT_COMMITTER_DATE='Sun Feb 14 00:00:00 2016' git commit -m 'update';


def get_date_string(days, startdate):
    d = startdate - timedelta(days=days)
    rtn = d.strftime("%a %b %d %X %Y %z -0400")
    return rtn.replace('00:00:00', '12:00:00')
   
# 入参数组,主要是三个参数 days date num 
def main(argv):
    print(argv)
    if len(argv) < 1 :
        print("Error: Bad input.")
        sys.exit(1)
    days = int(argv[0])-1 
    num = 1 # 提交的数量
    if len(argv) == 1:
        startdate = date.today()
    if len(argv) >= 2:
        startdate = date(int(argv[1][0:4]), int(argv[1][5:7]), int(argv[1][8:10]))
    if len(argv) > 2: 
        num = int(argv[2])
        
    i = 0
    while i <= days:
        curdate = get_date_string(i, startdate)
        for commit in range(0, num):
            #subprocess.call("echo '" + curdate + str(randint(0, 1000000)) +"' > realwork.txt; git add realwork.txt; GIT_AUTHOR_DATE='" + curdate + "' GIT_COMMITTER_DATE='" + curdate + "' git commit -m ' update "+curdate+"';git push", shell=True)
            print(curdate)
            sleep(.5)
        i += 1

# 生成love图案
# 判断星期几, 开始以原点的偏移来作图
def love(argv):
    date = str(argv[0])+'-12-31'
    #print(date)
    list = [1, date, 3]
    main(list)
    
    # 开始构建图案
    
    
#main(sys.argv[1:])
# 输入年份即可
love(sys.argv[1:])
