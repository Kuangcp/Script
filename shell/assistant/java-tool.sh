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
    format="  $green%-3s $yellow%-20s$end%-20s\n"
    printf "$format" "-h" "" "help"
    printf "$format" "" "pid" "select java pid to show stack"
    printf "$format" "-a" "" "select java pid to show stack"
    printf "$format" "-t" "pid" "show cpu active thread stack"
    printf "$format" "-w" "interval loopCount" "jstack to log"
}

javaPid=''
select_java_pid(){
    select appname in $(jps | sed 's/ /　/'); do
        log_info "you choose is $appname"
        break
    done
    javaPid=${appname%%　*}
}

show_stack_of_process(){
    select_java_pid
    pid=$javaPid
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

watch_pid_stack(){
    shift
    interval=$1
    loop=$2
    # 默认值
    if ! test $loop ; then 
        loop=100
    fi
    if ! test $interval; then 
        interval=1
    fi 

    select_java_pid

    for i in $(seq 1 $loop); do 
        sleep $interval
        if [ -d /proc/$javaPid ]; then 
            name=$(date +%T　%N)
            echo "jstack cmd $i $name"
            jstack $javaPid > "${appname}　$name.log"
        else
            log_warn "pid $javaPid not exist"
            exit
        fi
    done 
}

# jps sk 
# ps cat awk 
active_cpu_thread(){
    pid=$1
    if [ x$pid = "x" ] ; then 
        pid=$(jps | sk | awk '{print $1}')
    fi

    if [ x$pid = "x" ] ; then
        log_warn "please select java pid"
        exit
    fi

    log_info "show $pid :"

    tids=""
    while read -r line; do
        echo $line 
        tids="$tids "$(echo $line | awk '{print $2}')
    done <<< "$(ps -mp $pid -o %cpu,tid,time | sort -k1r | grep -v TID | grep -v -E '0\.0.*')"
    
    echo ""
    regx=""
    for tid in $tids; do 
        txid=$(printf %x $tid)
        # echo $tid $txid 
        regx="$regx|($txid)"
    done 
    regx=${regx:1}
    # echo $regx
    jstack $pid > /tmp/$pid-active-jstack.log
    active=0
    cat /tmp/$pid-active-jstack.log | while read line; do
        # echo "line: "$line;
        if [[ $line = \"* ]]; then 
            c=$(echo $line | grep -E "$regx")
            if [ "x$c" = "x" ]; then 
                active=0
            else
                active=1
                echo "$line"
            fi
        else 
            if [ $active = 1 ]; then 
                echo "    $line"
            fi 
        fi 
    done
}

force_full_gc(){
    pid=$1
    if [ "x$pid" = 'x' ];then 
        pid=$(jps | sk | awk '{print $1}')
    fi 
    if [ "x$pid" = 'x' ];then 
        echo 'Must select java pid'
        return
    fi 
    echo $pid > /tmp/force_full_gc.pid
    echo "jcmd $pid GC.run"
    jcmd $pid GC.run
}

case $1 in 
    -h)
        help 
    ;;
    -w)
        watch_pid_stack $*
    ;;
    -t)
        active_cpu_thread $2
    ;;
    -gc)
        force_full_gc
    ;;
    -gcl)
        if [ -f /tmp/force_full_gc.pid ]; then 
            force_full_gc $(cat /tmp/force_full_gc.pid)
        else
            echo 'no last history'
        fi 
    ;;
    -a)
        show_all_java_process
    ;;
    *)
        show_stack_of_process
    ;;
esac