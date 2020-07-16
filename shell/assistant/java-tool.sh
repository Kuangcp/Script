red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

stack_file='/tmp/java-stack'
ppid_file='/tmp/java-stack-ppid'

log(){
    printf " $1\n"
}
log_error(){
    printf "$red $1 $end\n" 
}
log_info(){
    printf "$green $1 $end\n" 
}
log_warn(){
    printf "$yellow $1 $end\n" 
}

help(){
    printf "Run：$red sh java-tool.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
    printf "$format" "" "pid" "select java pid to show stack"
    printf "$format" "-a" "" "select java pid to show stack"
}

show_stack_of_process(){
    pid=$1
    if test -z $pid; then
        log_error "pid can not be null"
        exit
    else
        log_info "checking pid $pid ..."
    fi

    if test -z "$(jps -l | cut -d '' -f 1 | grep $pid)"; then
        log_error "java process $pid is not exist"
        exit
    fi

    jstack $pid > $stack_file
    ps -mp $pid -o THREAD,tid,time | sort -k2r | awk '{if ($1 != "USER" && $2 != "0.0" && $8 != "-") print $8;}' | xargs printf "%x\n" > $ppid_file

    tidArray="$(cat $ppid_file)"
    for tid in $tidArray; do
        blockStartFlag=0
        cat $stack_file | while read line; do
            regexResult=$(echo "$line" | grep -e " #.*tid=.*nid=0x${tid}")
            if test "$regexResult" != ""; then
                blockStartFlag=1
                log_info "$line"
                continue
            fi
            if test "$(echo "$line" | grep -e " #.*tid=.*nid=0x.*")" != "" && test $blockStartFlag = 1; then
                blockStartFlag=0
                break
            fi
            if test $blockStartFlag = 1; then
                echo "$line"
            fi
        done
    done
    rm -f $stack_file
    rm -f $ppid_file
}

show_all_java_process(){
    result=$(jps)
    # printf "\n$result\n\n"
    lineNum=0
    echo "$result" | while read line; do
        lineNum=$(( $lineNum + 1 ))
        printf "    $red%s$end %s \n" $lineNum "$line"
    done

    log_info "Please select the java process: "
    read tempNum

    tempCount=0
    echo "$result" | while read line; do
        tempCount=$(( $tempCount + 1 ))
        if test $tempCount = $tempNum; then 
            pid=$(echo "$line" | awk '{print $1}')
            log_warn "select $pid"
            show_stack_of_process $pid
            exit
        fi
    done
}

case $1 in 
    -h)
        help ;;
    -a)
        show_all_java_process
    ;;
    *)
        show_stack_of_process $1
    ;;
esac