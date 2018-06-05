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
end='\033[0m'
error='\033[0;31m'

updateSelf(){
    curl https://raw.githubusercontent.com/Kuangcp/Script/master/shell/deploy/manager.sh -o manager.sh
    echo "脚本更新完成"
}

help(){
    printf "运行：dash manager.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|h|help" "帮助"
    printf "  $start%-16s$end%-20s\n" "-update" "更新此脚本"
    printf "  $start%-16s$end%-20s\n" "-up num" "更新对应num的ROOT.war"
    printf "  $start%-16s$end%-20s\n" "-re num" "重启Tomcat"
    printf "  $start%-16s$end%-20s\n" "-on num" "启动Tomcat"
    printf "  $start%-16s$end%-20s\n" "-off num" "关闭Tomcat"
    printf "  $start%-16s$end%-20s\n" "-l num" "显示项目日志"
    printf "  $start%-16s$end%-20s\n" "-t num" "显示Tomcat输出"
    printf "  $start%-16s$end%-20s\n" "-cnf num" "进入项目配置目录"
}

case $1 in 
    -h | h | help)
        help
    ;;
    -re)
        restart $2
    ;;
    -up)
        update $2
    ;;
    -t)
        showOut $2
    ;;
    -l)
        showLog $2
    ;;
    -on)
        process$2/bin/startup.sh
    ;;
    -off)
        process$2/bin/shutdown.sh
    ;;
    -cnf)
        cd process$2/webapps/ROOT/WEB-INF/classes/config
        # sh 运行是在子shell中的, 所以要用 source 执行该脚本
    ;;
    -update)
        updateSelf
    ;;
    *)
        help
    ;;
esac