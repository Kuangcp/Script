# 备份原始文件夹, 更新并重启
time=`date +%s`
cp -r webapps/ROOT back$time &&
rm -rf webapps/ROOT* &&
mv ROOT.war webapps &&
bin/shutdown.sh &&
bin/startup.sh
