# 获取当前用户默认shell类型, 写入到对应的配置文件中去

if [ $1'z' = 'z' ];then
    echo '请在脚本后带上 $0 参数'
    exit 1
else
    path=$(cd `dirname $0`; pwd)
    type=`echo $1 | cut -d / -f 4`
    if [ $type = 'zsh' ];then
        type='zsh'
    else
        type=$1
    fi
    echo $type
    echo "alias kh='sh "$path"/mythsdk.sh'" >> ~/.${type}rc
    $type ~/.${type}rc
fi
