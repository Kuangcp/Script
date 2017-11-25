#!/bin/sh

# 前提：代码能够正常运行，构建命令能正常运行，ssh已经配置
# 放置在src同级目录即可使用,针对Springboot的web项目,日志文件是logs

# 实现的步骤：构建出war，上传war，然后删除原有war，停止原有容器，构建镜像和容器，直接运行
# TODO 方便一点就是构建镜像，然后上传镜像服务器，生产服务器下拉镜像运行容器即可

user="kuang"
host="120.78.154.52"
upload_path="/home/kuang" 
target_path="/home/kuang/kuang" 
log_path="/home/kuang/log/kuang/"
image_name="wx-youhui"
con_name="you"
con_port="8888"
host_port="8080"

############
buildTool=gradle # maven  gradle maven是target根目录下，gradle是build/libs/下
app_log_path='/logs'#应用日志目录
base_image='frolvlad/alpine-oraclejdk8:slim'
# user="" #用户名
# host="" #主机IP
# upload_path="" #上传缓存路径 
# target_path="" #war真实存放路径
# log_path="" #本地日志目录，将要挂载进容器
# image_name="" #构建出来镜像名
# con_name="" #运行出来的容器名
# con_port="" #容器内开放的端口
# host_port="" #容器在主机开放的端口
############

# 以上是配置参数变量
# 公共变量
version=$1
build=$2
first=$3
ssh_login='ssh '$user'@'$host


if [ $version = "-h" ]; then
	echo '脚本参数： <version> <build> <status>'
    echo '   version: \n      版本号必需参数'
	echo '   build: \n      缺省或不为-b: 立即构建war \n      -b: 不进行构建'
	echo '   status: \n      缺省或不为-f: 则更新一个版本 \n      -f: 第一次创建容器运行'
	exit 0
fi

# 不说明-b就进行构建出war并上传，否则直接上传
if [ "$buildTool"x = "maven"x ]; then
	if [ "$build"x != "-b"x ]; then
		mvn package -DskipTests
	fi
    scp target/*.war $user@$host:$upload_path
fi
if [ "$buildTool"x = "gradle"x ]; then
	if [ "$build"x != "-b"x ]; then
		gradle war
    	gradle bootRepackage 
	fi
    scp build/libs/*.war $user@$host:$upload_path
fi

# 转移文件
$ssh_login 'rm -rf '$target_path'/*.war \'
$ssh_login 'mv '$upload_path'/*.war '$target_path'/ \'

# 进行构建镜像
$ssh_login 'cd '$target_path' \
    && echo -e "FROM '$base_image'" > Dockerfile \
    && echo -e "ADD *.war app.war" >> Dockerfile \
    && echo -e "ENTRYPOINT [\"java\",\"-jar\",\"/app.war\"]" >> Dockerfile \
    && docker build -t '$image_name':'$version' . \'

# 如果是第一次，就要创建dockerfile，否则只要删除旧容器即可
if [ "$first"x != "-f"x ]; then
	$ssh_login 'docker rm -f '$con_name
	# 删除成功会在控制台输出容器名
fi

create_con='docker run --name '$con_name' -d -p '$host_port':'$con_port' -e TZ=Asia/Shanghai -v '$log_path':'$app_log_path' '$image_name':'$version''
$ssh_login ''$create_con


# 停掉守护进程
if [ "$build"x != "-b"x ]; then
    if [ "$buildTool"x = "gradle"x ]; then
        gradle --stop
    fi
fi

echo ''$create_con