path=$(cd `dirname $0`; pwd)
. $path/base.sh

assertParamCount(){
    actual=$1
    expect=$2
    if [ ! $1 = $2 ]; then
        log_error "please input correct param count: $2"
        exit 1
    fi
}

help(){
    printf "Run：$red sh DockerTool.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-3s $yellow%-6s$end%-20s\n"
    printf "$format" "-h" "" "help"
    printf "$format" "-l" "image" "list docker image all tags"
}

list_image_tags(){
    image=$1
    curl -s "https://registry.hub.docker.com/v1/repositories/${image}/tags" | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n' | awk -F: '{print $3}' | column
}

case $1 in 
    -h|h)
        help ;;
    -l|l)
        assertParamCount $# 2
        list_image_tags $2 ;;
    *)
        help ;;
esac