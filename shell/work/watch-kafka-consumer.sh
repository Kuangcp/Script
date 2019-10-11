red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

other_threshold=200
warn_threshold=10
log_threshold=1
pid=$$
userDir=(`cd && pwd`)

cache_dir="$userDir/.config/app-conf/log/ofc_kafka_topic"
url=' '
consumers_log=" "

icon_file='/home/kcp/Application/Icon/warning-circle-yellow.svg'
total_consumer_url='http://kafka-manager.qipeipu.net/clusters/online/consumers'

init_config(){
    consumer=${url%%/*}
    consumers_log="$cache_dir/consumer-$consumer.log"
}

remove_td_tag(){
    str=${1/<td>/}
    str=${str/<\/td>/}
    echo $str
}

watch_consumer(){
    url=$1
    consumer=$2
    cache_file="$cache_dir/consumers-$consumer.html"
    curl $total_consumer_url/$url -o "$cache_file" > /dev/null 2>&1
    origins=$(cat $cache_file | grep " 100" -A 2 -B 4)
    date_str=$(date +%y-%m-%d_%H:%M:%S)
    has_lag=0
    app=''
    topic=''
    count=0

    for line in $origins; do
        if [ $line = '--' ]; then
            continue
        fi
        count=$((count+1))
        # echo "==   $count $line"
        if test $count = 2; then
            # echo "=== $count $line"
            temp=${line#*topic/}
            temp=${temp%%\/*}
            topic=$temp
        fi
        if test $count = 8; then
            line=$(remove_td_tag $line)
            # echo "=== $count $line"
            if test $line -gt $log_threshold; then
                has_lag=1
                printf "%s  %-25s %-50s " $date_str $consumer $topic >> $consumers_log
                printf "%s\n" "$line"  >> $consumers_log
            fi
            if test $line -gt $warn_threshold; then
                msg="$topic : $line"
                notify-send -i $icon_file "$msg" -t 3000
            fi
        fi
        if test $count = 8; then
            count=0
        fi
    done
    
    if test $has_lag = 1; then
        printf "\n"  >> $consumers_log
    else
        printf "%s \n" $date_str >> $consumers_log
    fi
}

watch_ofc(){
    url='btr-ofc-service-online/type/KF'
    init_config
    watch_consumer $url $consumer
}

case $1 in 
    -h|h)
        help 
    ;;
    l)
        url='btr-ofc-service-online/type/KF'
        init_config
        less $consumers_log
    ;;
    ln)
        url='btr-ofc-service-online/type/KF'
        init_config
        less -N $consumers_log
    ;;
    ofc)
        while true; do
            watch_ofc
            sleep 5;
        done
    ;;
    d)
        last_pid=$(ps aux | grep  "watch-kafka-consumers.sh a" | grep -v grep | awk '{print $2}')
        log_error "killed $last_pid"
        kill $last_pid
    ;;
    *)
        help
        
    ;;
esac