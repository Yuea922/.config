# My config for UBUNTU
## Includes
- [Neovim](#Neovim)
- [Tmux](#Tmux)

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
