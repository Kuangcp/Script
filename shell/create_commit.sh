#!/bin/dash
# 本质上就是一条命令的事, 写脚本是为了方便处理时间而已
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
    # echo '项目绝对路径: '`pwd`
}
# 创建虚假提交
create_commit(){
    # echo '项目绝对路径: '`pwd`
    # echo $1'__'$2
    date=$1
    echo "$date" > ignore
    get_file_url && cd `pwd` && git add * 
    GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m ' daily update';
}
# 创建有效提交一次, 但是修改日期
self_commit(){
    date=$1
    get_file_url && cd `pwd` && git add * 
    GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m ' daily update';
}

case $1 in 
    -h | h | help)
        start='\033[0;32m'
        end='\033[0m'
        echo "运行：dash check_commit.sh $start <params> $end"
        printf "  $start%-16s$end%-20s\n" "-h|h|help" "帮助"
        printf "  $start%-16s$end%-20s\n\t%-20s\n\t%-20s\n" "-qu|qu|quantum <quantum> <startTime> <commitNum> " \
                "按时间段提交; " "参数1:时间长度,默认1天; 参数2: 开始时间,默认当天; 参数3:提交量,默认为1;" \
                "例如  -qu 3 2 2 表示: 连续提交3天(含起点时间往前推),起点时间是2天前, 每天提交两次"
        printf "  $start%-16s$end%-20s\n\t%-20s\n" "-se|se|self <targetDate> " "修改该次提交的时间" "参数1:几天前 例如: se 1 在1天前提交"
    ;;
    -qu | qu | quantum)
        quantum=$2
        startTime=$3
        commitNum=$4

        if [ "$quantum"z = "z" ]; then
            quantum=1
        fi
        if [ "$startTime"z = "z" ]; then
            startTime=0
        fi
        if [ "$commitNum"z = "z" ]; then
            commitNum=1
        fi
        for i in `seq $quantum`; do
            temp=$(( $startTime + $i - 1))
            for k in `seq $commitNum`; do
                currentDay=`date --date=$temp' day ago - '$k'min ago' -R`
                create_commit "$currentDay"
            done
        done
        ;;
    -se| se |self)
        targetDate=$2
        if [ "$targetDate"z = "z" ]; then
            targetDate=0
        fi
        currentDay=`date --date=$targetDate' day ago' -R`
        self_commit "$currentDay"
    ;;
    # *)
    # echo 23333;;
esac
