#!/bin/bash
#  检查仓库 shell重写

cat ../python/config/repos.md | while read line
do 
    # echo $line
    start_char=`expr match "$line" "/*"`
    if [ "$start_char" = "0" ]; then 
        continue
    fi 
    var=${line%%#*} 
    # name=${line##*}
    # echo $var
    echo "\033[0;35m\n......."$line"\n\033[0m"
    result=`cd $var && git status 2>&1`
    echo "$result" | while read i  
    do  
        # echo ">>>>>"$i
        clean=`expr match "$i" ".*干净"`
        blank=`expr match "$i" "^\s"`
        # echo $blank
        if [ "$clean" != "0" ]; then 
            # echo $blank
            break
        fi

        change=`expr match "$i" ".*变更"`
        use=`expr match "$i" ".*使用"`
        
        if [ "$use" = "0" -a "$change" = "0" ]; then
            
            change=`expr match "$i" ".*修改"`
            if [ "$change" != "0" ]; then 
                echo "\033[0;33m "$i" \033[0m"
                # echo $i
                continue
            fi
            echo ">"$i
        fi 
        # echo $result
        # if [ $i =~ "变更*" ]; then
        #     echo "+++++++"$i

        # fi
    done 

done