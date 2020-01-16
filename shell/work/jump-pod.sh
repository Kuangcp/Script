#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red sh $0 $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
}

find_pod(){
    params=${*}
    regex=${params// /.*}

    list=$(kubectl --namespace docker$1 get pods |grep $regex | grep -v Ter)
    match_num=$(kubectl --namespace docker$1 get pods |grep $regex | grep -v Ter| wc -l)
    if test $match_num != 1; then
        printf "$red    server not sepcified! $end\n"

        echo "$list"
        exit 0
    fi

    echo "${list}" | cut -d " " -f 1
}

case $1 in 
    -h)
        help ;;
    -i)
        pod=$(find_pod ${*:2})
        num=$(echo "$pod" | wc -l)
        if test $num = 1; then 
            printf "\n$green     enter pod: $pod $end \n\n"
            kubectl --namespace docker$2 exec -it $pod -- /bin/bash
	    else
	        echo "$pod"
	    fi
    ;;
    *)
        if test $# = 0; then
            printf "$red please input param $end\n"
            help
            exit 0
        fi

        pod=$(find_pod ${*:1})
        num=$(echo "$pod" | wc -l)
        if test $num = 1; then 
            printf "\n$green     enter pod: $pod $end \n\n"
            kubectl --namespace docker$1 exec -it $pod -- /bin/bash
	    else
	        echo "$pod"
	    fi

        # kubectl --namespace docker$1 exec -it $pod -- /bin/bash
        # kubectl describe --namespace=docker33 pod  btr-im-publish-77d47978ff-b9zqn
        # kubectl logs --namespace=docker33 btr-im-publish-77d47978ff-b9zqn
    ;;
esac
