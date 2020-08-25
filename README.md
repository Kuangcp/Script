**目录 start**
 
1. [实用性脚本](#实用性脚本)
    1. [sdk管理](#sdk管理)
    1. [助手脚本](#助手脚本)
        1. [Python](#python)
        1. [C](#c)
    1. [Git仓库有关](#git仓库有关)
    1. [Github和Gitbook](#github和gitbook)
    1. [文件处理](#文件处理)
    1. [按组切换 host](#按组切换-host)
    1. [创建Github任意提交时间](#创建github任意提交时间)
    1. [记录并统计敲击键盘的数据](#记录并统计敲击键盘的数据)
    1. [刷CSDN浏览量](#刷csdn浏览量)
    1. [通过 m3u8 URL 下载并转换成mp4](#通过-m3u8-url-下载并转换成mp4)
1. [相关的脚本库](#相关的脚本库)

**目录 end**|_2019-07-20 14:17_|
****************************************
# 实用性脚本
> 给自己Linux使用的脚本

- 定一下自己的目录结构规范:
  1. 所有的本地化配置文件放在 `$HOME/.config/app-conf/$APP` 目录下
  1. 仓库中模板配置文件 采用 ini 后缀

## sdk管理
> `比sdkman 更简洁的sdk管理工具 因为采用的七牛云是免费版。请自行使用自己的七牛云进行使用`

- [Shell版](/shell/sdk) | [Python版](/python/mythsdk/)`Python是最初版,现已放弃,但是基本功能能用` 

*********************************

## 助手脚本
### Python
1. 自动提示 python unittest 可执行的类以及方法 | [zsh plugin](/shell/assistant/py-unittest.plugin.zsh)

### C
1. 编译并运行 *.c *.cpp 源文件 | [sh](/shell/assistant/c_run.sh)

***********************

## Git仓库有关
- [快速查看改动的git仓库](/python/nouse/check_repos.py) 
  - [Shell实现版](/shell/check_by_aliases.sh)

### Github和Gitbook
> [Python](/python/create_tree.py) 实现了将一个md的仓库, 生成一个GitBook所特有的目录文件 SUMMARY.md

然后就能方便的在线阅读了, 而且几乎没有修改自己笔记的仓库

> [示例](https://github.com/Kuangcp/Memo)

## 文件处理
- [Python](/python/rename_image.py)`批量重命名文件`

## 按组切换 host
> [Python](/python/tool/switch-host-group/app.py)

功能参考自 [SwitchHosts](https://github.com/oldj/SwitchHosts) 出于个人原因, 不太喜欢该软件, 重且bug多 但是操作方便  
写Python脚本就简单直接 但是操作复杂了点, 如果host组内容不是频繁改动 还是很适合的  

## 创建Github任意提交时间
> [Python](/python/nouse/create_commit.py) `参考自github上的greenhat`  
> [Shell](/shell/create_commit.sh)

## 记录并统计键盘按键数据
> [Python](/python/tool/key)

## 刷CSDN浏览量
> CSDN浏览量应该和IP有关系, 所以一天也就刷一次, 权当玩玩   

> [Python](/python/increase_readed.py)

## 通过 m3u8 URL 下载ts文件 并转换成mp4
> [Shell](/shell/media/mergets.sh)

*********

# 相关的脚本库
- [useful-script](https://github.com/oldratlee/useful-scripts)
- [iScript](https://github.com/PeterDing/iScript)`影音有关的脚本`
- [across](https://github.com/teddysun/across) `bench等有用的脚本`

