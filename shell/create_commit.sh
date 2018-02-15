#!/bin/dash

get_file_url(){
    echo "开始寻找项目根目录..."
    current_path=`pwd`
    for i in `seq 10` # 限制最多往上找10级目录
    do
        result=`ls -al | grep d.*git` # 搜索d开头的结果,也就是文件夹
        if [ "$result"z = "z" ]; then 
            cd ..
        else 
            break
        fi
        if [ `pwd` = "/" ]; then
            echo "查找结束! 已经到系统根目录了!"
            break
        fi
    done
    echo '项目绝对路径: '`pwd`
    date=`date -R`
    echo $date
    cd `pwd` && GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m ' update thisDate';

}
# 创建提交
create_commit(){

}
case $1 in 
    -h | h | help)
        start='\033[0;32m'
        end='\033[0m'
        echo "运行：dash check_commit.sh $start <params> $end"
        printf "  $start%-16s$end%-20s\n" "-h|h|help" "帮助"
        printf "  $start%-16s$end%-20s\n\t%-20s\n" "-qu|qu|quantum <quantum> <startTime>" "按时间段提交; 参数1:时间长度,默认1天; 参数2: 开始时间,默认当天; 参数3:提交量,默认为1;" "例如  -qu 3 2 2 表示: 连续提交3天(含起点时间往前推),起点时间是2天前, 每天提交两次"
    ;;
    -qu | qu | quantum)
        quantum=$2
        startTime=$3
        commitNum=$4

        if [ "$startTime"z = "z" ]; then
            startTime=0
        fi
        if [ "$commitNum"z = "z" ]; then
            commitNum=1
        fi
        date --date=$startTime' day ago' -R
        for i in `seq 10`
        do

        done
    ;;
esac