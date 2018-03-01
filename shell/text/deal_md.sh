# 忽略文件目录
config_ignore_file='/home/kcp/Application/Script/shell/text/ignore.conf'
# 脚本文件目录
config_python_file='/home/kcp/Application/Script/python/append_contents.py'
# md的仓库
config_target_repo='/home/kcp/Documents/Notes/Notes'

read_dir(){
    ''' 递归阅读文件, 然后更新md文件的目录 '''
    for file in `ls $1`
    do
        if [ -d $1"/"$file ]  #注意此处之间一定要加上空格，否则会报错 
        # 这里是判断是否是文件夹,文件夹就进入 
        then
            read_dir $1"/"$file
        else
            # 判断当前文件是否属于忽略文件 是则文件名否则空
            ignore_file=`cat $config_ignore_file | grep $file`
            # 判断文件名是否符合正则,负责则文件名否则空
            type=`echo $file | grep .*md$`
            # 不是忽略文件并且文件名符合要求
            if [ "$ignore_file"z = "z" ] && [ "$type"z != "z" ]; then 
                printf ">>>>>>%s" $file
                result=`python3 $config_python_file  -a n $1'/'$file`
                printf "$result\n"
            fi 
        fi
    done
}

case $1 in 
    -h | h | help)
        start='\033[0;32m'
        end='\033[0m'
        printf "%-20s$start%-20s$end\n" "运行：bash deal_md.sh " "<options>"
        printf "  $start%-20s$end%-20s\n" "-h|h|help" "输出帮助信息"
        printf "  $start%-20s$end%-20s\n" "<file>" "更新指定文件索引目录 "
        printf "  $start%-20s$end%-20s\n" "-c|c|current" "更新当前目录所有md文件的索引目录"
        printf "  $start%-20s$end%-20s\n" "-a|a|all" "更新指定目录下所有md文件的索引目录"
		# printf "\t\t>> 建议 add文件 后执行,不然就可能出现重复执行的情况了<<\n"
        printf "  $start%-20s$end%-20s\n" "-al|al|alter" "更新指定Git仓库下修改过的md文件的索引目录";;
    -c | c | current)
        files=`ls *.md`
        for file in $files
        do 
            if test -f $file; then
                printf "[%s]" $file
                result=`python3 $config_python_file -a n $file`
                printf "%s\n" "$result"
            fi
        done;;
        
    -a | a | all)
        printf "开始更新全部, 目录: %s" "$config_target_repo"
        read_dir $config_target_repo;;

    -al | al | alter)
        result=`cd $config_target_repo && git status`
        # 使用标志变量, 前缀为修改或者新增的行 才能进行更新, 每个文件都判断一次并更新这个标志变量一次
        change_flag=0 
        for line in $result
        do
            # echo "初始化"$change_flag
            # echo ">>"$line
            # 当前行出现了 修改 或者 新增 或者 -> (表示重命名) 任一,才会更新下面出现的md文件
            if [ `echo $line | grep -E "(修改)+|(新文件)+|(->)+"` ]; then
                change_flag=1
            fi
            map_result=`echo "$line" | grep ".md"`
            # echo "判断后"$change_flag
            
            if [ "$map_result"z != 'z' ]; then
                if [ $change_flag = 1 ]; then
                    # 下面这种方式只能完全匹配不能局部匹配
                    # ignore_file=`cat $config_ignore_file | grep $map_result`
                    ignore=`cat $config_ignore_file`
                    ignore_file=`echo $map_result | grep "$ignore" `
                    # echo "::::"$map_result
                    if [ "$ignore_file"z = "z" ];then
                        printf "\033[0;32m 修改 : "$map_result"\033[0m"
                        result=`python3 $config_python_file -a n $config_target_repo/$map_result`
                        printf "$result\n"
                    fi
                fi
                change_flag=0
            fi
            # echo "恢复"$change_flag
        done;;
    *)
        printf "[%s]" $1
        # 过滤掉 - 的字符串 , 将Python脚本的输出存放到变量中
        result=`python3 $config_python_file -a n $1`
        printf "$result\n";;
esac

# 2018-01-22 23:11:14
# 解决了一个更新删除和重命名的文件的目录的错误