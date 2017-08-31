path=$(cd `dirname $0`; pwd)
echo "alias mk='python3 "$path"/mythsdk.py'" >> ~/.bash_aliases
source ~/.bashrc