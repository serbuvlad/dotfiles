#!/bin/zsh

function p() {
	if [ -t 1 ]
	then
		printf '\n\033[35m%s\033[0m\n\n' "$@"
	else
		printf '%s\n' "$@"
	fi
}



function install-scripts() {
	p 'Installing scripts'

	mkdir -p "${HOME}/bin"

	rsync -avv bin/ "${HOME}/bin"
}

function install-yt-dlp() {
	p 'Installing yt-dlp'

	mkdir -p "${HOME}/bin"

	curl -Lo "${HOME}/bin/yt-dlp" 'https://github.com/yt-dlp/yt-dlp/releases/download/2023.07.06/yt-dlp'
	chmod +x "${HOME}/bin/yt-dlp"
	yt-dlp -U
}

function install-zshrc() {
	p 'Installing .zshrc.d files'

	mkdir -p "${HOME}/.zshrc.d"

	rsync -avv zshrc.d/ "${HOME}/.zshrc.d"

	if ! grep -Eq '^# Source .zshrc.d files$' "${HOME}/.zshrc"
	then
		echo '
# Source .zshrc.d files
for file in `ls "${HOME}/.zshrc.d"`
do
	source "${HOME}/.zshrc.d/${file}"
done
' \
		>> "${HOME}/.zshrc"
	fi
}

function install-config-alacritty() {
	p 'Installing config for alacritty'

	sudo mkdir -p /etc/xdg/alacritty

	if [ -f /etc/xdg/alacritty/alacritty.yml ]
	then
		sudo rm /etc/xdg/alacritty/alacritty.yml
	fi

	sudo rsync -avv etc/xdg/alacritty/ /etc/xdg/alacritty
}

function install-config-tmux() {
	p 'Installing config for tmux'

	if ! [ -d ~/.config/tmux/plugins/tpm ]
	then
		git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
	fi

	rsync -avv config/tmux/ ~/.config/tmux

	tmux source ~/.config/tmux/tmux.conf
}

function install-config-all() {
	install-config-alacritty
	install-config-tmux
}

function install-all() {
	install-scripts
	install-yt-dlp
	install-zshrc

	install-config-all
}

if [ "$#" -gt 0 ]
then
	for thing in "$@"
	do
		"install-${thing}"
	done
else
	install-all
fi
