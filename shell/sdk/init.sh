path=$(cd `dirname $0`; pwd)
echo "alias kh='sh "$path"/mythsdk.sh'" >> ~/.zshrc
. ~/.zshrc
