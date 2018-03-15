help(){
    start='\033[0;32m'
    end='\033[0m'
    echo "运行：dash check_desktop.sh $start <params> $end"
    printf "  $start%-16s$end%-20s\n" "-h|h|help" "帮助"
    printf "  $start%-16s$end%-20s\n" "-a|a|add name" "在当前目录下创建一个name.desktop文件骨架"
    printf "  $start%-16s$end%-20s\n" "-c|c|cp  name" "将配置好的name.desktop放到启动图标里去"
}

case $1 in 
    -h | h | help)
        help
    ;;
    -a | a | add)
        path=`pwd`
        echo '[Desktop Entry]\nCategories=Development;
Exec='$path'\nIcon='$path'\nName='$2'
Terminal=false\nType=Application\n'>>$2'.desktop'
    ;;
    -c | c | cp)
        path=`pwd`
        sudo cp $path'/'$2'.desktop' '/usr/share/applications/'$2'.desktop'
    ;;
    *)
        help
    ;;
esac