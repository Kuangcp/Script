file=$1
g++ `pwd`/$file -o `pwd`/${file%.*}.run
