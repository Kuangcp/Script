red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
yarn='\033[0;34m'
pulper='\033[0;35m'
blue='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

configFile='/home/kcp/.config/app-conf/key-record/main.conf'

help(){
    printf "Run：$red sh record.sh$green <verb> $yellow<args>$end\n"
    format="  $green%-5s $yellow%-15s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
    printf "$format" "-q" "" "搜索键盘设备可能对应的事件号"
    printf "$format" "-b" "" "显示正在后台运行的记录脚本"
    printf "$format" "-s" "<eventNum>" "root: 使用指定的事件号/上次配置启动记录脚本"
    printf "$format" "-d" "" "root: 停止所有正在后台运行的记录脚本"
}

startup(){
    if [ $(id -u) != "0" ]; then
        printf $red"Please use root to run this script\n"$end
        exit 1
    fi

    if [ ! -f $configFile ]; then
        echo "[event]\nkey = 9\n\n[redis]\nhost = 127.0.0.1\nport = 6666\ndb = 2\npassword=\n" >> $configFile
    fi

    eventNum=$1
    path=$(cd `dirname $0`; pwd)
    if [ $eventNum'z' = 'z' ];then
        printf "$green use default config to start $end \n"
    else
        sed -i "s/key\s=.*/key = $eventNum/g" $configFile
        printf "$green use event $eventNum to start $end \n"
    fi
    (python3 $path/RecordClickWithRedis.py &)
}

shutdown(){
    if [ $(id -u) != "0" ]; then
        printf $red"Please use root to run this script\n"$end
        exit 1
    fi
    id=`ps -ef | grep "WithRedis.py" | grep -v "grep" | grep -v "\-d" | awk '{print $2}'`
    if [ "${id}1" = "1" ];then
        printf $red"not exist background running script\n"$end
    else
        kill -9 $id
    fi
}

query(){
    result=$(cat /proc/bus/input/devices)
    flag=0
    printf $green"It could be a keyboard event: "$end
    for line in $result;do
        # echo $line
        result=`echo $line | grep event`
        if [ $flag = 1 ] && [ $result'z' != 'z' ];then
            printf $line" "
        fi
        if [ $line = 'kbd' ];then
            flag=1
        fi

        # 一个设备可能占据多行, 具有多个 event
        first=$(echo $line | grep "Bus")
        if [ $first'z' != 'z' ]; then
            flag=0
        fi
    done
    echo ""
}

case $1 in 
    -h)
        help ;;
    -s) # start 
        startup $2
    ;;
    -q) 
        query
    ;;
    -d) 
       shutdown
    ;;
    -b) # background
        ps -ef | grep "WithRedis.py" | grep -v "grep"
    ;;
    -cnf)
       vim $configFile
    ;;
    *)
        help
    ;; 
esac
