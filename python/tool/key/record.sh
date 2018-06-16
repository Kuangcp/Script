red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
yarn='\033[0;34m'
pulper='\033[0;35m'
blue='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red sh .sh$green <verb> <args>$end\n"
    format="  $green%-14s $yellow%-15s$end%-20s\n"
    printf "$format" "-h|h|help" "" "帮助"
    printf "$format" "-q|q|query" "" "搜索键盘可能的事件号"
    printf "$format" "-s|s|start" "eventNum" "依据指定的事件号启动脚本"
}
startup(){
    eventNum=$1
    # 根据输入事件号, 自动修改配置文件, 启动py脚本
}

case $1 in 
    -h | h | help)
        help ;;
    -s|s|start)
        if [ $2'z' = 'z' ];then
            printf "${red}Please specific event num{$end}\n"
            exit
        fi
        startup $2
    ;;
    -q|q|query)
        result=`cat /proc/bus/input/devices`
        flag=0
        for line in $result;do
            # echo $line
            result=`echo $line | grep event`
            if [ $flag = 1 ] && [ $result'z' != 'z' ];then
                echo $line
                flag=0
            fi
            if [ $line = 'Keyboard"' ];then
                flag=1
            fi
        done
    ;;
    *)
        help
    ;; 

esac