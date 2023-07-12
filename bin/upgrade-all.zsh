#!/bin/zsh

function p() {
	if [ -t 1 ]
	then
		printf '\n\033[35m%s\033[0m\n\n' "$@"
	else
		printf '%s\n' "$@"
	fi
}

function upgrade-apt() {
	p 'Upgrading APT packages'

	sudo apt update
	sudo apt upgrade -y
	sudo apt dist-upgrade -y
	sudo apt autoremove --purge -y
}

function upgrade-flatpak() {
	p 'Upgrading Flatpack packages'

	flatpak update -y
}

function upgrade-yt-dlp() {
	p 'Upgrading yt-dlp'

	yt-dlp -U
}

function upgrade-go() {
	p 'Checking for Go upgrades'

	pushd "$HOME/opt/go"

	git pull origin master
	
	GO_LATEST_RELEASE=`git tag -l | grep -E '^go1\.[0-9][0-9]?\.[0-9][0-9]?$' | sort -rnt . -k 2 | head -n 1`

	if ! git status | grep --silent $GO_LATEST_RELEASE
	then
		p "Upgrading Go to $GO_LATEST_RELEASE"
		
		cd src
		GOAMD64=v3 ./all.bash
		cd ../..
		rsync -vr go ~/opt/go
	else
		echo "Go at latest $GO_LATEST_RELEASE"
	fi

	popd
}

function upgrade-rust() {
	p 'Upgrading the Rust toolchain'

	rustup update
}

function upgrade-kitty() {
	p 'Upgrading the kitty terminal'

	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
		dest="${HOME}/opt" launch=n
}

function upgrade-all() {
	upgrade-apt
	upgrade-flatpak
	upgrade-yt-dlp
	#upgrade-go
	upgrade-rust
}

upgrade-all
