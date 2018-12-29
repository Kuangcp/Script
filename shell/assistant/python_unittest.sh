red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red sh python_unittest.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
}

# TODO 实现的功能 读取 Python 单元测试文件, 识别出其中的测试类, 测试方法, 然后交互式使用户选择运行哪个方法, 类


case $1 in 
    -h)
        help ;;
    *)
        help ;;
esac
