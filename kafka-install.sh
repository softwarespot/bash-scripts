#!/usr/bin/env bash

# Linted using https://www.shellcheck.net
set -euo pipefail

EXC_MISSING_DEP=1

VERSION="1.0"
SCRIPT_NAME="Kafka-install.sh"

# CURR_DIR=$(dirname "$0")
ROOT_DIR=$(pwd)
KAFKA_VERSION=$1

die() {
    # URL: https://gist.github.com/daytonn/8677243
    COLOR_END="\\033[0m"
    COLOR_RED="\\033[0;31m"

    echo -e "${COLOR_RED}$@${COLOR_END}" >&2
    exit $EXC_MISSING_DEP
}

kafka_install() {
    KAFKA_FULL_VERSION=$1
    KAFKA_VERSION=$(echo "$KAFKA_FULL_VERSION" | cut -d"-" -f1)
    SCALA_VERSION=$(echo "$KAFKA_FULL_VERSION" | cut -d"-" -f2)

    KAFKA_SYMLINK_DIR=$HOME/bin/kafka
    KAFKA_INSTALL_DIR=$HOME/workspaces/kafka
    KAFKA_INSTALL_FULL_DIR=$KAFKA_INSTALL_DIR/kafka_$KAFKA_FULL_VERSION
    KAFKA_INSTALL_BIN_DIR="$KAFKA_INSTALL_FULL_DIR/bin"
    KAFKA_TAR_GZ_FILE=kafka_$KAFKA_FULL_VERSION.tgz
    KAFKA_URL="https://downloads.apache.org/kafka/$SCALA_VERSION/$KAFKA_TAR_GZ_FILE"

    echo "Kafka v$KAFKA_VERSION"
    echo "Scala v$SCALA_VERSION"

    mkdir -p "$KAFKA_INSTALL_DIR" 2> /dev/null

    echo "Downloading v$KAFKA_FULL_VERSION from \"$KAFKA_URL\""
    curl -O "$KAFKA_URL"

    echo "Removing existing installation from \"$KAFKA_INSTALL_DIR/$KAFKA_FULL_VERSION\""
    rm -fr "$KAFKA_INSTALL_FULL_DIR" 2> /dev/null

    echo "Installing to \"$KAFKA_INSTALL_DIR\""
    tar -C "$KAFKA_INSTALL_DIR" -xzf "$KAFKA_TAR_GZ_FILE"
    rm -f "$KAFKA_TAR_GZ_FILE"

    echo "Updating symlink \"$KAFKA_SYMLINK_DIR\" to \"$KAFKA_INSTALL_DIR\""
    sudo rm "$KAFKA_SYMLINK_DIR"

    # Requires sudo rights
    sudo ln -s "$KAFKA_INSTALL_BIN_DIR" "$KAFKA_SYMLINK_DIR"

    echo "Successfully referencing v$KAFKA_FULL_VERSION via \"$KAFKA_SYMLINK_DIR\""
}

usage() {
  echo -n "Usage: $SCRIPT_NAME <VERSION> [OPTION]...

Install Kafka for the specified version

 Options:
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
            KAFKA_VERSION=$1
            ;;
        esac
        shift
done

if [[ -z "$KAFKA_VERSION" ]]; then
    usage
    exit
fi

kafka_install "$KAFKA_VERSION"
