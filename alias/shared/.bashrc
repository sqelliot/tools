
# self-source
sharedBash='/tools/alias/shared/.bashrc'
alias sourceSharedBash='source ~/${sharedBash}'
alias editSharedBash='vim ~/${sharedBash}; sourceSharedBash'


# Shared git commands
alias gpush='git push origin'
alias   gfo='git fetch origin -p'
alias gpull='git pull origin'
alias    gl='git log'     
alias gogit='cd ~/repos/'
alias    ga='git add'
alias    gc='git commit'
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gs='git status'
alias   gka='gitk --all'
alias    fc='cd ~/repos/fcms-config'
alias    fd='cd ~/repos/fcms-deployment'
alias gfall='git fetch --all -p'
