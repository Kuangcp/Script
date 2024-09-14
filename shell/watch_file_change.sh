FILE_NAME=$1

LAST_MODIFY_TIMESTAMP=`stat -c %Y  $FILE_NAME`

while true ; do
    # 每秒检查一次
    sleep 1 ;
    cur=`stat -c %Y  $FILE_NAME`
    # 文件修改过，且通知时间在上次通知时间60s后（避免高频消息频繁通知）
    if [ $cur -gt `expr $LAST_MODIFY_TIMESTAMP + 60` ]; then 
        echo "modify $FILE_NAME $cur"
        ssh test@host 'notify-send -i /opt/icon/test.svg  企业微信'
        LAST_MODIFY_TIMESTAMP=$cur
    fi
done


