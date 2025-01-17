# My config for UBUNTU
## Includes
- [Neovim](#Neovim)
- [Tmux](#Tmux)
- [zsh](#zsh)
- [yazi](#yazi)

# Neovim
## Requirements
- Neovim 0.10+
- Nerd fonts 3.0.0+ (Now use MesloLGS Nerd Font Bold)
- lazygit
- figlet (for fun ...)

# Tmux
## Requirements
- Tmux >= 3.0a
- ifstat (for tmux-powerline status bar)
- [rainbarf](https://github.com/creaktive/rainbarf.git) Fancy resource usage charts to put into the tmux status line.

## Configuration
- Use [TPM](https://github.com/tmux-plugins/tpm.git) to manage plugins. See .tmux.conf for detail.
- Execute the following command to make tmux configuration effective:
```sh
ln -s ~/.config/.tmux.conf ~/.tmux.conf
```

# zsh
## Requirements
- [zimfw](https://github.com/zimfw/zimfw.git) Plugin manager
- p10k theme (requirement Nerd fonts)
- See all required plguins in ~/.config/zsh/zimrc
- Check ~/.config/zsh/env.zsh and customize it
- Plugin fzf-tab need [fzf](https://github.com/junegunn/fzf#installation) v0.33.0 and above. Install it by git instead of apt

## Configuration
- Execute the following command to make zsh configuration effective:
```sh
ln -s ~/.config/zsh/zshrc ~/.zshrc
```

## TODO
- [ ] Improve file structure

# yazi
[yazi](https://github.com/sxyazi/yazi) Blazing fast terminal file manager
## Requirements
- See all infomation on https://yazi-rs.github.io/docs/installation/
- zoxide need [fzf](https://github.com/junegunn/fzf#installation) v0.33.0 and above. Install it by git instead of apt

## TODO
- [ ] Install [ueberzugpp](https://github.com/jstkdng/ueberzugpp) for image previewing (on ubuntu 20.04)
