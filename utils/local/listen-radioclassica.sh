#!/bin/sh
URL=http://radio.gruppoeditorialebresciana.it/radioclassica
MPLAYER=${MPLAYER-"mplayer"}
exec ${MPLAYER-mplayer} -vo null "$URL"
