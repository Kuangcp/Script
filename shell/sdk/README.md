# Shell版mythsdk工具

> SDK的zip格式是 `sdk-version.zip` 内容是 `version/bin` 这样的目录结构

## install 
1. `git clone --depth 1 https://github.com/kuangcp/script.git`
2. `cd script/shell/sdk && sh init.sh` 注意修改为自己对应的别名配置文件
3. `kh up` 更新配置文件, 获取可安装SDK
4. `kh h` 查看帮助信息
```
$ kh h
  -h|h|help                   帮助
  -up|up|update               更新sdk的配置文件
  -l|l|list <sdk>             列出所有sdk或者指定的sdk
  -ls|ls|lists <sdk>          列出所有sdk或者指定的sdk的详细信息
  -i|i|install sdk ver        下载安装指定sdk的指定版本
  -li|li sdk ver zipFile      从zip包中安装指定sdk的指定版本
  -u|u|use sdk ver            更改指定sdk的指定版本
```
## Config
> 所有的SDK的压缩包放在七牛云上, 当然可以放在任意云上, 只要配置好压缩包, 配置好URL就行了  
> 先配置好压缩包sdk-version.zip(version/bin结构)，然后上传，更改配置文件然后提交仓库  
> 然后客户端mk up 再mk l 就能看到新添加的sdk了。

*************
> TODO 提升速度,找到合理的数据存取方式, 感觉就是要让无关字符变少就OK了 2018-02-05 21:22:58
