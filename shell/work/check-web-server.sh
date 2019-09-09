red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

userDir=(`cd && pwd`)
cache_page="$userDir/.config/app-conf/log/healthcheck_status"

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
    printf "Run：$red sh check-web-server.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "h" "" "help"
    printf "$format" "up" "" "update health check page"
    printf "$format" "cnf" "" "open config file"
    printf "$format" "" "" "search any"
}

update_cache(){
    rm -f $cache_page
    curl http://test.status.qipeipu.net/healthcheck_status -o $cache_page > /dev/null 2>&1
    log_info "\n    update: "$cache_page
}


find_ip_by_app(){
    params="$*"
    regex=${params// /.*}
    # echo $regex
    result=$(cat $cache_page | grep "$regex" -A 2)
    count=$(echo $result | wc -w)
    if test $count != 3; then
        log_error "more than one matched"
        echo "$result" | less
        exit 0
    fi
    for line in $result; do
        # log_info $line
        is_title=$(echo $line | grep "$regex")
        # echo "title:["$is_title"]"
        if test -n "$is_title"; then
            printf "\n    "$(remove_td_tag $line)
        fi
        if [[  $line == *'8080'* ]];then
            url=$(remove_td_tag $line)
            printf "  "$url
            printf ${url%:8080*} | xclip -sel clip
        fi
        if [[ $line == *"up"* ]] || [[ $line == *"down"* ]]; then
            echo "  " $(remove_td_tag $line)
        fi
    done
}

remove_td_tag(){
    str=${1/<td>/}
    str=${str/<\/td>/}
    echo $str
}

case $1 in 
    -up|up)
        update_cache
    ;;
    -cnf|cnf)
        less $cache_page
    ;;
    -h|h)
        help 
    ;;
    *)
        if test $# == 0 ;then
            log_error "please input any param \n"
            help
            exit 0
        fi 
        update_cache
        find_ip_by_app $*
    ;;
esac