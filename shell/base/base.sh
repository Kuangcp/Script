# config base, and init some method

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

grey='\033[3;37;40m'

log(){
    printf "$1 $2\n"
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

log_t(){
    printf "`date +%F_%T`: $1 $end\n"
}
log_error_t(){
    printf "`date +%F_%T`: $red $1 $end\n" 
}
log_info_t(){
    printf "`date +%F_%T`: $green $1 $end\n" 
}
log_warn_t(){
    printf "`date +%F_%T`: $yellow $1 $end\n" 
}

assertParamCount(){
    actual=$1
    expect=$2
    if [ ! $1 = $2 ]; then
        log_error "please input correct param count: $2"
        exit 1
    fi
}
