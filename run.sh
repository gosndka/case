#!/bin/bash

get_latest_version() {
    local uri
    local version
    uri="https://api.github.com/repos/jpillora/cloud-torrent/releases/latest"
    version=$(curl -s "$uri" | grep -oP '"tag_name": "\\K(.\*)(?=")')
    echo "$version"
}

get_url() {
    local version
    version=$(get_latest_version)
    echo "https://github.com/jpillora/cloud-torrent/releases/download/$version/cloud-torrent_linux_amd64"
}

get_host() {
	local host
	host=$(hostname -A)
	echo "$host:$PORT" | tr -d ' '
}

wget -q $(get_url) -O cloud-torrent
chmod +x cloud-torrent

auto_pinger() {
    host=$(get_host)
    ./cloud-torrent & P1=$!
    while :; do
        sleep 1200
        curl --silent --url "$host"
    done & P2=$!
    wait $P1 $P2
}

if "$PINGER"; then
    auto_pinger
else
    ./cloud-torrent
fi
