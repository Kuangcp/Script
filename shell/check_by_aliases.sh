#!/bin/dash
# 根据aliase文件来检查git仓库, 只适用于使用中文语言的Linux系统

configPath="/home/kcp/.repos.ini"
# 向上迭代目录的最大深度
maxDeepth=10

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
start='\033[0;32m'
end='\033[0m'

# 读取配置文件,分析每一行,分析仓库状态 并输出
readConfigAnalysisRepos(){
    temp="";flag=1;title=0;
    # 对比之下,expr比grep更快
    clean=`expr match "$1" ".*干净"`
    # clean=`echo "$1"| awk "/干净/"`
    # echo ">>$clean<<"
    # 过滤掉没有修改的仓库
    if [ "$clean" != "0" ]; then 
        break
    fi
    crud=`expr match "$1" '.*[新修跟踪删除领]'`
    ignore=`expr match "$1" '.*<文件>'`
    if [ "$crud" != "0" ] && [ "$ignore" = '0' ];then
    # if [ "$change" != "0" ] || [ "$have_add" != "0" ] || [ "$have_delete" != "0" ] || [ "$new_file" != "0" ]; then 
        temp=$1
        flag=0
        if [ "$flag"x = "1"x ]; then
            temp="${temp}${1}"
        fi
        # 输出仓库彩色标题信息 去除了没有操作的仓库
        if [ "$3"x = "0"x -a "$4"x = "0"x ];then
            # 输出有颜色的仓库标题
            aliasName=${2%=*}
            aliasName=${aliasName#*kg.}
            line=${2#*cd }
            path=${line%%#*}
            path=${path%\'*}
            name=${line#*#}

            printf $green"kg.%-10s %-50s %-20s $end\n" $aliasName $path "《$name 》"
            title=1
        fi
        # 输出git命令运行结果 即文件名
        other=`expr match "$1" ".*尚未加入"`
        if [ $other = 0 ]; then
            printf "  \033[0;36m%s\033[0m\n" "$1"
        fi
    fi
    return $title #返回是否输出过标题
}

# 用来切分一行内容
LinePath=''
splitLine(){
    # 函数是不能返回字符串的 只能返回整型得知运行结果，用一个变量进行存取来达到目的
    vars=`expr match "$1" "alias.kg.*"`
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
    cat $1 | while read line ; do 
        vars=`expr match "$line" "alias.kg.*"`
        if [ "$vars" = "0" ]; then 
            continue
        fi
        #裁剪字符串
        temp=${line%%#*}
        str_alias=${line%=*}
        str_alias=${str_alias#*alias}
        str_path=${temp#*cd}
        str_path=${str_path%\'*}
        str_comment=${line#*#}
        
        printf "$yellow%-20s $cyan%-56s $green%-20s $end\n" $str_alias $str_path $str_comment
    done
}

# 读取配置文件
readFile(){
    title=0
    cat $1 | while read line ; do 
        # 配置文件中含有+号则表示不进行检查
        ignore=`echo "$line" | grep "+"`
        if [ "$ignore"x != "x" ];then 
            continue
        fi
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
        echo "$result" | while read i ; do  
            title= readConfigAnalysisRepos "$i" "$line" "${title}" "${show_title}"
            if [ "$title"x = "1"x ]; then
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
    echo "请输入别名, 例如 输入 a 得到 kg.a"
    read aliasName
    echo "alias kg."$aliasName"='cd $repo_path' # $comment" >> $1
    echo "添加完成, 请更新 .bashrc或其他别名配置文件"
}

# push所有仓库
pushAll(){
    title=0
    cat $1 | while read line; do 
        # 排除非/开头的行
        start_char= splitLine "$line"
        if [ "$start_char" = "0" ]; then 
            continue
        fi 
        if [ "$LinePath"x = "x" ]; then 
            continue
        fi 
        printf "\033[0;35m%s\033[0m\n" $LinePath
        result=`cd $LinePath && git status`
        haveCommit=`expr match "$result" ".*领先"`
        # echo $result$haveCommit
        if [ $haveCommit != 0 ]; then 
            cd $LinePath && git push
        fi
        LinePath=''
    done
}

# 根据平台的不同输出不同的URL Github Gitee Gitlab URL构造是一样的 有关联对应的仓库才输出
showLink(){
    for line in $1; do 
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
                echo "$isRepo/blob/$isBranch$relative_path/$3\n"
            else
                isRepo=${line#*:} # 截取:右边
                isRepo=${isRepo%%\.*} # 截取.左边
                echo "https://$2.com/$isRepo/blob/$isBranch$relative_path/$3\n"
            fi
            if [ $2 = 'github' ];then
                echo "https://raw.githubusercontent.com/$isRepo/$isBranch$relative_path/$3\n"
            fi
            break
        fi
    done
}
# 获取仓库中文件的远程URL,目前实现了Github和Gitee
getFileLocateUrl(){
    current_path=`pwd`
    for i in `seq $maxDeepth`; do # 限制最多往上找10级目录
        result=`ls -al | grep d.*git` # 搜索d开头的结果,也就是文件夹
        if [ "$result"z = "z" ]; then 
            cd ..
        else 
            break
        fi
        if [ `pwd` = "/" ]; then
            echo "查找Git仓库失败! 已经到系统根目录了!"
            exit
        fi
    done
    if [ $i = $maxDeepth ]; then
        echo "目录太深了, 请检查当前目录是否正确, 或者修改脚本最大迭代深度的配置项"
        exit
    fi
    if [ "$result"z != "z" ]; then 
        remote_link=`git remote -v`
        project_path=`pwd`
    fi 
    showLink "$remote_link" "github" $2
    showLink "$remote_link" "gitee" $2
    # showLink "$remote_link" "gitlab" $2
}
pullRepos(){
    . /home/kcp/.repos
    flag=0
    for repo in "$@" ; do
        if [ $flag = 0 ];then
            flag=1
            continue
        fi
        # printf " $repo \n"
        path="`alias kg.$repo`" 
        path=${path##*cd}
        path=${path%\'*}
        printf " $start$path$end \n"
        cd $path && git pull
    done
}
pushRemote(){
    path=`pwd`
    result=`git remote -v`
    count=-1
    for temp in $result; do
        count=$(( $count + 1 ))
        if [ $(($count % 6)) = 0 ]; then
            echo $start"$temp"$end
            git push $temp
        fi
    done
}
help(){
    printf "Run：$red sh check_by_aliases.sh.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-10s $yellow%-12s$end%-20s\n"
    printf "$format" "-h" "" "show help"
    printf "$format" "" "" "show all modify local repo"
    printf "$format" "-l|l|list" "" "list all local repo"
    printf "$format" "-p|p|push" "" "push all modify local repo to remote "
    printf "$format" "-pa|pa" "" "push current local repo to all remote"
    printf "$format" "-pl|pull" "repo..." "batch pull repo from remote "
    printf "$format" "-i|i" "imgFile" "show image url "
    printf "$format" "-f|f" "file" "show file raw content url "
    printf "$format" "-a|a" "" "add a local repo to alias config"
    printf "$format" "-ac|ac" "" "add current local repo to alias config"
    printf "$format" "-c" "" "open alias config file "
}
# 入口 读取脚本参数调用对应 函数
case $1 in 
    -h)
        help;;
    -pl|pull)
        pullRepos $@;;
    -p | push | p)
        pushAll "$configPath"
        echo "推送全部完成"
        exit 0;;
    -pa | pa)
        echo "推送到所有远程库"
        pushRemote
        exit 0;;
    -a | a)
        appendFile $configPath ''
        exit 0;;
    -ac | ac)
        appendFile $configPath 'currentPath'
        exit 0;;
    -l | l | list)
        listRepos $configPath | sort
        exit 0;;
    -i | i)
        # 配置图片仓库地址即可
        imagePath="/home/kcp/Pictures/ImageRepos"
        url="https://raw.githubusercontent.com/Kuangcp/ImageRepos/master"
        path=`pwd`
        isRepo=`expr match "$path" ".*$imagePath"`
        if [ $isRepo = 0 ]; then 
            echo "请在图片仓库运行"
            exit 0
        fi 
        imagePath=$imagePath" "
        # 要手动设置图片仓库的相对路径的长度 30 这之前的要截取掉
        subPath=`expr substr "$path" ${#imagePath} ${#path}`
        echo "\n"$url$subPath"/"$2"\n"
        exit 0;;
    -f | f )
        # 思路: 循环 往上找10级目录,找到了.git文件夹就执行 git remote -v 命令,然后github的拼接出来
        getFileLocateUrl $1 $2;;
    -c | c)
        vim $configPath
        exit 0;;
    *)
        readFile "$configPath";;
esac

# TODO 实现终端里的进度条
