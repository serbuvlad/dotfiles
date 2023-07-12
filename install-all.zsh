#!/bin/zsh

function p() {
	if [ -t 1 ]
	then
		printf '\n\033[35m%s\033[0m\n\n' "$@"
	else
		printf '%s\n' "$@"
	fi
}

function install-kitty() {
	p 'Installing the kitty terminal'

	if [ -d "${HOME}/opt/kitty.app" ]
	then
		p 'Removing old kitty install'
		rm -r "${HOME}/opt/kitty.app"
	fi

	# Installation documented at https://sw.kovidgoyal.net/kitty/binary/

	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
		dest="${HOME}/opt" launch=n

	cp ~/opt/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
	cp ~/opt/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/

	sed -i "s|Icon=kitty|Icon=${HOME}/opt/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
	sed -i "s|Exec=kitty|Exec=${HOME}/opt/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
}

function install-scripts() {
	p 'Installing scripts'

	mkdir -p "${HOME}/bin"

	rsync -a bin/ "${HOME}/bin"
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

	rsync -a .zshrc.d/ "${HOME}/.zshrc.d"

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

function install-config-kitty() {
	p 'Installing config for kitty'

	rsync -a .config/kitty/ "${HOME}/.config/kitty"
}

function install-config-all() {
	install-config-kitty
}

function install-all() {
	install-kitty
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
