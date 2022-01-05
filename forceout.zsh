#!/bin/zsh

# Author: Andrew W. Johnson
# Date: 2021.09.30
# Organization: Stony Brook University/DoIT

# Version: 1.01
# Added some logging and fixed a typo.


# Version: 1.00
# This script will remove the trigger file then reboot the system.
# It is called by a LaunchDaemon plist which is always watching /Users/Shared/ForceOut/


	# Remove the trigger file.
/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) $( /usr/bin/basename ${0} )[$$]: Removing the trigger file..." >> /Users/Shared/idletime.log
/bin/rm -Rf /Users/Shared/ForceOut/trigger
	# Run the shutdown command.
/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) $( /usr/bin/basename ${0} )[$$]: Restarting the computer." >> /Users/Shared/idletime.log
/sbin/shutdown -r now

exit 0
