# Shell 版 处理Md文件的目录
# TODO 读取到文件的标题
readFile(){
    filePath=$1;
    i=0
    indexList=(0)
    cat $filePath | while read line;do
        # echo "$line"
        i=$(( $i + 1 ))
        echo $i"  "${#indexList}
        indexList[$i]=111
    done
}
case $1 in 
    -h|-help)
        help
    ;;
    *)
        readFile $1
        echo ${indexList[*]}
    ;;
esac