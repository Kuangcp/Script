---
title: README
date: 2024-10-02 21:37:51
tags: 
categories: 
---

💠

- 1. [实用性脚本](#实用性脚本)
- 2. [数据库](#数据库)
    - 2.1. [助手脚本](#助手脚本)
        - 2.1.1. [Python](#python)
        - 2.1.2. [C](#c)
    - 2.2. [Git仓库有关](#git仓库有关)
        - 2.2.1. [Github和Gitbook](#github和gitbook)
    - 2.3. [文件处理](#文件处理)
    - 2.4. [按组切换 host](#按组切换-host)
    - 2.5. [创建Github任意提交时间](#创建github任意提交时间)
    - 2.6. [记录并统计键盘按键数据](#记录并统计键盘按键数据)
    - 2.7. [刷CSDN浏览量](#刷csdn浏览量)
    - 2.8. [通过 m3u8 URL 下载ts文件 并转换成mp4](#通过-m3u8-url-下载ts文件-并转换成mp4)
- 3. [相关的脚本库](#相关的脚本库)

💠 2024-10-02 21:37:59
****************************************
# 实用性脚本
> 给自己Linux使用的脚本

- 定一下自己的目录结构规范:
  1. 所有的本地化配置文件放在 `$HOME/.config/app-conf/$APP` 目录下
  1. 仓库中模板配置文件 采用 ini 后缀

# 数据库
> 记录 PostgreSQL Clickhouse 复杂不容易记忆的统计分析，DDL类SQL [入口](/database/)

*********************************

## 助手脚本
### Python
1. 自动提示 python unittest 可执行的类以及方法 | [zsh plugin](/shell/assistant/py-unittest.plugin.zsh)

### C
1. 编译并运行 *.c *.cpp 源文件 | [sh](/shell/assistant/c_run.sh)

***********************

## Git仓库有关
- [快速查看改动的git仓库](/python/nouse/check_repos.py) 
  - [Shell 实现](/shell/check_by_aliases.sh)

### Github和Gitbook
> [Python 实现](/python/create_tree.py) 实现了将一个md的仓库, 生成一个GitBook所特有的目录文件 SUMMARY.md

然后就能方便的在线阅读了, 而且几乎没有修改自己笔记的仓库

> [示例](https://github.com/Kuangcp/Memo)

## 文件处理
- [Python 实现](/python/rename_image.py)`批量重命名文件`

## 按组切换 host
> [Python 实现](/python/tool/switch-host-group/app.py)

功能参考自 [SwitchHosts](https://github.com/oldj/SwitchHosts) 出于个人原因, 不太喜欢该软件, 重且bug多 但是操作方便  
写Python脚本就简单直接 但是操作复杂了点, 如果host组内容不是频繁改动 还是很适合的  

> **改进版本** [hosts-group](https://github.com/Kuangcp/GoBase/tree/master/toolbox/hosts-group) Go+HTML 交互简单 语法高亮

## 创建Github任意提交时间
> [Python 实现](/python/nouse/create_commit.py) `参考自github上的greenhat`  
> [Shell 实现](/shell/create_commit.sh)

## 记录并统计键盘按键数据
> 仅支持Linux

> [Python 实现](/python/tool/key)  
> [Go 实现](https://github.com/Kuangcp/GoBase/tree/master/toolbox/keylogger)`实现Echarts报表，kpm实时计算，悬浮窗实时展示统计数据和时间`  

## 刷CSDN浏览量
> CSDN浏览量应该和IP有关系, 所以一天也就刷一次, 权当玩玩   

> [Python 实现](/python/increase_readed.py)

## 通过 m3u8 URL 下载ts文件 并转换成mp4
> [Shell 实现](/shell/media/mergets.sh)

*********

# 相关的脚本库
- [useful-script](https://github.com/oldratlee/useful-scripts)
- [iScript](https://github.com/PeterDing/iScript)`影音有关的脚本`
- [across](https://github.com/teddysun/across) `bench等有用的脚本`

