#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

EXC_MISSING_DEP=1

VERSION="1.0"
SCRIPT_NAME="k9s-install.sh"

# CURR_DIR=$(dirname "$0")
ROOT_DIR=$(pwd)
K9S_VERSION=$1

die() {
    # URL: https://gist.github.com/daytonn/8677243
    COLOR_END="\\033[0m"
    COLOR_RED="\\033[0;31m"

    echo -e "${COLOR_RED}$*${COLOR_END}" >&2
    exit $EXC_MISSING_DEP
}

k9s_install() {
    K9S_VERSION=$1
    K9S_INSTALL_DIR="$HOME/bin"
    K9S_TAR_GZ_INSTALL_DIR="$HOME/k9s_extracted"
    K9S_TAR_GZ_FILE=k9s_Linux_amd64.tar.gz

    mkdir -p "$K9S_TAR_GZ_INSTALL_DIR"

    echo "Downloading v$K9S_VERSION"
    echo "curl -L https://github.com/derailed/k9s/releases/download/v$K9S_VERSION/$K9S_TAR_GZ_FILE -o $K9S_TAR_GZ_INSTALL_DIR/$K9S_TAR_GZ_FILE"
    curl -L "https://github.com/derailed/k9s/releases/download/v$K9S_VERSION/$K9S_TAR_GZ_FILE" -o "$K9S_TAR_GZ_INSTALL_DIR/$K9S_TAR_GZ_FILE"

    echo "Installing to \"$K9S_TAR_GZ_INSTALL_DIR\""
    tar -C "$K9S_TAR_GZ_INSTALL_DIR" -xzf "$K9S_TAR_GZ_INSTALL_DIR/$K9S_TAR_GZ_FILE"
    cp "$K9S_TAR_GZ_INSTALL_DIR/k9s" "$K9S_INSTALL_DIR/k9s"
    rm -r "$K9S_TAR_GZ_INSTALL_DIR"

    echo "Successfully downloaded v$K9S_VERSION and installed to \"$K9S_INSTALL_DIR\""
}

usage() {
  echo -n "Usage: $SCRIPT_NAME <VERSION> [OPTION]...

Install k9s for the specified version

 Options:
   -f, --force     Force re-downloading
   -h, --help      Display this help and exit
       --version   Display version information and exit
"
}

cd "$ROOT_DIR" || die "Unable to change the directory to \"$ROOT_DIR\""

# Commandline parsing
while [ "$1" != "" ]; do
	case $1 in
        -h | --help)
            usage
            exit
            ;;
        --version)
            echo "$VERSION"
            exit
            ;;
        *)
            K9S_VERSION=$1
            ;;
        esac
        shift
done

if [[ -z "$K9S_VERSION" ]]; then
    usage
    exit
fi

k9s_install "$K9S_VERSION"
