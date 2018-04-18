#!/bin/bash

# 远程URL
url='http://192.168.10.200/svn/'
# 项目 空格分隔, 只能是根路径 不能出现 test/test
repos='test'
username='kuangchengping'
password='123456'
mergeDay=3


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
merge(){
    repoName=$1;lastVersion=$2;dates=$3;
    allFile=`ls ${repoName}*all.dump 2>/dev/null`
    # echo $allFile
    if [ $allFile'z' = 'z' ];then 
        svnrdump dump $url$repoName --username $username --password $password > "${repoName}_${dates}_ver${latestVersion}.all.dump"
        return 0
    fi
    files=`ls -tr $repoName*_.dump 2>/dev/null`
    if [ $files'z' = 'z' ] ;then
        printf  $error"没有更新\n"$end
    else
        mv $allFile "${repoName}_${dates}_ver${latestVersion}.all.dump"
        allFile="${repoName}_${dates}_ver${latestVersion}.all.dump"
        for file in $files;do
            echo "归并 "$file" >> "$allFile
            cat $file >> $allFile
        done
        rm -f $repoName*_.dump
    fi
}
dump(){
    for repoName in $repos;do
        dates=`date +%Y-%m-%d`
        # 获取最新版本号
        latestVersion=`svn info $url$repoName --username $username --password $password --xml`
        latestVersion=${latestVersion##*revision=\"}
        latestVersion=${latestVersion%%\">*}
        if [ "$latestVersion" -gt 0 ] 2>/dev/null ;then 
            echo '' > /dev/null
        else
            printf $error"$repoName 仓库配置错误, 请检查配置 \n"$end
            continue
        fi 
        # 如果是指定天数就全量备份否则增量备份, 且注意,版本号区间是不能重叠的否则导入失败
        # 加载配置文件得到上次备份的版本号, 如果是第一次就追加默认版本号为1
        name=${repoName}lastVersion
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
        # 除了首次备份, 之后都是增量备份
        if [ ! $lastVersion = 1 ];then
            svnrdump dump $url$repoName --username $username --password $password -r $lastVersion:$latestVersion --incremental > "${repoName}_${dates}_ver_${lastVersion}-${latestVersion}_.dump"
        fi
        # 判断是否需要归并
        if [ `date +%u` = $mergeDay ];then
            merge $repoName $lates"${repoName}_${dates}_ver${latestVersion}.all.dump"tVersion $dates
        fi
        # 更新版本号
        sed -i "s/"$repoName"lastVersion=.*/"$repoName"lastVersion="$latestVersion"/g" $configFile
    done
}
load(){
    repoName=$1;
    allFile=`ls ${repoName}*all.dump 2>/dev/null`
    if [ $allFile'z' = 'z' ];then 
        printf $error$repoName"没有完整备份文件\n"$end
        return 1
    fi
    files=`ls -tr $repoName*_.dump 2>/dev/null`
    if [ $files'z' = 'z' ] ;then
        printf $error$repoName"没有更新\n"$end
    else
        cp $allFile latest.dump
        for file in $files;do
            echo "归并 "$file" >> latest.dump"
            cat $file >> latest.dump
        done
    fi
}



help(){
    printf "%-20s$start%-20s$end\n" "运行：bash deal_md.sh " "<options>"
    printf "  $start%-20s$end%-20s\n" "-h|h|help" "输出帮助信息"
    printf "  $start%-20s$end%-20s\n" "-d" "对全部仓库进行备份"
    printf "  $start%-20s$end%-20s\n" "-l <repoName>" "对指定仓库或全部仓库合并出一个完整的latest.dump文件"
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
        if [ $# -lt 2 ];then
            for repo in $repos;do
                load $repo
            done
        else
            load $2
        fi
    ;;
    *)
        help
    ;;
esac


