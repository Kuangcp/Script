# show readme file

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

showReadme(){
	num=`ls -AlFh | grep -i 'readme' | wc -l `
	if [ $num = 0 ];then
		printf $red"There is no readme file in this directory \n"$end
		exit 1
	fi
	
	if [ $num = 1 ];then 
		readme=`ls -A | grep -i 'readme'`
		less $readme
	else
		ls -A | grep -i 'readme' | awk '{printf("%2d %s\n", NR, $0);}'
		printf "select (1-$num): "
        read no
		if test $no -gt $num; then
			printf $red"Select no out of round: (1-$num) \n"$end
			exit 1
		fi
		file=$(ls -A | grep -i 'readme' | sed -n ${no}p)
		less $file
	fi
}

help(){
    printf "Run：$red bash ShowReadme.sh $green<verb> $yellow<args>$end\n"
    format="  $green%-4s $yellow%-4s$end%-20s\n"
    printf "$format" "-h" "" "help"
    printf "$format" "-a" "" "touch Readme.md"
}

case $1 in 
	-h)
		help ;;
	-a)
		vim Readme.md ;;
	i | -i)
		cat .gitignore
	;;
	vi )
		vim .gitignore
	;;
	*)
		showReadme ;;
esac
