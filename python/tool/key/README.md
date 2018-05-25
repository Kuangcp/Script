# 记录并分析键盘敲击数据

脚本旁新建文件 main.conf
```conf
    [event]
    key=5

    [redis]
    host=127.0.0.1
    port=6666
    db=2
    password=
```

```sh
# 快速配置redis
docker pull hub.baidubce.com/mythos/redis-alpine:1211
docker tag hub.baidubce.com/mythos/redis-alpine:1211 redis
docker run --name redis -p 6666:6379 -d redis3:latest
```
> 记录到redis 中的数据结构为 zset  
- 日期
    - 键的code <-> 敲击次数 
