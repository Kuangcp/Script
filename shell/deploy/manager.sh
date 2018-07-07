#!/bin/sh
# 管理 项目/process1 ... process4 这样的目录结构的Tomcat

update(){
    target=$1;
    cd process$target
    # 备份原始文件夹, 更新并重启
    time=`date +%m-%d_%H:%M:%S`
    cp -r webapps/ROOT back$time &&
    rm -rf webapps/ROOT* &&
    mv ROOT.war webapps &&
    bin/shutdown.sh &&
    bin/startup.sh &&
    cd ..
}
restart(){
    target=$1;
    cd process$target
    bin/shutdown.sh &&
    bin/startup.sh &&
    cd ..
}
showOut(){
    less process$1/logs/catalina.out
}
showLog(){
    less process$1/log/game.log
}

start='\033[0;32m'
error='\033[0;31m'

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
yarn='\033[0;34m'
pulper='\033[0;35m'
blue='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red sh manager.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-11s $yellow%-8s$end%-20s\n"
    printf "$format" "-h|h|help" "" "帮助"
    printf "$format" "-update" "" "更新此脚本"
    printf "$format" "-up" "num" "更新对应num的ROOT.war"
    printf "$format" "-re" "num" "重启Tomcat"
    printf "$format" "-on" "num" "启动Tomcat"
    printf "$format" "-off" "num" "关闭Tomcat"
    printf "$format" "-l" "num" "显示项目日志"
    printf "$format" "-t" "num" "显示Tomcat输出"
    printf "$format" "-cnf" "num" "进入项目配置目录"
}

updateSelf(){
    curl https://raw.githubusercontent.com/Kuangcp/Script/master/shell/deploy/manager.sh -o manager.sh
    echo "脚本更新完成"
}

case $1 in 
    -h)
        help
    ;;
    -re|re)
        restart $2
    ;;
    -up|up)
        update $2
    ;;
    -t|t)
        showOut $2
    ;;
    -l|l)
        showLog $2
    ;;
    -on|on)
        process$2/bin/startup.sh
    ;;
    -off|off)
        process$2/bin/shutdown.sh
    ;;
    -cnf|cnf)
        cd process$2/webapps/ROOT/WEB-INF/classes/config
        # sh 运行是在子shell中的, 所以要用 source 执行该脚本
    ;;
    -update|update)
        updateSelf
    ;;
    *)
        help
    ;;
esac