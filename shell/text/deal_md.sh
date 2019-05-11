path=$(cd `dirname $0`; pwd)
. $path/../base/base.sh

# 忽略文件目录
config_ignore_file=$path'/ignore.ini'
# 仓库目录
config_file="$path"/local.conf

# 载入配置
while read line;do  
    eval "$line"  
done < $config_file

check_config(){
    if [ ! -f $config_file ]; then
        log_error "Must config local.conf"
        exit 1
    fi
}

generate_catalog(){
    # bash $path'/append_catalog.sh' "$1"
    python3 $path'/refresh_catalog.py' -at "$1"
}

handle_file(){
    file=$1
    # 判断当前文件是否属于忽略文件 是则文件名否则空
    ignore_file=`cat $config_ignore_file | grep $file`
    # 判断文件名是否符合正则,负责则文件名否则空
    type=`echo $file | grep .*md$`
    # 不是忽略文件并且文件名符合要求
    if [ "$ignore_file"z = "z" ] && [ "$type"z != "z" ]; then 
        result=$(generate_catalog $file)
        printf "$result\n"
    fi 
}
read_dir(){
    # 递归阅读文件, 然后更新md文件的目录
    for file in `ls $1`;do
        if [ -d $1"/"$file ]; then
            read_dir $1"/"$file
        else
            ignore_file=`cat $config_ignore_file | grep $file`
            type=`echo $file | grep .*md$`
            if [ "$ignore_file"z = "z" ] && [ "$type"z != "z" ]; then 
                printf ">>>>>> \033[0;32m%s\033[0m" $file
                result=$(generate_catalog $1'/'$file)
                printf "$result\n"
            fi 
        fi
    done
}

help(){
    printf "Run：$red sh deal_md.sh.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-15s $yellow%-12s$end%-20s\n"
    printf "$format"  "-h|h|help"    "" "输出帮助信息"
    printf "$format"  "-init"        "" "设置当前目录为笔记仓库的目录"
    printf "$format"  ""    "filename"  "更新指定文件索引目录 "
    printf "$format"  "-c|c|current" "" "更新当前目录所有md文件的索引目录"
    printf "$format"  "-a|a|all"     "" "更新指定目录下所有md文件的索引目录"
    printf "$format"  "-al|al|alter" "" "更新指定Git仓库下修改过的md文件的索引目录"
}

case $1 in 
    -h | h | help)
        help
    ;;
    -init)
        path=$(pwd)
        echo "# 笔记的仓库路径\nconfig_target_repo='$path'" > $config_file
        log_info "init complete"
    ;;

    -c | c | current)
        check_config
        files=`ls *.md`
        printf "current dir:\n" 
        for file in $files;do 
            if test -f $file; then
                handle_file "$file"
            fi
        done
        ;;
    -a | a | all)
        check_config
        printf "refresh all catalog: path=%s\n" "$config_target_repo"
        read_dir $config_target_repo
        ;;
    -al | al | alter)
        check_config
        printf "refresh catalog: path=%s\n" "$config_target_repo"
        result=`cd $config_target_repo && git status -s`
        # 使用标志变量, 前缀为修改或者新增的行 才能进行更新, 每个文件都判断一次并更新这个标志变量一次
        change_flag=0 
        for line in $result;do
            # mark next line has modify
            if [ `echo $line | grep -E "^[A|M]+$|^\?\?|->$"` ]; then
                change_flag=1
            fi
            map_result=`echo "$line" | grep ".md"`
            if [ "$map_result"z != 'z' ]; then
                if [ $change_flag = 1 ]; then
                    ignore=`cat $config_ignore_file`
                    ignore_file=`echo $map_result | grep "$ignore" `
                    if [ "$ignore_file"z = "z" ];then
                        printf "\033[0;32m modify: \033[0m" 
                        result=$(generate_catalog $config_target_repo/$map_result)
                        printf "$result\n"
                    fi
                fi
                change_flag=0
            fi
        done
        ;;
    *)
        assertParamCount $# 1
        check_config
        # 没有参数的时候, 就是单文件的更新
        result=$(generate_catalog $1)
        printf "$result\n"
    ;;
esac