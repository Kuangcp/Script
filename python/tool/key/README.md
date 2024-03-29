# 记录并分析键盘敲击数据
> 原理 通过evdev包 监听 Linux 上 InputEvent 接口对应的键盘设备，记录按键

## 1.配置redis
```sh
    # 快速配置redis
    docker pull hub.baidubce.com/mythos/redis-alpine:1211
    docker tag hub.baidubce.com/mythos/redis-alpine:1211 redis3-myth
    docker run --name redis -p 6666:6379 -d redis3-myth
```

## 2.在redis中配置键的code和键对应
> hash结构 键名为 key_map 

- 使用 show_key_code_map.py 按下所有按键, 复制输出, 稍作修改 成为 ini 文件
- 使用 import_conf.py 即可完成导入

> 我的键盘是Poker II [键 code 映射配置文件](pokerII.ini)

## 3. 配置和运行Shell脚本
1. 配置 conf 文件, 并把该文件的绝对路径配置到 record.sh 中  
    `配置文件` 等号左右必须要有空格
```conf
[event]
key = 5

[redis]
host = 127.0.0.1
port = 6666
db = 2
password=
```
2. `sh record.sh -q` 搜索到所有有可能为键盘的事件号
3. `sh record.sh -s 事件号`  root权限 启动脚本 

> 通过 Analysis.py 可以分析出一天中最多的敲击次数, 也可以自己增加统计所有次数和所有的排行

*********

## 找键盘的事件号
> `less /proc/bus/input/devices` 找到键盘的事件号, 主要看name和handlers
>> 例如 H: Handlers=sysrq kbd leds event16
>> 运行 RecordeClick.py 测试事件号是否正确 然后填写到配置文件中去

例如 _event8_
```
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
```

## TODO

- [ ] 按时间段分析 所有敲击, 做出统计报表
