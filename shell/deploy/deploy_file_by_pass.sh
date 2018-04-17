# 通过密码上传war到指定的服务器并重启Tomcat
path=$(cd `dirname $0`; pwd)
. $path/server.conf


# sshpass -p "tHoxVL4F" scp -P 32200 target/ROOT.war huoshu@47.100.46.134:/home/huoshu/

# 健康 🍎 幸福💑 就是💝爱

loadConfig(){
    perfix=$1;process=$2;
    temp=${perfix}host;
    host=${!temp}
    temp=${perfix}port;
    port=${!temp}
    temp=${perfix}user;
    user=${!temp}
    temp=${perfix}pass;
    pass=${!temp}
    temp=${perfix}work;
    work=${!temp}
    temp=${perfix}file;
    file=${!temp}
    temp=${perfix}path;
    path=${!temp}
    temp=${perfix}build;
    build=${!temp}
    temp=${perfix}comm;
    comm=${!temp}

    echo $host $port $user $pass $file $path $comm
    cd $work
    build="$build"$process
    echo ${build}|awk '{run=$0;system(run)}'
    # echo $build
    sshpass -p "${pass}" scp -P $port $file $user@$host:$path
    echo "$comm$process"
    echo sshpass -p \""${pass}\"" ssh -t -p $port $user@$host "\"$comm$process\""

}

help(){
    start='\033[0;32m'
    end='\033[0m'
    printf "运行：bash check_desktop.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|help" "帮助"
    printf "  $start%-16s$end%-20s\n" "-up type process" "使用某配置上传到指定进程"
}

case $1 in 
    -h | help)
        help
    ;;
    -up)
        # echo $#
        if [ $# -lt 3 ];then
            echo "请输入 配置系列 进程号";exit
        fi
        loadConfig $2'_' $3
    ;;
    *)
        help
    ;;
esac