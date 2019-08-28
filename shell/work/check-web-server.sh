red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'


cache_page='~/.config/app-conf/log/healthcheck_status'

help(){
    printf "Run：$red sh $0 $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
}

update_cache(){
    curl http://test.status.qipeipu.net/healthcheck_status -o $cache_page
}

case $1 in 
    -up)
        update_cache
    ;;
    -h)
        help ;;
    *)
        help ;;
esac