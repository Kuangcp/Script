
# TODO 自动更新指定目录的所有md文件的目录

case $1 in 
    -h | h | help)
        start='\033[0;32m'
        end='\033[0m'
        printf "%-20s$start%-20s$end\n" "运行：bash deal_md.sh " "<params>"
        printf "  $start%-20s$end%-20s\n" "-h|h|help" "输出帮助信息"
        printf "  $start%-20s$end%-20s\n" "-i|i|index" "生成索引目录"
        printf "  $start%-20s$end%-20s\n" "no param" "生成索引目录"
        ;;
    -i | i | index)
        echo $2
        result=`python3 ~/Application/Script/python/append_contents.py -a n $2`
        echo -e "$result"
        ;;
    -ai | ai | allIndex)
        files=`ls *.md`
        for file in $files
        do 
            if test -f $file; then
                echo $file
                result=`python3 ~/Application/Script/python/append_contents.py -a n $file`
                echo -e "$result"
            fi
        done
        ;;
    *)
        echo $1
        # 过滤掉 - 的字符串 
        
            result=`python3 ~/Application/Script/python/append_contents.py -a n $1`
            echo -e "$result"
        ;;
esac




# 始终有个bug，读取每一行时，行首的空格丢了！！
# addToc(){
#     echo -e "$2" 
#     blank=`expr match "$line" "^ "`
#     # echo $blank
#     start_char=`expr match "$line" "^#*"` # 只能匹配到#并且后面有空格的字符串，返回出现次数
#     if [ $start_char = 1 ]; then
#         # echo -e "$2" 
#         # echo ">>>>"$start_char
#         titleWeight=`echo $2 | awk -F'#' '{print NF-1}'`
#         # echo $titleWeight
#     fi 
#     echo ">>>>"$start_char
# }

# case $1 in 
#     -h | h | help)
#         echo "bash deal_md.sh <params>"
#         echo "  -h|h|help    输出帮助信息"
#         echo "  -i|i|index    生成索引目录"
#         # echo ""
#     ;;
#     -i | i | index)
#         echo -e "添加目录索引\n"
#         while read -r "line"
#         do
#             # echo  "$line"
#             addToc $2 "$line"
#         done < $2
#     ;;
# esac
