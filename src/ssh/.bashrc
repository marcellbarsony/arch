# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prompt
PS1='[\u@\h \W]\$ '

# SSH agent venv
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
