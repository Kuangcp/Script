help(){
    start='\033[0;32m'
    end='\033[0m'
    printf "运行：dash check_desktop.sh $start <params> $end\n"
    printf "  $start%-16s$end%-20s\n" "-h|h|help" "帮助"
    printf "  $start%-16s$end%-20s\n" "-a" "解析当前文件夹所有proto文件"
    printf "  $start%-16s$end%-20s\n" "file1 file2..." "解析对应proto文件"
}

case $1 in 
    -h | h | help)
        help
    ;;
    -a)
        protoc *.proto --java_out=./
    ;;
    # 文件过大时会有bug
    # -c)
    #     cat $2 | xsel -b
    # ;;
    *)
        protoc $@ --java_out=./
    ;;
esac
