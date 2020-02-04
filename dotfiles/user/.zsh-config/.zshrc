#----------------------------------------
# History settings
#----------------------------------------
HISTFILE=$ZDOTDIR/.zsh-history
HISTSIZE=10000
SAVEHIST=10000
#----------------------------------------
# Bind method
#----------------------------------------
bindkey -v
#----------------------------------------
#----------------------------------------
zstyle :compinstall filename '$ZDOTDIR/.zshrc'
#----------------------------------------

#----------------------------------------
# Git settings
#----------------------------------------
source $ZDOTDIR/.git-settings


#----------------------------------------
# ZSH Autocomplete
#----------------------------------------
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit;
else
    compinit -C;
fi;


#----------------------------------------
# ZSH time output format
#----------------------------------------
TIMEFMT=$'\n> %J\n\nCPU\t%P\nUser\t%*U\nSystem\t%*S\nTotal\t%*E\nMemory\t%Mkb'


#----------------------------------------
# Variables
#----------------------------------------
source $ZDOTDIR/.shell-variables


#----------------------------------------
# Aliases
#----------------------------------------
source $ZDOTDIR/.shell-aliases


#----------------------------------------
# Prompt setup
#----------------------------------------
source $ZDOTDIR/.zsh-prompt


#----------------------------------------
# ZSH syntax highlighting
#----------------------------------------
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


#----------------------------------------
# ZSH autosuggestions
#----------------------------------------
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh


#----------------------------------------
# ZSH history substring search
#----------------------------------------
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[1;5A' history-substring-search-up
bindkey '^[[1;5B' history-substring-search-down


#----------------------------------------
# FZF
#----------------------------------------
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh


#----------------------------------------
# Sway boot
#----------------------------------------
#source $ZDOTDIR/.swayboot
