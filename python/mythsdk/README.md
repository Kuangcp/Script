# MythSDK
> 类似sdkman一样的工具，但是这个脚本是基于 .bash_aliases 修改来配置环境变量的<br/>
> 因为使用sdkman导致终端开启慢，才写的这个脚本,所有sdk放在了七牛上 所以要自行配置<br/>
> 2017-08-31 10:36:38

## How to Use
> 先配置好压缩包sdk-version.zip(version/bin结构)，然后上传，更改配置文件然后提交仓库
> 然后客户端mk up 再mk l 就能看到新添加的sdk了。

### config
- ![qiniu](https://raw.githubusercontent.com/Kuangcp/ImageRepos/masters/Image/mythsdk/qiniu.gng)
- 使用自己的七牛云，上传好zip，就能方便的使用了。 
- zip格式是 `sdk-version.zip` 内容是 `version/bin` 这样的目录结构

### install 
- `git clone https://git.oschina.net/kcp1104/script.git`
- `cd script/python/mythsdk/`
- `python3 mythsdk.py up` 
    - then `python3 mythsdk.py l` can view all sdk
- `./init.sh` 
    - may be should run `chmod 744 init.sh`

### use

- `mk q url` 配置七牛云仓库地址

- `mk up` 更新配置文件，获取到sdk列表，需要改成自己的地址
- `mk l` 列出所有可安装的sdk
    - `mk l java` 列出java 的所有可安装版本
- `mk u gradle 3.5` 使用指定版本
- `mk i java` 安装 java最新版（json配置文件的最后一个版本）
    - `mk i gradle 4.0` 安装指定版本

### TODO
> 增加删除压缩包, 删除压缩包以及解压文件, 删除解压文件 三个功能

添加介绍信息和官网地址
    "info":{
        "ant":["构建工具", "url"]
    },