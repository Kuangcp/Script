
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red sh mergets.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "help"
    printf "$format" "" "url" "url of m3u8, start download"
}

case $1 in
    -h)
        help ;;
    *)
        file=$(date +%F_%T).mp4
        ffmpeg -i $1 -c copy -bsf:a aac_adtstoasc $file
        echo "\n\n\tfinished $file \n\n"
    ;;
esac



