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

# red='\033[0;31m'
# green='\033[0;32m'
# yellow='\033[0;33m'
# yarn='\033[0;34m'
# purple='\033[0;35m'
# blue='\033[0;36m'
# white='\033[0;37m'
# default='\033[0m'

start='\033[0;32m'
end='\033[0m'
error='\033[0;31m'

help(){
    printf "运行：dash manager.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|h|help" "帮助"
    printf "  $start%-16s$end%-20s\n" "-up <processNum>" "更新对应process的ROOT.war"
    printf "  $start%-16s$end%-20s\n" "-re" "重启Tomcat"
    printf "  $start%-16s$end%-20s\n" "-l" "显示日志"
}

case $1 in 
    -h | h | help)
        help
    ;;
    -re)
        restart
    ;;
    -up)
        update $2
    ;;
    -l)
        showLog
    ;;
    *)
        help
    ;;

esac