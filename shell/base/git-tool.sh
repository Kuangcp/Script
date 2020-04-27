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
    -s)
        if test -z "$2"; then 
            exit 1;
        fi
        au=''
        if test -n "$3"; then 
            au="--author=$3"
        fi
        echo $au
        for i in $(seq 0 $2); do 
            startDate=$(date -d "$(($i+1)) day ago" +"%Y-%m-%d")

            data=$(git log --oneline --decorate --stat $au --since="$(($i+1)) day ago" --until="$i day ago" | grep "files changed")
            add=$(echo "$data" | awk '{print $4}' | awk '{sum += $1};END {print sum}')
            del=$(echo "$data" | awk '{print $6}' | awk '{sum += $1};END {print sum}')

            printf "$cyan$startDate$end add:$green%-6s$end del:$red%-6s$end\n" $add $del 
        done 
    ;;
    -h)
        help ;;
    *)
        help ;;
esac