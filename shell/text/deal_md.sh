# 在脚本旁边建立 local.conf文件 并添加以下配置
# 笔记的仓库路径, 而且最后留一行空行  config_target_repo='/home/kcp/Documents/Notes/Notes'

path=$(cd `dirname $0`; pwd)
# 忽略文件目录
config_ignore_file=$path'/ignore.ini'
# 脚本文件目录

# markdown_handle_script=${path%%shell*}'python/append_contents.py'
# markdown_handle_script=$path'/append_catalog.sh'

# 读取本地配置文件 初始化 config_target_repo
while read line;do  
    eval "$line"  
done < "$path"/local.conf

generate_catalog(){
    bash $path'/append_catalog.sh' "$1"
}

read_dir(){
    # 递归阅读文件, 然后更新md文件的目录
    for file in `ls $1`;do
        if [ -d $1"/"$file ]; then
            read_dir $1"/"$file
        else
            # 判断当前文件是否属于忽略文件 是则文件名否则空
            ignore_file=`cat $config_ignore_file | grep $file`
            # 判断文件名是否符合正则,负责则文件名否则空
            type=`echo $file | grep .*md$`
            # 不是忽略文件并且文件名符合要求
            if [ "$ignore_file"z = "z" ] && [ "$type"z != "z" ]; then 
                printf ">>>>>> \033[0;32m%s\033[0m" $file
                # result=`bash $markdown_handle_script $1'/'$file`
                result=$(generate_catalog $1'/'$file)
                printf "$result\n"
            fi 
        fi
    done
}

case $1 in 
    -h | h | help)
        start='\033[0;32m'
        end='\033[0m'
        printf "%-20s$start%-20s$end\n" "运行：bash $0 " "<options>"
        printf "  $start%-20s$end%-20s\n" "-h|h|help" "输出帮助信息"
        printf "  $start%-20s$end%-20s\n" "<file>" "更新指定文件索引目录 "
        printf "  $start%-20s$end%-20s\n" "-c|c|current" "更新当前目录所有md文件的索引目录"
        printf "  $start%-20s$end%-20s\n" "-a|a|all" "更新指定目录下所有md文件的索引目录"
		# printf "\t\t>> 建议 add文件 后执行,不然就可能出现重复执行的情况了<<\n"
        printf "  $start%-20s$end%-20s\n" "-al|al|alter" "更新指定Git仓库下修改过的md文件的索引目录";;
    -c | c | current)
        files=`ls *.md`
        for file in $files;do 
            if test -f $file; then
                printf "current dir:" 
                # result=`bash $markdown_handle_script  $file`
                result=$(generate_catalog $file)
                printf "%s\n" "$result"
            fi
        done;;
    -a | a | all)
        printf "开始更新全部, 目录: %s\n" "$config_target_repo"
        read_dir $config_target_repo;;
    -al | al | alter)
        printf "更新已修改文件, 目录: %s\n" "$config_target_repo"
        result=`cd $config_target_repo && git status -s`
        # 使用标志变量, 前缀为修改或者新增的行 才能进行更新, 每个文件都判断一次并更新这个标志变量一次
        change_flag=0 
        for line in $result;do
            # echo ">>"$line
            if [ `echo $line | grep -E "^[A|M]+$|^\?\?$"` ]; then
                change_flag=1
            fi
            map_result=`echo "$line" | grep ".md"`
            if [ "$map_result"z != 'z' ]; then
                if [ $change_flag = 1 ]; then
                    ignore=`cat $config_ignore_file`
                    ignore_file=`echo $map_result | grep "$ignore" `
                    if [ "$ignore_file"z = "z" ];then
                        printf "\033[0;32m modify: \033[0m" 
                        # result=`bash $markdown_handle_script  $config_target_repo/$map_result`
                        result=$(generate_catalog $config_target_repo/$map_result)
                        printf "$result\n"
                    fi
                fi
                change_flag=0
            fi
        done;;
    *)
        # 没有参数的时候, 就是单文件的更新
        # printf "[%s]" $1
        # 过滤掉 - 的字符串 , 将Python脚本的输出存放到变量中
        # result=`bash $markdown_handle_script $1`
        result=$(generate_catalog $1)
        printf "$result\n";;
esac