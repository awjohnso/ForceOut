#!/bin/zsh

# Author: Andrew W. Johnson
# Date: 2021.09.30
# Organization: Stony Brook University/DoIT
#
# Version: 1.01
# Added a check to see if a movie, or zoom is playing aka checking for PreventUserIdleDisplaySleep.
# Should that be set to 1, then don't run and exit so not to interrupt a user's session.
# Added some logging. Most of it is disabled, but it will log the user being kicked out.
# Thank you Shaun Kepert @ Stony Brook University.
#
# Version: 1.00
# This script is meant to be called by a launchDaemon every two minutes.
#
# This script uses the jamfHelper app to display information to the enduser.
# It will check system idle time and if it's greater than 5 minutes, it will then
# inform the user with the jamfHelper window that in 10 or 15 minutes the system
# will force the user out with a reboot.
#
# Inspired by the work of Shea G Craig in 2014 with is auto_logout.py: https://github.com/sheagcraig/auto_logout
# auto_logout.py seems to break becuase being run in the user space, the reboot
# command wants admin auth, which is not possible. Also Python is being phazed
# out by Apple and thus will not be present by default on the system.

	# Check for logged in users.
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }' )

	# Should this run with no user logged in exit.
if [[ ! -n ${loggedInUser} ]]; then
#	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) $( /usr/bin/basename ${0} )[$$]: There are no users logged in."  >> /Users/Shared/idletime.log
	exit 0
fi
	# Get the idle time and description text from the preference file.
idleTime=$( /usr/bin/defaults read /Library/Preferences/edu.stonybrook.doit.idletime idleTime )
text=$( /usr/bin/defaults read /Library/Preferences/edu.stonybrook.doit.idletime description )

	# Setup some variables.
jamfHelperPath="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
windowtype="utility"
title="Idle Warning"
heading="Idle warning!"
alignHeading="center"
description="If you are inactive for ${text} more minutes you will be logged out of this workstation."
button1="Logout"
button2="Cancel"
icon="/usr/local/bin/Warning.png"

	# Check to see if a movie, zoom, or other program is preventing sleep or screensaver action.
	# Check PreventUserIdleDisplaySleep: 1 don't sleep, 0 ok to sleep.
PreventUserIdleDisplaySleep=$( /usr/bin/pmset -g assertions | /usr/bin/egrep -iv pid | /usr/bin/awk '/PreventUserIdleDisplaySleep/{print $2}')
if [[ ${PreventUserIdleDisplaySleep} -gt 0 ]]; then
#	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) $( /usr/bin/basename ${0} )[$$]: $( /usr/bin/pmset -g assertions | /usr/bin/egrep -i pid | /usr/bin/egrep -i PreventUserIdleDisplaySleep | /usr/bin/awk -F ":" '{print $1}' ) is running to prevent sleep. Exiting."   >> /Users/Shared/idletime.log
	exit 0
fi

	# Check how long the computer has been idle. The number returned is huge.
myIdleTime=$( /usr/sbin/ioreg -c IOHIDSystem | /usr/bin/egrep -i HIDIdleTime  | /usr/bin/awk -F " " '{print $6}' )

	# If the system idle time is longer than 5 minutes
if [ ${myIdleTime} -ge 300000000000 ]; then
		# Bring up the widow to warn the user they will be logged out in so many minutes.
#	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) $( /usr/bin/basename ${0} )[$$]: Initiating idle warning!" >> /Users/Shared/idletime.log
		# Get the button returned. If the count down times out, button1 (Logout) is automatically returned.
	myButton=$( ${jamfHelperPath} -windowType ${windowtype} -title ${title} -heading ${heading} -alignHeading ${alignHeading} -description ${description} -button1 ${button1} -button2 ${button2} -timeout ${idleTime} -countdown -icon ${icon} )
		# If Logout button (0) is returned either by timeout or user click, then kill the session.
	if [[ ${myButton} -eq 0 ]]; then
		/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) $( /usr/bin/basename ${0} )[$$]: Killing ${loggedInUser}'s session!" >> /Users/Shared/idletime.log
			# Drop a trigger file to reboot the system.
		/usr/bin/touch /Users/Shared/ForceOut/trigger
		exit 0
	elif [[ ${myButton} -eq 2 ]]; then
			# If user cancels just exit this script.
#		/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) $( /usr/bin/basename ${0} )[$$]: User Canceled." >> /Users/Shared/idletime.log
		exit 0
	fi
else
		# System is not idle for more than 5 minutes, no need to warn user yet.
#	/bin/echo "$( /bin/date | /usr/bin/awk '{print $1, $2, $3, $4}' ) $( /usr/sbin/scutil --get LocalHostName ) $( /usr/bin/basename ${0} )[$$]: Under five minutes, there is no need to warn yet." >> /Users/Shared/idletime.log
	exit 0
fi

exit 0
