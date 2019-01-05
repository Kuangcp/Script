kpy.ut(){
    $SCRIPT/shell/assistant/python_unittest.sh "$@"
}
_generate_option(){
    if [ ! $(ls * | grep -E "*_test.py" | wc -l)"" = '0' ];then 
        ls *_test.py | xargs bash $SCRIPT/shell/assistant/python_unittest.sh -f
    else
        # echo 'there not exist any python unittest script'
        exit 0
    fi
}

function listUnitTestCompletions { 
    reply=(
        $(_generate_option)
    );
}

compctl -K listUnitTestCompletions kpy.ut

# ln -s `pwd`/py-unittest.plugin.zsh ~/.oh-my-zsh/custom/plugins/py-unittest/py-unittest.plugin.zsh
# add py-unittest to .zshrc with plugins=(...)
