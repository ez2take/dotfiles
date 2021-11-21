alias ls="ls --color=auto"
alias l="ls"
alias ll="ls -lAF"
alias c="cd"

if $nvim ; then
    alias n="nvim"
fi

alias nvimconfig="nvim ~/.config/nvim"
alias zshconfig="nvim ~/.zsh.d/init; source ~/.zshrc"