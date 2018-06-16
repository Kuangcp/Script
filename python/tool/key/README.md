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
    - 使用 import_conf.py 即可完成导入

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


- [ ] 事件号变来变去, 要找到一个规律自动填充

_event8_
I: Bus=0003 Vendor=04d9 Product=0209 Version=0111
N: Name="USB-HID Keyboard"
P: Phys=usb-0000:00:14.0-3/input0
S: Sysfs=/devices/pci0000:00/0000:00:14.0/usb2/2-3/2-3:1.0/0003:04D9:0209.0002/input/input9
U: Uniq=
H: Handlers=sysrq kbd event8 leds 
B: PROP=0
B: EV=120013
B: KEY=1000000000007 ff800000000007ff febeffdfffefffff fffffffffffffffe
B: MSC=10
B: LED=7
