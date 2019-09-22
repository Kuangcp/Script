red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

path=`pwd`

log_error(){
	printf "$red $1 $end\n"
}

help(){
	printf "Run：$red sh cpp.sh $green<verb> $yellow<args>$end\n"
	format="  $green%-3s $yellow%-6s$end%-20s\n"
	printf "$format" "" "file" "compile then run (cpp/c)"
	printf "$format" "-c" "" "clean *run file in dir with recurise"
	printf "$format" "-h" "" "help"
}

compileThenRun(){
	sourceFile=$1
	if [ "$sourceFile" = "" ];then
		log_error "please specific c/cpp file"
		exit 1
	fi
	if [ ! -f $path/$sourceFile ];then
		log_error "file not exist "
		exit 1
	fi

	# 去除第一个参数
	temp=''
	count=0
	for a in $@; do
		count=$((count+1))
		if [ $count = 1 ];then
			continue
		fi
		temp=$temp" "$a
	done
	
	run_file=${sourceFile}.run
	rm -f $path/$run_file

	# 编译
	g++ $path/$sourceFile -o $path/$run_file
	if [ -f $path/$run_file ];then
		# 执行
		$path/$run_file $temp
	else
		log_error "compile occur error"
		exit 1
	fi
}

case $1 in
	-h)
		help 
	;;
	-c)
		find . -iregex  ".*\.run$" | xargs rm 
	;;
	*)
		compileThenRun $@
	;;
esac
