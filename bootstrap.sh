#!/bin/bash

set -u # set -o nounset
set -e # set -o errexit

VERSION="1.1"
DATE="2019-02-16"

RED=`tput setaf 1`
GREEN=`tput setaf 2`
DEFAULT=`tput sgr0`

SCRIPT_FILE="bootstrap.sh"
SCRIPT_SOURCE="https://raw.githubusercontent.com/evasio/buildscripts/master/${SCRIPT_FILE}"

UPDATE_BREW=1

echo ""
echo "${GREEN}Running Evasio Bootstrap v${VERSION} (${DATE})${DEFAULT}"
echo "${GREEN}==========================================${DEFAULT}"
echo ""
echo "${GREEN}  You can update this script by running \"${SCRIPT_FILE} -u\" ${DEFAULT}"
echo ""

if [[ $# -eq 1 ]] && [[ $1 == "-u" ]]; then
	echo ""
	echo " > ${GREEN}Updating ${SCRIPT_FILE}${DEFAULT}";
	curl -L $SCRIPT_SOURCE?$(date +%s) -o $0
	exit 1
fi

install_with_brew() {
	if [ $UPDATE_BREW -eq 1 ]; then
		echo ""
		echo " > ${GREEN}Updating BREW${DEFAULT}";

		# update brew to keep dependencies up to date
		brew update || echo " > ${RED}Failed to update BREW${DEFAULT}";
		UPDATE_BREW=0
	fi

	echo ""
	echo " > ${GREEN}Installing $1 with BREW${DEFAULT}";

	# install dependency, if is not installed
	brew list $1 || brew install $1 || echo " > ${RED}Failed to install $1 ${DEFAULT}";

	# upgrade dependency, if it is outdated
	brew outdated $1 || brew upgrade $1 || echo " > ${RED}Failed to upgrade $1 ${DEFAULT}";
}

if [ -e "Mintfile" ]; then
	install_with_brew mint
	mint bootstrap
fi

if [ -e "Cartfile" ]; then
	install_with_brew carthage
	# carthage update --platform iOS
fi

if [ -e "project.yml" ]; then
	mint run xcodegen
fi
