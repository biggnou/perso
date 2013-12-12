#! /bin/bash

pgrep chrome >/dev/null; rc=$?

if [[ $rc == '0' ]]; then
    killall chrome
fi

/opt/google/chrome/google-chrome %U 2>/dev/null &
