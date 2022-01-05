# ForceOut
 Scripts to forcibly reboot a lab computer if a user is logged in too long.
 Makes use of a launch agent, a launch daemon, and two scripts:

**/Library/LaunchDaemons/edu.stonybrook.doit.idletime.plist**
Runs the script: `/usr/local/bin/idletime.zsh` every two minutes.

**/Library/LaunchAgents/edu.stonybrook.doit.killsession.plist**
Runs the script ``/usr/local/bin/forceout.zsh` when the script idletime.zsh drops a trigger file in the folder /Users/Shared/ForceOut/

**/usr/local/bin/idletime.zsh**
We have two sets of idletimes to check for, open computer labs and computer labs that are classrooms. The installer will create the plist: `/Library/Preferences/edu.stonybrook.idletime.plist` and populate it with the proper settings. 

idletime.zsh will get then get the proper idletime from this preference file, and as long as PreventUserIdleDisplaySleep (Zoom,YouTube, VLC could be running...) it will warn the user with a JamfHelper window that the comptuer will get rebooted at the end of the the countdown. The user can cancel or if it times out the script will then put a trigger file in `/Users/Shared/ForceOut/` to trigger `/usr/local/bin/forceout.zsh`.

**/usr/local/bin/forceout.zsh**
Removes the trigger file and the reboots the computer.
	
**/usr/local/bin/Warning.png**
Icon for the JamfHelper tool.
	
**PKG Preflight: preflight.zsh**
Preflight script for the pkg to distribute the above. Unloads the `/Library/LaunchDaemons/edu.stonybrook.doit.idletime.plist` before the installer runs.
	
**PKG Postflight: postflight.zsh**
Postflight checks the existing computer name against a list of comptuers in the script to see which idletime to set in `/Library/Preferences/edu.stonybrook.idletime.plist`.

Creates the trigger directory in `/Users/Shared/ForceOut`. Sets permissions on this directory to be `root:admin`, `666`, and makes it invisible to the Finder.

Create the log file in `/Users/Shared/idletime.log` and sets it to `root:admin`, `666`, and makes it invisible to the Finder.

Finally loads `/Library/LaunchDaemons/edu.stonybrook.doit.idletime.plist` so a reboot is not necessary.