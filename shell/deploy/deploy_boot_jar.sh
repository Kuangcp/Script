rootDir='/home/rs/synthesizerd'

dateTime=`date +%m_%d-%H_%M_%S`

# ./bin/stop.sh && mv synthesizer.jar backup/synthesizer.jar`date +%m_%d-%H_%M_%S` && mv upload/synthesizer.jar . && ./bin/start.sh
# ssh rs@192.168.10.201 "cd "$rootDir" && sh bin/stop.sh && mv synthesizer.jar backup/synthesizer.jar_$dateTime && mv upload/synthesizer.jar . && sh bin/start.sh" 
# ssh rs@192.168.10.201 "cd "$rootDir" && ls"

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red bash .sh $green<verb> $yellow<args>$end\n"
    format="  $green%-6s $yellow%-8s$end%-20s\n"
    printf "$format" "-h" "" "帮助"
    printf "$format" "-on" "" "启动"
    printf "$format" "-off" "" "关闭"
    printf "$format" "-re" "" "更新"
}
on(){
    java -jar $rootDir/synthesizer.jar --spring.profiles.active=production &> $rootDir/game.log
}
off(){
    pid=`ps uxf |grep -v grep |grep -i synthesizer|awk '{print $2}'`
    echo killing ... pid = $pid
    kill $pid
}
case $1 in 
    -h)
        help ;;
    -on)
        on
    ;;
    -off)
        off
    ;;
    -re)
        off  && mv $rootDir/synthesizer.jar $rootDir/backup/synthesizer.jar`date +%m_%d-%H_%M_%S` && \
        mv $rootDir/upload/synthesizer.jar $rootDir/ && on
    ;;
    *)
        help ;;
esac