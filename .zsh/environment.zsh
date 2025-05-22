# your project folder that we can `c [tab]` to
export WORKSPACE=~/workspace
export DATASETS=~/Datasets

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# FAT Scripts
export PATH=$WORKSPACE/abis_scripts:$PATH 

# Docker environment
if [[ -a /.dockerenv  ]]; then
    export PATH=$HOME/.linuxbrew/bin:$PATH
fi

# rbenv setup
if command -v rbenv >/dev/null 2>&1; then
    export PATH="$PATH:$HOME/.rbenv/bin"
    eval "$(rbenv init -)"
fi

# Conda setup
# Check for Conda installation in either Homebrew or home directory
CONDA_PATHS=(
    "/opt/homebrew/Caskroom/miniconda/base"
    "$HOME/miniconda3"
)

# Try to find Conda installation
for conda_path in "${CONDA_PATHS[@]}"; do
    if [[ -f "$conda_path/bin/conda" ]]; then
        __conda_setup="$("$conda_path/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "$conda_path/etc/profile.d/conda.sh" ]; then
                . "$conda_path/etc/profile.d/conda.sh"
            else
                export PATH="$conda_path/bin:$PATH"
            fi
        fi
        unset __conda_setup
        break
    fi
done

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# SDKMAN setup
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh" 

# minio client completion
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/mc mc