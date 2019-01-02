red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

alias py='/usr/bin/python3'

help(){
    printf "Run：$red sh python_unittest.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-10s $yellow%-12s$end%-20s\n"
    printf "$format" "-h" "" "help"
    printf "$format" "filename" "[testcase]" "show all testcase when testcase is empty otherwise run test case"
}

# TODO 实现的功能 读取 Python 单元测试文件, 识别出其中的测试类, 测试方法, 然后交互式使用户选择运行哪个方法, 类

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
read_content(){
    filename=$1
    class_name=''
    cat $filename | while read line; do
        class_define=$(echo "$line" | grep -E "^class\s.*\(.*TestCase\):$")
        if [ ! "$class_define"z = 'z' ]; then
            temp=${line#*class}
            class_name=${temp%%(*}
            printf "\n%s\n" $class_name
        fi
        # echo "$line"
        method_define=$(echo "$line" | grep -E "^.*def\stest.*\(self\):$")
        # echo $method_define
        if [ ! "$method_define"z = 'z' ];then
            temp=${line#*def}
            method_name=${temp%%(*}
            printf "%s.%s\n" $class_name $method_name
        fi
    done
}
case $1 in 
    -h)
        help ;;
    *)
        if [ $# = 0 ];then
            log_error "please specific python script file"
            exit
        fi
        filename=$1
        if [ $# = 1 ];then
            read_content $filename
        else
            file_name=${filename%%.py*}
            py -m unittest $file_name.$2 
        fi
    ;;
esac
