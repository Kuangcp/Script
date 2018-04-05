case $1 in
    -p | p)
        netstat -anlp | grep $2 | grep LIST
    ;;
    -l | l)
        sudo lsof -i:$2
    ;;
    *)
    ;;
esac


