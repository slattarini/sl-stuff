# -*- bash -*-

if IsHost bigio; then
    export MAILDIR="$HOME/mail"
    # Directory usata da KMail per il salvataggio della posta.
    KMAIL_DIR="$MAILDIR/KMail"
    # Directory dei contatti personali (in formato `vCard visiting card').
    ADDRESS_BOOK_DIR="$HOME/address_book"
    # Eliminiamo informazioni superflue o errate.
    for v in ADDRESS_BOOK_DIR KMAIL_DIR; do
        if [ -d "${!v}" ]; then
            declare -rx $v
        else
            unset $v
        fi
    done
    unset v
fi

# vim: ft=sh et ts=4 sw=4
