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

## 3.配置键的code和键对应
我的键盘是Poker II
```conf
1 = Esc
2 = 1
3 = 2
4 = 3
5 = 4
6 = 5
7 = 6
8 = 7
9 = 8
10 = 9
11 = 0
12 = -
13 = =
14 = Backspace
15 = Tab
16 = Q
17 = W
18 = E
19 = R
20 = T
21 = Y
22 = U
23 = I
24 = O
25 = P
26 = [
27 = ]
28 = Enter
29 = L_Control
30 = A
31 = S
32 = D
33 = F
34 = G
35 = H
36 = J
37 = K
38 = L
39 = ;
40 = '
41 = `
42 = L_Shift
43 = |
44 = Z
45 = X
46 = C
47 = V
48 = B
49 = N
50 = M
51 = ,
52 = .
53 = /
54 = R_Shift
56 = L_Alt
57 = Space
58 = Caps
59 = F1
60 = F2
61 = F3
62 = F4
63 = F5
64 = F6
65 = F7
66 = F8
67 = F9
68 = F10
70 = Scrlk
87 = F11
88 = F12
97 = R_Control
99 = Prtsc
100 = R_Alt
102 = Home
103 = Up
104 = PageUp
105 = Left
106 = Right
107 = End
108 = Down
109 = PageDown
110 = Insert
111 = Delete
119 = Pause
125 = Win
127 = youjian
```

## 4. 找到键盘的事件号
> `less /proc/bus/input/devices` 找到键盘的事件号, 主要看name和handlers
>> 例如  H: Handlers=sysrq kbd leds event16
>> 然后填写到配置文件中去

## 5.root用户执行
> 执行`RecordClickWithRedis.py`即可将敲击键的次数记录到redis中去, 通过 Analysis.py 可以分析出一天中最多的敲击次数, 也可以自己增加统计所有次数和所有的排行
