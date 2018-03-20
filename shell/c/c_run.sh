file=$1
if [ "$1" = "" ];then
	exit
fi

# 编译
g++ `pwd`/$file -o `pwd`/${file%.*}.run
# 执行
`pwd`/${file%.*}.run
