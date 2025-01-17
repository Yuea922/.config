export PLUG_DIR=$HOME/.zim
if [[ ! -d $PLUG_DIR ]]; then
    curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
    if [[ -f ~/.zimrc ]]; then
        rm ~/.zimrc
    fi
	ln -s ~/.config/zsh/zimrc ~/.zimrc
fi
