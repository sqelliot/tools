
# self-source
sharedBash='/tools/alias/shared/.bashrc'
alias sourceSharedBash='source ~/${sharedBash}'
alias editSharedBash='vim ~/${sharedBash}; sourceSharedBash'


# Shared git commands
alias gpush='git push origin'
alias   gfo='git fetch origin -p'
alias gpull='git pull origin'
alias    glog='git log'     
alias gogit='cd ~/repos/'
alias    gadd='git add'
alias    gbra='git branch'
alias    gco='git commit'
alias   grv='git remote -v'
alias   gri='git rebase -i'
alias    gsta='git status'
alias   gka='gitk --all'
alias    fc='cd ~/repos/fcms-config'
alias    fd='cd ~/repos/fcms-deployment'
alias gfall='git fetch --all -p'

alias tools='cd ~/tools/'
