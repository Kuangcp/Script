red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

log(){
    printf " $1\n"
}
log_error(){
    printf "$red $1 $end\n" 
}
log_info(){
    printf "$green $1 $end\n" 
}
log_warn(){
    printf "$yellow $1 $end\n" 
}

help(){
    printf "Run：$red sh $0 $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
}

delete_char(){
    title=$1
    ignore=": \. 【 】 ： ， \/ ( ) \* 。 ? ？ 《 》"
    for char in $ignore; do
        title=$(echo $title | sed "s/$char//g")
    done
    echo -e "$title"
}

transfer_link(){
    title=$1
    title=$(echo "$title" | tr '[A-Z]' '[a-z]')
    title=$(delete_char "$title")
    echo "#$title"
}

generate_catalog(){
    origin_catalog=$(cat $1 | grep -E "^(#){1,6}")

    titles=$(echo "$origin_catalog"| awk '{print $2}')
    catalog=$(echo "$origin_catalog"| awk '{print $1"1.["$2"]"}')

    # echo "$catalog" > test.log
    i=0
    for line in $catalog ; do
        # echo "$line" 
        i=$((i+1))
        j=0
        for link in $titles; do
            j=$((j+1))
            if [ $i = $j ];then 
                link=$(transfer_link $link)
                line=${line#*#}
                pre=$(echo "$line" | sed 's/#/    /g' | sed 's/1./1. /1')
                echo -e "$pre($link)"
                break
            fi
        done 
    done
}

replace_catalog(){
    file=$1
    start_num=$(cat -n $file | grep "\`目录 start\`" | awk '{print $1}')
    end_num=$(cat -n $file | grep "\`目录 end\`" | awk '{print $1}')

    if [ "$start_num"z = 'z' ] || [ "$end_num"z = 'z' ];then
        log_warn "not exist catalog"
        append_catalog $file
        exit 0
    fi
    sed -i "$start_num,${end_num}d" $file
    append_catalog $file
}
append_catalog(){
    file=$1;
    catalog=$(generate_catalog $file)

    now=$(date "+%Y-%m-%d %H:%M")
    banner='[码云](https://gitee.com/gin9) | [CSDN](http://blog.csdn.net/kcp606) | [OSChina](https://my.oschina.net/kcp1104) | [cnblogs](http://www.cnblogs.com/kuangcp)'
    # input file can't be output file
    echo -e "\`目录 start\`\n\n${catalog}\n\n\`目录 end\`|_${now}_|${banner}" | cat - "$file" >> "${file}.bak"
    mv "${file}.bak" "$file"
}

case $1 in 
    -h)
        delete_char $2
        help ;;
    *)
        if [ $# = 0 ];then
            log_error "empty param"
            exit 1
        fi
        log_warn $1" \033[0mcomplete"
        replace_catalog $1
        ;;
esac
