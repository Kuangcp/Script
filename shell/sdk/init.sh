path=$(cd `dirname $0`; pwd)
echo "alias kh='sh "$path"/mythsdk.sh'" >> ~/.kcp_aliases
source ~/.bashrc
