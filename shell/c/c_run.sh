file=$1
if [ "$1" = "" ];then
	exit
fi

# 编译
g++ `pwd`/$file -o `pwd`/run.${file%.*}.run
# 执行
`pwd`/run.${file%.*}.run
