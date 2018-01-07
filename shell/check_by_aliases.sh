#!/bin/sh

## TODO bug: 不能检查到删除新增文件的仓库，只是检查了修改的仓库
configPath="/home/kcp/.kcp_aliases"
#  检查仓库 shell重写，使用aliases文件更方便
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
        if [ "$3"x = "0"x -a "$4"x = "0"x ];then
            # 输出有颜色的仓库标题
            # echo $2
            aliasName=${2%=*}
            aliasName=${aliasName#*Kg.}
            line=${2#*cd }
            path=${line%%#*}
            path=${path%\'*}
            name=${line#*#}
            printf "\033[0;35mKg.%-10s" $aliasName
            printf "\033[0;32m%-60s" $path
            printf "\033[1;34m《%s》\n" $name
            title=1
        fi
        # 其他部分：修改的文件
        echo "  "$temp
    fi
    return $title #返回是否输出过标题
}
# 用来切分一行内容
LinePath=''
splitLine(){
    # 函数是不能返回字符串的 只能返回整型得知运行结果，用一个变量进行存取来达到目的
    vars=`expr match "$1" "alias.Kg.*"`
    if [ "$vars" = "0" ]; then 
        return 0;
    fi 
    vars=${1%%#*} # 截取#左边
    vars=${vars#*cd } # 截取cd右边
    vars=${vars%\'*} # 截取 右边引号 之左
    LinePath="$vars"
}
# 列出仓库 加上颜色
listRepos(){
    cat $1 | while read line
    do 
        vars=`expr match "$line" "alias.Kg.*"`
        if [ "$vars" = "0" ]; then 
            continue
        fi
        # echo $line
        temp=${line%%#*}
        end='\033[0m'
        #裁剪字符串
        str_alias=${line%=*}
        str_alias=${str_alias#*alias}
        str_path=${temp#*cd}
        str_path=${str_path%\'*}
        str_comment=${line#*#}
        # 格式化输出
        printf "\033[0;33m%-20s" $str_alias
        printf "\033[0;36m%-56s" $str_path
        printf "\033[0;32m%-20s\n" $str_comment
    done
}

# 读取配置文件
readFile(){
    title=0
    cat $1 | while read line
    do 
        # 记录一次仓库循环中是否输出过标题
        show_title=0

        start_char= splitLine "$line"
        # echo "收到的结果______"$LinePath
        if [ "$start_char" = "0" ]; then 
            continue
        fi
        if [ "$LinePath"x = "x" ]; then 
            continue
        fi 
        # echo "收到的结果"$LinePath
        result=`cd "$LinePath" && git status 2>&1`  #将真正输出的内容先放在数组里，判断后再全部输出
        echo "$result" | while read i  
        do  
            title= readLine "$i" "$line" "${title}" "${show_title}"
            if [ "$title"x = "1"x ]; then
                # cd $var && git branch
                show_title=1
            fi
        done
        LinePath='' # 清除缓存变量
    done
}
# 新增一行内容
appendFile(){
    repo_path=`pwd`
    if [ "$2"x = ""x ]; then
        echo "请输入仓库路径："
        read repo_path
    fi
    echo "请输入仓库注释/说明"
    read comment
    echo "请输入别名,当输入 a 得到 Kg.a"
    read aliasName
    # echo $repo_path" # "$comment >> $1
    echo "alias Kg."$aliasName"='cd $repo_path' # $comment" >> $1
    echo "添加完成"
}

pushAll(){
    title=0
    cat $1 | while read line
    do 
        # 排除非/开头的行
        start_char= splitLine "$line"
        if [ "$start_char" = "0" ]; then 
            continue
        fi 
        if [ "$LinePath"x = "x" ]; then 
            continue
        fi 
        echo "\033[0;35m"$LinePath"\033[0m"
        result=`cd $LinePath && git status`
        haveCommit=`expr match "$result" ".*领先"`
        # echo $result$haveCommit
        if [ $haveCommit != 0 ];then 
            cd $LinePath && git push
        fi
        LinePath=''
    done
}

# 读取参数
case $1 in 
    -h | h | help)
        start='\033[0;32m'
        end='\033[0m'
        echo "运行：sh check_repos.sh $start <params> $end"
        printf "  $start%-16s$end%-20s\n" "-h|h|help" "输出帮助信息"
        printf "  $start%-16s$end%-20s\n" "-l|l|list" "列出所有仓库"
        printf "  $start%-16s$end%-20s\n" "-p|p|push" "推送本地的提交"
        printf "  $start%-16s$end%-20s\n" "-a<ac>" "手动添加仓库以及注释信息或者<自动添加当前目录>"
        printf "  $start%-16s$end%-20s\n" "-i <image>" "仅是图片仓库：在当前目录方便得到图片URL"
        printf "  $start%-16s$end%-20s\n" "-f" "打开配置文件"
        # printf "  $start%-16s$end%-20s\n" "" ""
        return 0
    ;;
    -p | push | p)
        pushAll "$configPath"
        echo "推送全部完成"
        return 0;;
    -a)
        appendFile $configPath ''
        return 0;;
    -ac)
        appendFile $configPath 'currentPath'
        return 0;;
    -l | l | list)
        listRepos $configPath
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
esac

readFile "$configPath"