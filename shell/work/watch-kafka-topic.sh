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
consumers_page="$cache_dir/consumers-page.html"
consumers_log="$cache_dir/consumers.log"

icon_file='/home/kcp/Application/Icon/warning-circle-yellow.svg'

topics='OFC_PURCHASE_FINISH OFC_DATA_TRACK '

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
    curl $total_consumer_url -o $consumers_page > /dev/null 2>&1
    origins=$(cat $consumers_page | grep -v "(0% coverage" | grep -v "unavailable" | grep "lag" -B 2)
    
    app=''
    topic=''
    count=0
    for line in  $origins; do
        # echo "===="$line
        count=$((count+1))
        if test $count = 2; then
            temp=${line#*consumers\/}
            temp=${temp%//type*}
            app=${temp%%/topic*}
            topic=${temp#*topic/}
            topic=${topic%%/type*}
        fi
        if test $count = 5; then
            # echo $line
            if  [ ! $(echo $temp | grep -v "KF") = "" ]; then
                # echo 8888888888 $temp
                if test $line -gt $warn_threshold; then
                    printf "%s %-30s %-50s " `date +%y-%m-%d_%H:%M:%S` $app  $topic >> $consumers_log
                    printf "$line\n"  >> $consumers_log
                    msg="$topic : $line"
                    notify-send -i $icon_file "$msg" -t 3000
                fi
            fi
        fi 
        if test $count = 7; then
            count=0
        fi
    done
    printf "\n"  >> $consumers_log
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
    la)
        less $consumers_log
    ;;
    a)
        while true; do
            watch_total_topic
            sleep 2;
        done
    ;;
    *)
        while true; do
            watch_ofc_topic
            sleep 2;
        done
    ;;
esac
