red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

log(){
    printf "`date +%y-%m-%d_%H:%M:%S`: $1 $end\n"
}
log_error(){
    printf "`date +%y-%m-%d_%H:%M:%S`: $red $1 $end\n" 
}
log_info(){
    printf "`date +%y-%m-%d_%H:%M:%S`: $green $1 $end\n" 
}
log_warn(){
    printf "`date +%y-%m-%d_%H:%M:%S`: $yellow $1 $end\n" 
}

help(){
    printf "Run：$red sh GitTool.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "help"
    printf "$format" "-dc" "one [other]" "diff content between branch, other empty then default current branch"
}

diff_branch(){
    git log --pretty=oneline  $1...$2 | awk '{print $1}' | xargs git show
}

case $1 in 
    -dc)
    # TODO validate branch is correct
        if [ $2'z' = 'z' ];then 
            log_error "must select one branch"
            exit 1;
        fi
        diff_branch $2 $3
    ;;
    -h)
        help ;;
    *)
        help ;;
esac