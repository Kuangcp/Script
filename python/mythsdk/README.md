# MythSDK
> 类似sdkman一样的工具，但是这个脚本是基于 .bash_aliases 修改来配置环境变量的
> 因为使用sdkman导致终端开启慢，才写的这个脚本,所有sdk放在了七牛上
> 2017-08-31 10:36:38

## How to Use
### install 
- `git clone https://git.oschina.net/kcp1104/script.git`
- `cd script/python/mythsdk/`
- `python3 mythsdk.py l`
- `./init.sh` may be should run `chmod 744 init.sh`

### use

- `mk up` update sdk list config file
- `mk l` list all sdk
    - `mk l java` list java all version
- `mk u gradle 3.5` chang default gradle version to 3.5
- `mk i java` install lastst java version
    - `mk i gradle 4.0` install gradle with 4.0 version

