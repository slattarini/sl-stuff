# -*- bash -*-

#==========================================================================

#
# Terminal control.
#

#==========================================================================

# Escape character.
ESC=""

#--------------------------------------------------------------------------

#
# Color Codes.
#

readonly _TERM_BLACK=0
readonly _TERM_RED=1
readonly _TERM_GREEN=2
readonly _TERM_YELLOW=3
readonly _TERM_BLUE=4
readonly _TERM_MAGENTA=5
readonly _TERM_CYAN=6
readonly _TERM_GREY=7
readonly _TERM_WHITE=9

#--------------------------------------------------------------------------

# Escape a string to feed it to terminal.
term_escape() {
    printf '%s' "$ESC[$*"
}
declare -rf term_escape

#--------------------------------------------------------------------------

# Some internal variables which must remain shared between subroutines
_setterm_bolding=0
_setterm_underlining=0
_setterm_reversing=0
_setterm_blinking=0
_setterm_bolding_saved=0
_setterm_underlining_saved=0
_setterm_reversing_saved=0
_setterm_blinking_saved=0
_term_foreground_color=WHITE
_term_background_color=BLACK
_term_foreground_color_saved=${_term_foreground_color}
_term_background_color_saved=${_term_background_color}

#--------------------------------------------------------------------------

_set_term_color() {
   echo -ne "${ESC}[${2}${1}m"
}
declare -rf _set_term_color

_term_color_to_code()
{
    case ${1-} in
        WHITE|[wW]hite)
            echo "${_TERM_WHITE}";;
        BLACK|[bB]lack)
            # This is necessary to have real black and not
            # a "smoke grey" color
            echo "${_TERM_BLACK}";;
        GR[EA]Y|[gG]r[ea]y)
            # Simulate light grey.
            echo "${_TERM_GREY}";;
        RED|[rR]ed)
            echo "${_TERM_RED}";;
        GREEN|[gG]reen)
            echo "${_TERM_GREEN}";;
        YELLOW|[yY]ellow)
            echo "${_TERM_YELLOW}";;
        BLUE|[bB]lue)
            echo "${_TERM_BLUE}";;
        MAGENTA|[mM]agenta)
            echo "${_TERM_MAGENTA}";;
        CYAN|[cC]yan)
            echo "${_TERM_CYAN}";;
        *)
            fwarn "'${1-}': Invalid color name"
            return $FAILURE;;
    esac
    return $SUCCESS
}
declare -rf _term_color_to_code

set_term_color()
{
    local _term_ground
    case "${2-foreground}" in
        f|F|[fF]oreground) _term_ground=3;; # set the color as foreground
        b|B|[bB]ackground) _term_ground=4;; # set the color as background
        *) fwarn "Invalid second argument '$2'"; return $E_USAGE;;
    esac
    if (($# == 0)); then
        fwarn "No color name given"
        return $FAILURE
    fi
    _term_color=$(_term_color_to_code "$1") || return $FAILURE
    _set_term_color "${_term_color}" "${_term_ground}"
    case ${_term_ground} in
        3) _term_foreground_color="$1";; # global var
        4) _term_background_color="$1";; # global var
        *) fwarn "INTERNAL ERROR: bad \${_term_ground}"
           return $E_FAILURE;;
    esac
    return $SUCCESS
}
declare -rf set_term_color

set_term_foreground_color() {
    set_term_color "$1" foreground
}
declare -rf set_term_foreground_color

set_term_background_color() {
    set_term_color "$1" background
}
declare -rf set_term_background_color

#--------------------------------------------------------------------------

_set_current_term_settings()
{
    tput sgr ${_setterm_reversing} ${_setterm_underlining} \
             0 ${_setterm_blinking} 0 ${_setterm_bolding}
    set_term_background_color "${_term_background_color}"
    set_term_foreground_color "${_term_foreground_color}"
}
declare -rf _set_current_term_settings

term_default() {
    tput sgr0
}
declare -rf term_default

term_reverse() {
    _setterm_reversing=1
    _set_current_term_settings
}
declare -rf term_reverse

term_unreverse() {
    _setterm_reversing=0
    _set_current_term_settings
}
declare -rf term_unreverse

term_bold() {
    _setterm_bolding=1
    _set_current_term_settings
}
declare -rf term_bold

term_unbold() {
    _setterm_bolding=0
    _set_current_term_settings
}
declare -rf term_unbold

term_underline() {
    _setterm_underlining=1
    _set_current_term_settings
}
declare -rf term_underline

term_ununderline() {
    _setterm_underlining=0
    _set_current_term_settings
}
declare -rf term_ununderline

term_blink() {
    _setterm_blinking=1
    _set_current_term_settings
}
declare -rf term_blink

term_unblink() {
    _setterm_blinking=0
    _set_current_term_settings
}
declare -rf term_unblink

get_term_lines() {
    tput lines
}
declare -rf get_term_lines

get_term_columns() {
    tput cols
}
declare -rf get_term_columns

#--------------------------------------------------------------------------

save_term_colors() {
    _term_background_color_saved=${_term_background_color}
    _term_foreground_color_saved=${_term_foreground_color}
}
declare -rf save_term_colors

save_term_text_settings() {
    _setterm_bolding_saved=${_setterm_bolding}
    _setterm_underlining_saved=${_setterm_underlining}
    _setterm_reversing_saved=${_setterm_reversing}
    _setterm_blinking_saved=${_setterm_blinking}
}
declare -rf save_term_text_settings

save_term_settings() {
    save_term_colors
    save_term_text_settings
}
declare -rf save_term_settings

restore_term_colors() {
    _term_background_color=${_term_background_color_saved}
    _term_foreground_color=${_term_foreground_color_saved}
    set_term_foreground_color "${_term_foreground_color}"
    set_term_background_color "${_term_background_color}"
}
declare -rf restore_term_colors

restore_term_text_settings() {
    _setterm_bolding=${_setterm_bolding_saved}
    _setterm_underlining=${_setterm_underlining_saved}
    _setterm_reversing=${_setterm_reversing_saved}
    _setterm_blinking=${_setterm_blinking_saved}
    _set_current_term_settings;
}
declare -rf restore_term_text_settings

restore_term_settings() {
    restore_term_text_settings
    restore_term_colors
}
declare -rf restore_term_settings

#--------------------------------------------------------------------------

#
# Initialize the terminal properties with our defaults.
#

export LINES=$(get_term_lines)
export COLUMNS=$(get_term_columns)

_set_current_term_settings

#--------------------------------------------------------------------------

# vim: ft=sh et ts=4 sw=4
