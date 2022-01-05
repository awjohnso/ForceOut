#!/bin/zsh

# Author: Andrew W. Johnson
# Date: 2021.09.30
# Organization: Stony Brook University/DoIT
#
# Version: 1.01
# Fixed the idle time for Fine Arts and Hybrid to 900 not 1200.
# Added the logfile creation.
#
# Version: 1.00
# This script is to be a post flight script for a package installer.
# It will create the preference file for a script and a watched folder, and finally
# it will load a launch daemon.

	# Ensure myname is set to lower case.
typeset -l myname
	# Get the computer name.
myname=$( /usr/sbin/networksetup -getcomputername | /usr/bin/cut -c 1-3 )
/bin/echo ${myname}

	# If the computer is a HYB or FAM computer then set the idle time to 15 minutes.
if [ "${myname}" = "fam" ] || [ "${myname}" = "hyb" ]; then
	idleTime=900
	description="fifteen (15)"
else
		# Else set idle time to twn minutes.
	idleTime=600
	description="ten (10)"
fi
/bin/echo ${idleTime}
/bin/echo ${description}

	# Write the idletime plist.
/usr/bin/defaults write /Library/Preferences/edu.stonybrook.doit.idletime idleTime -int ${idleTime}
/usr/bin/defaults write /Library/Preferences/edu.stonybrook.doit.idletime description -string ${description}

	# Create the watched directory and set ownership, permissions, and Finder visibility.
/bin/mkdir /Users/Shared/ForceOut
/usr/sbin/chown root:admin /Users/Shared/ForceOut
/bin/chmod 777 /Users/Shared/ForceOut
/usr/bin/chflags hidden /Users/Shared/ForceOut

	# Create the logfile and set ownership, permissions, and Finder visibility.
/usr/bin/touch /Users/Shared/idletime.log
/usr/sbin/chown root:admin /Users/Shared/idletime.log
/bin/chmod 666 /Users/Shared/idletime.log
/usr/bin/chflags hidden /Users/Shared/idletime.log

	# Load the session killer plist.
/bin/launchctl load -w /Library/LaunchDaemons/edu.stonybrook.doit.killsession.plist

exit 0

