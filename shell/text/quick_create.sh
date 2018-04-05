if [ $1"z" = "z" ];then
    exit
else
    path=$(cd `dirname $0`; pwd) 
    cp $path'/model.conf' ./$1
    echo "创建 model.sh 成功"
fi

