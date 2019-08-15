path=$(cd `dirname $0`; pwd)
. $path/base.sh

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
        if test -z $2; then 
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