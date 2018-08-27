help(){
    start='\033[0;32m'
    end='\033[0m'
    printf "运行：dash FileTool.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|h|help" "帮助"
}

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red sh FileTool.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
    printf "$format" "" "" "复制当前路径到粘贴板"
    printf "$format" "-p|p" "dir" "输出文件或目录的绝对路径"
}

case $1 in 
    -h | h)
        help ;;
    -p | p)
        currentPath=`pwd`
        echo $currentPath/$2
    ;;
	-cf | cf)
		cat $2 | xclip -sel clip
	;;
    -f | f)
        find . -iname "*$2*" 
    ;;
    *)
        currentPath=`pwd`
        echo $currentPath/$1 | xsel -b
    ;;
esac
