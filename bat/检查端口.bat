chcp 936
@echo off
rem rem �����ж˿ڵ������Ϣд�� �ı��ļ���ȥ
rem rem �½��ļ����Ḳ��֮ǰ���ļ�
echo=>test.txt
rem rem ׷�ӵ��ļ���ȥ
netstat -a -n >> test.txt
type test.txt | find "3306" && echo "�Ѿ�������Mysql"
 rem rem dir >> test.txt
pause