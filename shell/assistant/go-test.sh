
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
    printf "$format" "-b" "" "benchmark"
}

run_bench(){
    methods=$(ls *.go | xargs cat | grep "func Benchmark" |  sed 's/func //g;s/(.*//g')
    select method in $methods; do
        break;
    done

    printf " Run $method\n"
    echo "go test -v -bench=. -benchtime=3s -run $method  *.go"
}

run_test(){
    methods=$(ls *.go | xargs cat | grep "func Test" |  sed 's/func //g;s/(.*//g')

    select method in $methods; do
        break;
    done

    printf " Run $method\n"

    if test -z $method; then 
        echo "select error"
    else
        go test -v -run $method *.go 
        echo "go test -v -run $method *.go"
    fi 
}

case $1 in 
    -h)
        help ;;
    -b)
        run_bench;;
    *)
        run_test ;;
esac