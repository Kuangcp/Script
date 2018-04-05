help(){
    start='\033[0;32m'
    end='\033[0m'
    printf "运行：dash file_tool.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|h|help" "帮助"
}

case $1 in 
    -h | h | help)
        help
    ;;
    -p | p)
        currentPath=`pwd`
        echo $currentPath/$2
    ;;
    *)
        currentPath=`pwd`
        echo $currentPath/$1 | xsel -b
    ;;
esac