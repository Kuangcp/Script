red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red sh image_size.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
}


calculate(){
    printf "input width: "
    read width
    printf "input height: "
    read height


    printf "input target width: "
    read targetWidth
    printf "input target height: "
    read targetHeight

    echo ""
    resultWidth=$(expr $height \* $targetWidth / $targetHeight)
    echo 'remain height: width='$resultWidth 'height='$height

    resultHeight=$(expr $width \* $targetHeight / $targetWidth)
    echo 'remain width:  width='$width 'height='$resultHeight
}

case $1 in 
    -h)
        help ;;
    *)
        calculate
    ;;
esac