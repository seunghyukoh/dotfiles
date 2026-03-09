# ln -sv $PWD/aliases.zsh  $ZSH_CUSTOM/aliases.zsh

# --- Editor ---
alias vim=nvim

# --- Shell ---
alias sz='source ~/.zshrc'

# --- tmux ---
alias t="tmux new -As"

# --- eza (ls 대체) ---
alias ls="eza --icons"
alias ll="eza --icons -l --git"
alias la="eza --icons -la --git"
alias lt="eza --icons --tree --level=2"

# --- bat (cat 대체) ---
alias cat="bat --paging=never"

# --- Git ---
alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias gp="git push"
alias gl="git log --oneline -20"
alias gco="git checkout"
alias gcb="git checkout -b"
alias ga="git add"
alias gc="git commit"
alias gca="git commit --amend"

# --- lazygit ---
alias lg="lazygit"
