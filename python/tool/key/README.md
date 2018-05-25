# 记录并分析键盘敲击数据

```sh
# 快速配置redis
docker pull hub.baidubce.com/mythos/redis-alpine:1211
docker tag hub.baidubce.com/mythos/redis-alpine:1211 redis
docker run --name redis -p 6666:6379 -d redis3:latest

```