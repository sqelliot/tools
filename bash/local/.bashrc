#PS1='\u@\h:\W\$ '

alias cint='ssh cint'
alias dev='ssh dev'

alias ls='ls --color=auto'

function scpcint (){ 
  scp $1 sean.elliott3@cint:~
}

alias govaccess='ssh gov' 
