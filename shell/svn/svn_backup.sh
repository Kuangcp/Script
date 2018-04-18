#!/bin/bash

url='http://192.168.10.200/svn/'
repos='test df'
username='kuangchengping'
password='123456'
dayOfBackupAll=6

path=$(cd `dirname $0`; pwd)
configFile=$path/backup.conf
start='\033[0;32m'
error='\033[0;31m'
end='\033[0m'
init(){
    if [ ! -f $configFile ];then
        touch $configFile
    fi
    . $configFile
}
dump(){
    for repoName in $repos;do
    # repoNum=${#repos[*]}
    # for i in $(seq 0 $repoNum); do
        # if [ $i == $repoNum ];then
            # break
        # fi       
        # repoName=${repos[i]}
        dates=`date +%Y-%m-%d`
        # 获取最新版本号
        latestVersion=`svn info $url$repoName --username $username --password $password --xml`
        
        latestVersion=${latestVersion##*revision=\"}
        
        latestVersion=${latestVersion%%\">*}
        echo ">>>>>>>>>>"$latestVersion
        # 如果是指定天数就全量备份否则增量备份, 且注意,版本号区间是不能重叠的否则导入失败
        # 加载配置文件得到上次备份的版本号, 如果是第一次就追加默认版本号为1
        name=${repoName}lastVersion
        echo $name
        lastVersion=${!name}
        if [ "$lastVersion"z = 'z' ];then
            lastVersion=1
            echo $repoName"lastVersion=1" >> $configFile
        else
            ((lastVersion++))
            if [ $lastVersion -gt $latestVersion ];then
                printf $error$repoName" 仓库没有更新\n"$end
                continue
            fi
        fi
        # latestVersion=3
        if [ `date +%u` = $dayOfBackupAll ];then
            svnrdump dump $url$repoName --username $username --password $password > "${repoName}_${dates}_ver${latestVersion}.all.dump"
            #删除增量备份
            rm -f $repoName*_.dump
        else
            svnrdump dump $url$repoName --username $username --password $password -r $lastVersion:$latestVersion --incremental > "${repoName}_${dates}_ver_${lastVersion}-${latestVersion}_.dump"
        fi
        # 更新版本号
        sed -i "s/"$repoName"lastVersion=.*/"$repoName"lastVersion="$latestVersion"/g" $configFile
    done
}
load(){
    echo 32
}

help(){
    printf "%-20s$start%-20s$end\n" "运行：bash deal_md.sh " "<options>"
    printf "  $start%-20s$end%-20s\n" "-h|h|help" "输出帮助信息"
    printf "  $start%-20s$end%-20s\n" "-d" "进行备份"
    printf "  $start%-20s$end%-20s\n" "-l" "进行恢复"
}
case $1 in 
    -h)
        help
    ;;
    -d)
        init
        dump
    ;;
    -l)
        init
        load
    ;;
    *)
        help
    ;;
esac


