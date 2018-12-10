red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

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
    printf "Run：$red sh append_catalog.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
}

transfer_link(){
    title=$1
    echo $title
}
case $1 in 
    -h)
        help ;;
    *)
        if [ $# = 0 ];then
            log_error "empty param"
            exit 1
        fi
        log_info "handling file: "$1
        # cat $1 | grep -E "^(#){1,6}" | awk '{print $1" 1.["$2"]()"}' |  sed 's/#/    /g'
        cat $1 | grep -E "^(#){1,6}" | gawk 'function transfer(){
            printf "[%s](%s)\n",$1,$1;
        }BEGIN{ FS="\n";RS=" "}{
            transfer()
        }' |  sed 's/#/    /g'

        ;;
esac
