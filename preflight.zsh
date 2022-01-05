#!/bin/zsh

# Author: Andrew W. Johnson
# Date: 2021.09.30
# Organization: Stony Brook University/DoIT
#
# Version: 1.01

#
# Version: 1.00
# This script is to be a pre flight script for a package installer.
# If the /Library/LaunchDaemons/edu.stonybrook.doit.killsession.plist daemon exists, it will
# try to unload it thus enabling the installer to load it again at the end of the install.


if [[ -e /Library/LaunchDaemons/edu.stonybrook.doit.killsession.plist ]]; then
	# Unload the session killer plist.
	/bin/launchctl unload -w /Library/LaunchDaemons/edu.stonybrook.doit.killsession.plist
fi

exit 0

