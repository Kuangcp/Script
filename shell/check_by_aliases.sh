#!/bin/sh
#  检查仓库 shell重写，使用aliases文件更方便
# 只适用于中文系统

configPath="/home/kcp/.kcp_aliases"

# 读取配置文件,分析每一行,分析仓库状态 并输出
readConfigAnalysisRepos(){
    temp=""
    flag=1
    title=0
    clean=`expr match "$1" ".*干净"`
    # 去除无关信息
    if [ "$clean" != "0" ]; then 
        break
    fi
    change=`expr match "$1" ".*变更"`
    use=`expr match "$1" ".*使用"`
    if [ "$use" != "0" -o "$change" != "0" ]; then
        continue
    fi 
    # 判断是否需要添加进来，去除掉没有修改,增加,删除的仓库
    change=`expr match "$1" ".*修改"`
    have_add=`expr match "$1" ".*未跟踪"`
    have_delete=`expr match "$1" ".*删除"`
    # echo $have_add
    if [ "$change" != "0" ] || [ "$have_add" != "0" ] || [ "$have_delete" != "0" ]; then 
        # echo "\033[0;33m"$i" \033[0m"
        temp="\033[0;33m ${1} \033[0m"
        flag=0
    fi
    if [ "$flag"x = "1"x ]; then
        temp="${temp}${1}"
    fi

    # 输出仓库彩色标题信息 去除了没有操作的仓库
    if [ "$change" != "0" ]  || [ "$have_add" != "0" ] || [ "$have_delete" != "0" ]; then 
        if [ "$3"x = "0"x -a "$4"x = "0"x ];then
            # 输出有颜色的仓库标题
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
        # 输出git命令运行结果 即文件名
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
            title= readConfigAnalysisRepos "$i" "$line" "${title}" "${show_title}"
            if [ "$title"x = "1"x ]; then
                # cd $var && git branch
                show_title=1
            fi
        done
        LinePath='' # 清除缓存变量
    done
}

# alias文件新增一个仓库以及别名
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
    echo "alias Kg."$aliasName"='cd $repo_path' # $comment" >> $1
    echo "添加完成, 请更新 .bashrc或其他别名配置文件"
}

# push所有仓库
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

# 根据平台的不同输出不同的URL Github Gitee Gitlab URL构造是一样的 有关联对应的仓库才输出
show_link(){
    for line in $1
    do 
        isGithub=`expr match "$line" ".*"$2`
        if [ $isGithub != 0 ]; then 
            result=`git branch`
            isBranch=${result#* } # 得到分支名
            index=${#project_path} # 得到项目路径长度
            index=$(($index+1))
            relative_path=`expr substr "$current_path" $index 100` # 将当前路径减去项目路径
            
            url=${line#* } # 截取空格之后的URL
            isHttps=`expr match "$url" "https*"`
            # HTTPS 和 SSH 两种方式的仓库URL进行转换
            if [ $isHttps != 0 ]; then 
                isRepo=${url%%\.git*}
                echo "  \033[0;36m"$isRepo"/blob/"$isBranch$relative_path"/"$3"\033[0m\n"
            else
                isRepo=${line#*:} # 截取:右边
                isRepo=${isRepo%%\.*} # 截取.左边
                echo "  \033[0;36mhttps://$2.com/"$isRepo"/blob/"$isBranch$relative_path"/"$3"\033[0m\n"
            fi
            break
        fi
    done
}
get_file_url(){
    echo "开始寻找项目根目录..."
    current_path=`pwd`
    for i in `seq 10` # 限制最多往上找10级目录
    do
        result=`ls -al | grep d.*git` # 搜索d开头的结果,也就是文件夹
        if [ "$result"z = "z" ]; then 
            cd ..
        else 
            break
        fi
        if [ `pwd` = "/" ]; then
            echo "查找结束! 已经到系统根目录了!"
            break
        fi
    done
    if [ "$result"z != "z" ]; then 
        remote_link=`git remote -v`
        project_path=`pwd`
    fi 

    show_link "$remote_link" "github" $2
    show_link "$remote_link" "gitee" $2
    # show_link "$remote_link" "gitlab" $2
}

# 入口 读取脚本参数调用对应 函数
case $1 in 
    -h | h | help)
        start='\033[0;32m'
        end='\033[0m'
        echo "运行：sh check_repos.sh $start <params> $end"
        printf "  $start%-16s$end%-20s\n" "no param" "列出所有操作过的仓库"
        printf "  $start%-16s$end%-20s\n" "-h|h|help" "输出帮助信息"
        printf "  $start%-16s$end%-20s\n" "-l|l|list" "列出所有仓库"
        printf "  $start%-16s$end%-20s\n" "-p|p|push" "推送本地的提交"
        printf "  $start%-16s$end%-20s\n" "-a/ac" "手动添加仓库以及注释信息或者/自动添加当前目录"
        printf "  $start%-16s$end%-20s\n" "-i <imagefile>" "仅是图片仓库：在当前目录方便得到图片URL"
        printf "  $start%-16s$end%-20s\n" "-f <file>" "github上文本文件URL"
        printf "  $start%-16s$end%-20s\n" "-c" "打开配置文件"
        # printf "  $start%-16s$end%-20s\n" "" ""
        return 0;;
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
    -f | f )
        # 思路: 循环 往上找10级目录,找到了.git文件夹就执行 git remote -v 命令,然后github的拼接出来
        get_file_url $1 $2;;
    -c)
        vim $configPath
        return 0;;
    *)
        readFile "$configPath";;
esac