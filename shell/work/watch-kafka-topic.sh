red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

total_consumer_url='http://kafka-manager.qipeipu.net/clusters/online/consumers'

userDir=(`cd && pwd`)
cache_dir="$userDir/.config/app-conf/log/ofc_kafka_topic"
log_file="$cache_dir/total.log"
man_log_file="$cache_dir/man-total.log"

icon_file='/home/kcp/Application/Icon/warning-circle-yellow.svg'

topics='OFC_PURCHASE_FINISH OFC_DATA_TRACK 
OFC_PURCHASE_ORDER_CREATED 
OFC_PACKAGE_DELIVERY 
OFC_PREAPARE_QUTE_CREATE_SUPPLIER_ORDER 
OFC_SUB_SALE_ORDER 
OFC_CANCEL_ORDER_MONITOR 
OFC_SUPPLIER_ORDER_CREATED 
OFC_PURCHASE_ORDER_PROCESSED 
OFC_PURCHASE_REPRICE 
OFC_PACKAGE_RECEIVE 
OFC_PACKAGE_PACK 
OFC_GENERATE_ORDER 
OFC_ORDER_PAID 
IM_YUN_XIN_CC_MESSAGE_TO_ADMIN 
OFC_PURCHASE IM_YUN_XIN_CC_MESSAGE_FOR_BIZ 
LOGISTICS_PARTS_TRACK 
quote_quoteResultPushErp 
inquiry 
oms_order_process '

warn_threshold=10
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
    rm -f $cache_dir/$topic
    curl http://kafka-manager.qipeipu.net/clusters/online/consumers/ofc-service-online/topic/$topic/type/ZK -o $cache_dir/$topic > /dev/null 2>&1
    log_info "   update: "$cache_dir/$topic
}

remove_td_tag(){
    str=${1/<td>/}
    str=${str/<\/td>/}
    echo $str
}

check_topic_total_lag(){
    topic=$1
    page=$cache_dir/$topic
    result=$(cat $page | grep Total -A 1)
    count=0
    for line in $result; do
        count=$((count+1))
        if test $count = 3;then
            # echo $count"---------"$line
            num=$(remove_td_tag $line)
            # printf "%s $yellow%-40s  %3s $end\n" `date +%y-%m-%d_%H:%M:%S` "$topic" "$num"
            printf "%s %-40s  %3s \n" `date +%y-%m-%d_%H:%M:%S` "$topic" "$num"  >> $log_file
            mo_num=$(echo $num | sed 's/,//g')
            if test $mo_num -gt $warn_threshold; then
                msg="$topic : $num"
                notify-send -i $icon_file "$msg" -t 3000
            fi
        fi
    done
}

check_topic_detail_lag(){
    topic=$1
    page=$cache_dir/$topic
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


watch_total_topic(){
    curl $total_consumer_url -o $cache_dir/$topic > /dev/null 2>&1
    
}

watch_ofc_topic(){
    for topic in $topics; do
        update_cache $topic
        check_topic_total_lag  $topic 
        # check_topic_detail_lag  $topic 
    done
    printf "\n"  >> $log_file
}


case $1 in 
    -h|h)
        help 
    ;;
    log)
        less $log_file
    ;;
    a)
        watch_total_topic
    ;;
    *)
        while true; do
            watch_ofc_topic
            sleep 2;
        done
    ;;
esac
