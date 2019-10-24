# readme=`ls -A | grep -i Readme `

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
end='\033[0m'

showReadme(){
	num=`ls -AlFh | egrep "(\.md|txt)+" | grep -i 'readme' | wc -l `
	if [ $num = 0 ];then
		printf $red"There is no readme file in this directory \n"$end
		exit 1
	fi
	
	readme=`ls -A | egrep "(\.md|txt)+" | grep -i 'readme'`
	if [ $num = 1 ];then 
		less $readme
	else
		tempNum=0
		for file in $readme; do
			tempNum=$(( $tempNum + 1 ))
			echo $tempNum"  "$file
		done
		tempNum=0
		printf $green"Please select the sequence number in front of the file : \n"$end
		read fileNum
		for file in $readme ; do
			tempNum=$(( $tempNum + 1 ))
			if [ $tempNum = $fileNum ];then
				less $file
			fi
		done
	fi
}

case $1 in 
	-h)
		help ;;
	-a)
		touch Readme.md ;;
	*)
		showReadme ;;
esac