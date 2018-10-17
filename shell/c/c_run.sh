red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

path=`pwd`

help(){
	printf "Run：$red sh c_run.sh $green<verb> $yellow<args>$end\n\n"
	format="  $green%-3s $yellow%-10s$end%-20s\n"
	printf "$format" "" "cpp file" "编译并运行"
	printf "$format" "-c" "" "清除当前目录所有可执行文件"
	printf "$format" "-h" "" "帮助"
}

compileThenRun(){
	sourceFile=$1
	if [ $sourceFile"z" = "z" ];then
		printf "Please select a spcific file.\n"
		exit 1
	fi

	# 编译
	g++ $path/$sourceFile -o $path/run.${sourceFile%.*}.run
	# 执行
	$path/run.${sourceFile%.*}.run
}

case $1 in
	-h)
		help ;;
	-c)
		ls -A | egrep ".*[^\.][\.]{1}run" | xargs rm
	;;
	*)
		compileThenRun $1 ;;
esac
