for i in {0..100000..1}
  do
	sleep 1
	curl -s -o /dev/null http://www.imooc.com/article/15384
	curl -s -o /dev/null http://www.imooc.com/article/15384
	curl -s -o /dev/null http://www.imooc.com/article/15406
	curl -s -o /dev/null http://www.imooc.com/article/15390
	curl -s -o /dev/null http://www.imooc.com/article/15384
	curl -s -o /dev/null http://www.imooc.com/article/15388
 done
# 循环访问网页