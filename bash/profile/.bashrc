#!/bin/bash
export PS1='\[\033]0;$MSYSTEM:${PWD//[^[:ascii:]]/?}\007\]\[\033[32m\]\u@\h \[\033[33m\]\w\[\033[36m\] `gitbranch || echo ""` {`date -u`} \[\033[0m\]\nπ '
