@echo off
REM REM �趨dos���ڵı���
chcp 936
cls
:redo
set /a con=1 
rem rem ���֮ǰ�Ļ���ֵ

echo +++++++++++++++++  �����б�  ++++++++++++++++++++++++
echo +
echo +    11  :   �򿪷�������
echo +    12  :   ���� Oracle ����
echo +    13  :   ���� Tomcat 7.07
echo +    14  :   ���� VMWare ����
echo +
echo +    21  :   �ر� VMWare ����
echo +    22  :   �ر� Oracle ����
echo +    23  :   �ر� Tomcat 7.07
echo +    0  :   �˳�����
echo +
echo +++++++++++++++++  �����б�  ++++++++++++++++++++++++


echo �����������Ӧ�Ĵ���:
set /p action=Action :  
if "%action%"=="12" goto NO
if "%action%"=="22" goto CO
if "%action%"=="14" goto NV
if "%action%"=="21" goto CV
if "%action%"=="11" goto NS
if "%action%"=="0" goto EX
if "%action%"=="13" goto TR
if "%action%"=="23" goto TS
rem rem �������������еĲ�����ִ������Ĵ��룺
cls 
echo ## ��
echo ## ����
echo ## ������
echo ## ��������   ����������Ч�����
echo ## ������
echo ## ����
echo ## ��

goto redo

echo +++++++++++++++++ ��������  +++++++++++++++++++++++
REM REM ����Oracle����
:NO
echo ++ ���� Oracle ����
net start "OracleServiceORCL"
net start "OracleOraDb11g_home1TNSListener"
goto end

REM REM �ر�Oracle����
:CO
echo �ر� Oracle ����
net stop "OracleOraDb11g_home1TNSListener"
net stop "OracleServiceORCL"
goto end

:NV
echo ++���� VMWare ����
net start "VMAuthdService"
net start "VMnetDHCP"
net start "VMware NAT Service"
net start "VMUSBArbService"
goto end 

:CV
echo ++�ر� VMWare ����
net stop "VMAuthdService"
net stop "VMnetDHCP"
net stop "VMware NAT Service"
net stop "VMUSBArbService"
goto end 

:NS
echo ++�򿪷�������
start "myth" "services.msc"
goto end 

:TR
echo ++tomcat startup
net start "Tomcat7"
goto end 


:TS
echo ++tomcat stop
net stop "Tomcat7"
goto end 

:end
set /a action="myth" 
rem rem ���֮ǰ�Ļ���ֵ
set /p con=���� c ���� ����ֱ���˳� �� 
cls
if "%con%"=="c" goto redo
exit

:EX 
exit