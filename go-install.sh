#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

EXC_MISSING_DEP=1

VERSION="1.0"
SCRIPT_NAME="go-install.sh"

# CURR_DIR=$(dirname "$0")
ROOT_DIR=$(pwd)
GO_VERSION=$1
GO_INSTALL_TYPE="inUsrLocal"

die() {
    # URL: https://gist.github.com/daytonn/8677243
    COLOR_END="\\033[0m"
    COLOR_RED="\\033[0;31m"

    echo -e "${COLOR_RED}$*${COLOR_END}" >&2
    exit $EXC_MISSING_DEP
}

# See URL: https://www.pugetsystems.com/labs/hpc/install-golang-in-your-home-directory-and-configure-vscode/
go_install() {
    GO_VERSION=$1
    GO_INSTALL_TYPE=$2

    echo "Downloading v$GO_VERSION"

    GO_TAR_GZ_FILE=go$GO_VERSION.linux-amd64.tar.gz
    curl -L -O "https://go.dev/dl/$GO_TAR_GZ_FILE"

    if [[ $GO_INSTALL_TYPE == "inHome" ]]; then
        GO_INSTALL_DIR="$HOME/go-installed"

        echo "Installing to \"$GO_INSTALL_DIR/go\""
        mkdir -p "$GO_INSTALL_DIR"
        rm -fr "$GO_INSTALL_DIR/go"
        tar -C "$GO_INSTALL_DIR" -xzf "$GO_TAR_GZ_FILE"
    else
        GO_INSTALL_DIR="/usr/local"
        echo "Installing to \"$GO_INSTALL_DIR/go\""
        sudo rm -fr "$GO_INSTALL_DIR/go"
        sudo tar -C "$GO_INSTALL_DIR" -xzf "$GO_TAR_GZ_FILE"
    fi

    rm "$GO_TAR_GZ_FILE"

    echo "Successfully downloaded v$GO_VERSION and installed to \"$GO_INSTALL_DIR/go\""

     if [[ $GO_INSTALL_TYPE == "inHome" ]]; then
        GO_INSTALL_DIR=$HOME
        echo -e "
# Please add the following to \"$HOME/.bashrc\" beforehand
# go
export GOROOT=\"\$HOME/go-installed/go\"
export GOPRIVATE=
export PATH=\"\$PATH:\$GOROOT/bin\""
    else
        echo -e "
# Please add the following to \"$HOME/.bashrc\" beforehand
# go
export GOPRIVATE=
export PATH=\"$GO_INSTALL_DIR/go/bin:\$HOME/go/bin:\$PATH\""
    fi
}

usage() {
  echo -n "Usage: $SCRIPT_NAME <VERSION> [OPTION]...

Install Go for the specified version

 Options:
   -l, --inHome    Install in the user's home directory instead of \"/usr/local/\"
   -h, --help      Display this help and exit
       --version   Display version information and exit
"
}

cd "$ROOT_DIR" || die "Unable to change the directory to \"$ROOT_DIR\""

# Commandline parsing
while [ "$1" != "" ]; do
	case $1 in
        -l | --inHome)
            GO_INSTALL_TYPE="inHome"
            ;;
        -h | --help)
            usage
            exit
            ;;
        --version)
            echo "$VERSION"
            exit
            ;;
        *)
            GO_VERSION=$1
            ;;
        esac
        shift
done

if [[ -z "$GO_VERSION" ]]; then
    usage
    exit
fi

go_install "$GO_VERSION" "$GO_INSTALL_TYPE"
