#!/bin/sh

configPath="/home/kcp/Application/Script/python/config/repos.md"
#  检查仓库 shell重写
readLine(){
    i=$1
    temp=""
    flag=1
    title=0
    clean=`expr match "$i" ".*干净"`
    # 去除无关信息
    if [ "$clean" != "0" ]; then 
        break
    fi
    change=`expr match "$i" ".*变更"`
    use=`expr match "$i" ".*使用"`
    if [ "$use" != "0" -o "$change" != "0" ]; then
        continue
    fi 
    # 判断是否需要添加进来，去除没有修改的仓库输出信息
    change=`expr match "$i" ".*修改"`
    if [ "$change" != "0" ]; then 
        # echo "\033[0;33m"$i" \033[0m"
        temp="${temp}\033[0;33m ${i} \033[0m"
        flag=0
    fi
    if [ "$flag"x = "1"x ]; then
        temp="${temp}${i}"
    fi
    # 去除没有修改的仓库的头信息
    change=`expr match "$temp" ".*修改"`
    if [ "$change" != "0" ]; then 
        if [ "$3"x = "0"x ];then
            echo $2
            echo "\033[0;32m当前分支："`git branch`"\033[0m"
        fi
        title=1
        echo ""$temp
    fi
    return $title
}
readFile(){
    title=0
    cat $1 | while read line
    do 
        # 排除非/开头的行
        start_char=`expr match "$line" "/*"`
        if [ "$start_char" = "0" ]; then 
            continue
        fi 
        var=${line%%#*} 
        result=`cd $var && git status 2>&1`
        # 将真正输出的内容先放在数组里，判断后再全部输出
        echo "$result" | while read i 
        do  
            title= readLine "$i" "\033[0;35m..............${line}\033[0m" "${title}"
            # echo $title
        done
    done
}
appendFile(){
    repo_path=`pwd`
    if [ "$2"x = ""x ]; then
        echo "请输入仓库路径："
        read repo_path
    fi
    echo "请输入仓库注释"
    read comment
    echo $repo_path" # "$comment >> $1
    echo "添加完成"
}

pushAll(){
    title=0
    cat $1 | while read line
    do 
        # 排除非/开头的行
        start_char=`expr match "$line" "/*"`
        if [ "$start_char" = "0" ]; then 
            continue
        fi 
        var=${line%%#*} 
        echo "\033[0;35m"$var"\033[0m"
        result=`cd $var && git status`
        haveCommit=`expr match "$result" ".*领先"`
        # echo $result$haveCommit
        if [ $haveCommit != 0 ];then 
            cd $var && git push
        fi
    done
}

# 读取参数
case $1 in 
    -h | h | help)
        echo "sh check_repos.sh <params>"
        echo "  -h|h|help    输出帮助信息"
        echo "  -p|p|push    推送本地的提交"
        echo "  -a <c>       添加仓库以及注释信息<添加当前目录>"
        echo "  -i <image>   仅是图片仓库：在当前目录方便得到图片URL"
        # echo ""
        return 0
    ;;
    -p | push | p)
        pushAll "$configPath"
        echo "推送全部完成"
        return 0;;
    -a)
        appendFile $configPath $2
        return 0;;
    -l)
        cat $configPath
        return 0;;
    -i)
        # 配置图片仓库地址即可
        imagePath="/home/kcp/Pictures/ImageRepos"
        url="https://raw.githubusercontent.com/Kuangcp/ImageRepos/master"
        path=`pwd`
        isRepo=`expr match "$path" ".*$imagePath"`
        if [ $isRepo = 0 ]; then 
            echo "请在图片仓库运行"
            return 0
        fi 
        imagePath=$imagePath" "
        # 要手动设置图片仓库的相对路径的长度 30 这之前的要截取掉
        subPath=`expr substr "$path" ${#imagePath} ${#path}`
        echo "\n"$url$subPath"/"$2"\n"
        return 0;;
    -f)
        vim $configPath
        return 0;;
    # *)
    #     echo "Ignorant"
    # ;; 
esac

readFile "$configPath"