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
showLog(){
    less process$1/logs/catalina.out
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
    printf "  $start%-16s$end%-20s\n" "-up num" "更新对应num的ROOT.war"
    printf "  $start%-16s$end%-20s\n" "-re num" "重启Tomcat"
    printf "  $start%-16s$end%-20s\n" "-l num" "显示日志"
}

case $1 in 
    -h | h | help)
        help
    ;;
    -re|re)
        restart $2
    ;;
    -up|up)
        update $2
    ;;
    -l|l)
        showLog $2
    ;;
    -update)
        updateSelf
    ;;
    *)
        help
    ;;
esac