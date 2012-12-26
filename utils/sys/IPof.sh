#!/bin/sh
exec nslookup "$@" | cut -f3
