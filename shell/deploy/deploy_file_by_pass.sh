# 通过密码上传war到指定的服务器并重启Tomcat
path=$(cd `dirname $0`; pwd)
. $path/server.conf

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
    echo "sshpass -p "${pass}" scp -P $port $file $user@$host:$path"
    sshpass -p "${pass}" scp -P $port $file $user@$host:$path
    echo "$comm$process"
    echo sshpass -p \""${pass}\"" ssh -t -p $port $user@$host "\"$comm$process\""
    sshpass -p "${pass}" ssh -t -p $port $user@$host "$comm$process"
    sshpass -p "${pass}" ssh -t -p $port $user@$host "$comm$process"
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
        if [ -f server.conf ];then
            echo "请初始化配置文件"
            echo -e "A_host=''" >> server.conf
            echo -e "A_port=''" >> server.conf
            echo -e "A_user=''" >> server.conf
            echo -e "A_pass=''" >> server.conf
            echo -e "A_work='/home/kcp/work/yy'" >> server.conf
            echo -e "A_file='target/ROOT.war'" >> server.conf
            echo -e "A_path='/home/huoshu/'" >> server.conf
            echo -e "A_build='mvn clean package -Pyy_fengkuangqiangda_'" >> server.conf
            echo -e "A_comm='sudo mv /home/huoshu/ROOT.war /data/services/fengkuangqiangda/process'" >> server.conf
            exit 1
        fi
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