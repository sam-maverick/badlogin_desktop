#!/bin/bash

# Check https://github.com/sam-maverick/badlogin_desktop for license details

$HOME/software/code/lockscreen2.sh "true"

dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver',member='ActiveChanged'" | while read line ; do

echo "evaluating"
	if echo "$line" | grep 'true'; then 

		# runs once when screensaver comes on... (screen getting locked)
		#
		# In gnome, the user keyring is not locked when the screen is locked. The keyring is locked on logout, suspend or hybernate, though.
		
		# If you want your computer to perform some tasks when you lock your screen, put the commans here. For instance, you may want to close your browser, for security.
	fi

	if echo "$line" | grep 'false'; then

		# runs once when screensaver goes off... (screen getting unlocked)
		echo "Screen off"
		echo "$(date) Screen off; calling lockscreen2.sh" >> $HOME/software/logs/badlogin_desktop.log
        $HOME/software/code/lockscreen2.sh "false"

	fi

done


