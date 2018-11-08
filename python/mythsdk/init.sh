path=$(cd `dirname $0`; pwd)
echo "alias kk='python3 "$path"/mythsdk.py'" >> ~/.kcp_aliases
source ~/.bashrc
