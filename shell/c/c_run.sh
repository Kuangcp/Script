file=$1
# 编译
g++ `pwd`/$file -o `pwd`/${file%.*}.run
# 执行
`pwd`/${file%.*}.run
