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

summary_commit_msg(){
    # ollama + deepseek 7b 模型
    prepare_commit=$(git diff --cached)
    prompt='现在需要对一个Git仓库做提交，以下是这次提交的diff格式修改内容，请用英文做一句话总结，无需列出修改文件，总结出修改的范围和目的，用于commit message。'
    ollama run deepseek-r1  "${prompt} 修改内容：${prepare_commit}" > /tmp/dp.git.msg
    # cat /tmp/dp.git.msg | sd '\n' '' | sd '.*</think>' ''
    cat /tmp/dp.git.msg | sd '\n' '@@@' | sd '.*</think>' '' | sd '@@@@@@' '' | sd '@@@' '\n'
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
        for i in $(seq 0 $(($2-1))); do 
            startDate=$(date -d "$(($i+1)) day ago" +"%Y-%m-%d")

            # echo "git log --oneline --decorate --stat $au --since='$(($i+1)) day ago' --until='$i day ago' | grep 'changed, '"

            data=$(git log --oneline --decorate --stat $au --since="$(($i+1)) day ago" --until="$i day ago" | grep "changed, ")
            add=$(echo "$data" | awk '{print $4}' | grep -v " " | awk '{sum += $1};END {print sum}')
            del=$(echo "$data" | awk '{print $6}' | grep -v " " | awk '{sum += $1};END {print sum}')

            if test $add -gt 0 || test $del -gt 0 ; then 
                printf "$cyan$startDate$end add:$green%-6s$end del:$red%-6s$end\n" $add $del 
            fi 
        done 
    ;;
    -msg)
        summary_commit_msg
    ;;
    -h)
        help ;;
    *)
        help ;;
esac