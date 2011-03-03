# -*- bash -*-

# I18N and L10N

W nlang || {
    mwarn "Missing program \`nlang'" >&2
    mwarn "Fancy localization functions won't be available" >&2
    return $SUCCESS
}

savelang() {
    _restore_lang_cmd=$(nlang)
}

resetlang() {
    eval "${_restore_lang_cmd}" && _restore_lang_cmd=""
}

setlang() {
    eval $(nlang "$@")
    export LC_COLLATE=C
    export LC_NUMERIC=C
}

clearlang() {
    eval $(nlang '')
}

speak() {
    case "${1-}" in
        crucco|de|deutsch)  set de_DE.UTF-8;;
        mafia|it|italiano)  set it_IT.UTF-8;;
         limey|en|english)  set en_GB.UTF-8;;
            yankee|us|usa)  set en_US.UTF-8;;
              fr|français)  set fr_FR.UTF-8;;
    esac
    setlang "$1"
}

savelang
setlang -f it_IT.UTF-8

# vim: ft=sh ts=4 sw=4 et
