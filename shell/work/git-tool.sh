red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

help(){
    printf "Run：$red sh git-tool.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-8s $yellow%-20s$end%-20s\n"
    printf "$format" "" "版本 功能" "创建新分支"
    printf "$format" "-c" "版本 功能" "创建新分支 使用当前目录名作为项目名"
}

create_branch_current_dir(){
    version=$2
    feature=$3

    if test -z $version || test -z $feature; then
        echo "must input two param"
        exit
    fi

    date=$(date +%Y%m%d)
    
    name=$(pwd)
    name=${name##*/}
    branch_name="${date}_${name}_${version}_$feature"
    printf "$green %s $end" $branch_name
    printf $branch_name | xclip -sel clip

    git branch $branch_name
}

create_branch(){
    version=$1
    feature=$2
    if test -z $version || test -z $feature; then
        echo "must input two param"
        exit
    fi

    # 获取项目名
    name=$(git remote -v | awk '{print $2}')
    name=${name##*btr-project\/}
    name=${name%%.git*}
    date=$(date +%Y%m%d)
    branch_name="${date}_${name}_${version}_$feature"
    printf "$green %s $end" $branch_name
    printf $branch_name | xclip -sel clip

    git branch $branch_name
}

case $1 in 
    -h)
        help
    ;;
    -c)
        create_branch_current_dir $*
    ;;
    *)
        create_branch $*
    ;;
esac