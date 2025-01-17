# The environment settings may vary on different computers
# Please check and reset them !!!!!!!

# -----------------------------------------------------------------------------------------------------
# opt config
# -----------------------------------------------------------------------------------------------------

export EDITOR=nvim
export SVN_EDITOR=nvim

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

### ROS Noetic
source /opt/ros/noetic/setup.zsh

# neovim config
export PATH="$PATH:/opt/nvim-linux64/bin"

# tmux config
export PATH=$PATH:/opt/tmux/bin/
export MANPATH=$MANPATH:/opt/tmux/share/man/

# yazi
export PATH=$PATH:/opt/yazi/
function ya() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# fzf (On ubuntu, install by git isntall of apt for v0.33.0 and above)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# colmap
export PATH=$PATH:/opt/colmap/bin/

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/qzy/5_opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/qzy/5_opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/qzy/5_opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/qzy/5_opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# -----------------------------------------------------------------------------------------------------
# 3rdparty config
# -----------------------------------------------------------------------------------------------------

### Qt5.14.2
export QTDIR=/opt/Qt5.14.2/
export PATH=$PATH:$QTDIR/Tools/QtCreator/bin/
export QT_SELECT=qt5.14.2

### protobuf 3.7.1
# export PATH=$PATH:/opt/protobuf-3.7.1/bin/
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/protobuf-3.7.1/lib
# export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/protobuf-3.7.1/lib/pkgconfig

### protobuf 3.5.1
export PATH=$PATH:/opt/protobuf-3.5.1/bin/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/protobuf-3.5.1/lib
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/protobuf-3.5.1/lib/pkgconfig

### NOTE: ros use protobuf 3.6.1 default

### gdal221
# export PATH=$PATH:/usr/local/gdal221/
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/gdal221/lib/

### proj 4.9.3
# export PATH=$PATH:/usr/local/PROJ-4.9.3/bin/
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/PROJ-4.9.3/lib/

# gtsam-4.2.0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/gtsam-4.2.0/lib

# opncv-4.10.0
# export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opencv-4.10.0/lib/pkgconfig 
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/opencv-4.10.0/lib

# ceres-1.14.0
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/ceres-1.14.0/lib/cmake/ceres/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/ceres-1.14.0/lib/

# sophus-a621ff
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/sophus-a621ff/lib/

# cuda-12.2
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12.2/lib64
export PATH=$PATH:/usr/local/cuda-12.2/bin
export CUDA_HOME=$CUDA_HOME:/usr/local/cuda-12.2
