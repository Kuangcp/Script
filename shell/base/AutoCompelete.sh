function autotab() {
    echo "function autotab called $@"
}
autotab_list=("aa" "bb" "cc" "dd" "123")
function _autotab() {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "${autotab_list[*]}" -- ${cur}) )
    return 0
}
complete -F _autotab autotab