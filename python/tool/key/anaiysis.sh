path=$(cd `dirname $0`; pwd)

if [ $1'z' = '-hz' ];then
    python3 $path/Analysis.py -h
    exit
fi
if [ $1'z' = '-bz' ] && [ $2'z' = 'z' ];then
    echo '请输入第二个参数'
    exit
fi
python3 $path/Analysis.py $1 $2 | less