# 记录并分析键盘敲击数据

## 1.脚本旁新建文件 main.conf
```conf
    [event]
    key=5

    [redis]
    host=127.0.0.1
    port=6666
    db=2
    password=
```

## 2.配置redis
```sh
# 快速配置redis
docker pull hub.baidubce.com/mythos/redis-alpine:1211
docker tag hub.baidubce.com/mythos/redis-alpine:1211 redis
docker run --name redis -p 6666:6379 -d redis3:latest
```
> 其中, 记录到redis 中的数据结构为 zset  
- 日期
    - 键的code <-> 敲击次数 
> 记录键盘code和键对应的是hash结构
- code <-> key

## 3.在redis中配置键的code和键对应
> hash结构 键为 key_map 

- 我的键盘是Poker II [键 code 映射配置文件](pokerII.ini)

## 4. 找到键盘的事件号
> `less /proc/bus/input/devices` 找到键盘的事件号, 主要看name和handlers
>> 例如 H: Handlers=sysrq kbd leds event16
>> 运行 RecordeClick.py 测试事件号是否正确 然后填写到配置文件中去

## 5.root用户执行
> 执行`RecordClickWithRedis.py`即可将敲击键的次数记录到redis中去  
> 通过 Analysis.py 可以分析出一天中最多的敲击次数, 也可以自己增加统计所有次数和所有的排行

## 6.使用别名
```sh
alias reco.redis='(python3 /path/to/RecordClickWithRedis.py &)'
```
之后只需登录root, 执行reco.redis即可在后台记录了

- [ ] 按时间段分析 所有敲击, 做出统计报表

