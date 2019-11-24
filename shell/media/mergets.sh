
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

url_decode(){
    url=$1
    printf $(echo -n $url | sed 's/\\/\\\\/g;s/\(%\)\([0-9a-fA-F][0-9a-fA-F]\)/\\x\2/g')
}

download(){
    url=$(url_decode $1)
    current=$2
    file="$current.mp4"

    echo "$file $url" >> download.log
    ffmpeg -i $url -headers $'\r\n' -c copy -bsf:a aac_adtstoasc $file
    log_info "\n\n\tfinished $file \n\n"
}

help(){
    printf "Run：$red sh mergets.sh $green<verb> $yellow<args>$end\n"
    printf "\nDescription:\n\t  Download .ts file and merge as .mp4.\n\n"
    format="  $green%-4s $yellow%-6s$end%-20s\n"
    printf "$format" "-h" "" "help"
    printf "$format" "-du" "" "decode url "
    printf "$format" "" "url" "url of m3u8 file"
}

case $1 in
    -h)
        help ;;
    -du)
        url=$(url_decode $2)
        log_info $url
    ;;
    *)
        if test $# -lt 1;then
            log_error 'Input valid URL'
            exit 0
        fi
        current=$(date "+%Y%m%d-%H%M%S")
        (download $1 $current &) > $current.log 2>&1
    ;;
esac

