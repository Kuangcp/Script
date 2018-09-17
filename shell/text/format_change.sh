while read line; do
  # echo "start $line"
  isAdd=`echo "$line" | egrep "^[+]" | wc -l`
  isDelete=`echo "$line" | egrep "^[-]" | wc -l`

  if [ $isAdd = 0 -a $isDelete = 0 ];then
	 continue;
  fi

  if [ $isAdd = 1 ];then
	  printf "\033[0;32m $line \n"
  fi

  if [ $isDelete = 1 ];then
	  printf "\033[0;31m $line \n"
  fi
done