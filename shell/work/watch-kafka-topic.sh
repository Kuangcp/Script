red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

userDir=(`cd && pwd`)
cache_page="$userDir/.config/app-conf/log/ofc_kafka_topic"
log_file="$userDir/.config/app-conf/log/ofc_kafka_topic/total.log"
icon_file='/home/kcp/Application/Icon/Stream.svg'

topics='OFC_PURCHASE_FINISH OFC_DATA_TRACK OFC_PURCHASE IM_YUN_XIN_CC_MESSAGE_FOR_BIZ'

pid=$$

log(){
    printf " $1\n"
}
log_error(){
    printf `date +%y-%m-%d_%H:%M:%S`"$red $1 $end\n" 
}
log_info(){
    printf `date +%y-%m-%d_%H:%M:%S`"$green $1 $end\n" 
}
log_warn(){
    printf `date +%y-%m-%d_%H:%M:%S`"$yellow $1 $end\n" 
}

help(){
    printf "Run：$red sh watch-kafka-topic.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "h" "" "help"
    printf "$format" "" "" "search any"
}

update_cache(){
    topic=$1
    rm -f $cache_page/$topic
    curl http://kafka-manager.qipeipu.net/clusters/online/consumers/ofc-service-online/topic/$topic/type/ZK -o $cache_page/$topic > /dev/null 2>&1
    log_info "   update: "$cache_page/$topic
}

remove_td_tag(){
    str=${1/<td>/}
    str=${str/<\/td>/}
    echo $str
}

check_topic_total_lag(){
    topic=$1
    page=$cache_page/$topic
    result=$(cat $page | grep Total -A 1)
    count=0
    for line in $result; do
        count=$((count+1))
        if test $count = 3;then
            # echo $count"---------"$line
            num=$(remove_td_tag $line)
            # printf "%s $yellow%-40s  %3s $end\n" `date +%y-%m-%d_%H:%M:%S` "$topic" "$num"
            printf "%s $yellow%-40s  %3s $end\n" `date +%y-%m-%d_%H:%M:%S` "$topic" "$num"  >> $log_file
            if test $num  -gt 1; then
                msg="$topic has lag $num"
                notify-send -i $icon_file "$msg" -t 3000
            fi
        fi
    done
}

check_topic_detail_lag(){
    topic=$1
    page=$cache_page/$topic
    cat $page | grep Total -A 1
    # result=$(cat $page | grep Total -A 1)
    # count=0
    # for line in $result; do
    #     count=$((count+1))
    #     if test $count = 3;then
    #         # echo $count"---------"$line
    #         num=$(remove_td_tag $line)
    #         printf "%s $yellow%-40s  %3s $end\n" `date +%y-%m-%d_%H:%M:%S` "$topic" "$num"
            
    #         # printf "%s $yellow%-40s  %s $end\n" `date +%y-%m-%d_%H:%M:%S` "$topic" "$num"  >> $log_file
    #         if test $num  -gt 1; then
    #             msg="$topic has lag $num"
    #             notify-send -i $icon_file "$msg" -t 3000
    #         fi
    #     fi
    # done
}

watch_ofc_topic(){
    for topic in $topics; do
        update_cache $topic
        check_topic_total_lag  $topic 
        # check_topic_detail_lag  $topic 
    done
}


case $1 in 
    -h|h)
        help 
    ;;
    log)
        less $log_file
    ;;
    *)
        for i in $(seq 1 10000); do
            watch_ofc_topic
            sleep 3;
        done
    ;;
esac
