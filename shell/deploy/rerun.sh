# 备份原始文件夹, 更新并重启
cp -r webapps/ROOT back &&
rm -rf webapps/ROOT* &&
mv ROOT.war webapps &&
bin/shutdown.sh &&
bin/startup.sh
