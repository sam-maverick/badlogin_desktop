#!/bin/bash

# Check https://github.com/sam-maverick/badlogin_desktop for license details

sleep 8

## Parameters
MAXNEGATIVECOUNT=1000

#Set $1 to true if the script is called at startup
#Set $1 to false if the script is called as a routine call on screen unlock event

### Do the work

SHOWWARNING="false"
TITLE=""
MESSAGE=""

FULLREPORT=`aureport --input-logs --auth --no-config --escape shell_quote 2> /dev/null | tail -n +6 | grep -v ' gdm ' | grep -v ' /usr/bin/sudo '`
NUMLINES=`echo -n "$FULLREPORT" | grep -c '^'`
LAST=`echo "$FULLREPORT" | awk 'END{print $(NF-1)}'`
PENULTIMATE=`echo "$FULLREPORT" | tail -n 2 | head -n 1 | awk 'END{print $(NF-1)}'`
PENULTIMATETIME=`echo "$FULLREPORT" | tail -n 2 | head -n 1 | awk 'END{print $2 , $3}'`

if [ "$LAST" == "no" ] ; then
	# This script is executed after successful logging in, so last record in audit log should be yes/successful
	SHOWWARNING="true"
	TITLE="EXCEPTION in software/code/lockscreen.sh"
	MESSAGE="Unhandled exception checking the aureport audit log: Last successful login was unsuccessful"
else
    if [ "$LAST" == "yes" ] && [ "$PENULTIMATE" == "yes" ] ; then
	   # The penultimate authentication attempt was successful (only Gnome; excluding sudo). Nothing to do
	   echo "$(date) Nothing to report" >> $HOME/software/code/lockscreen.log
	   echo "Nothing to report";
	else
	    if [ "$LAST" == "yes" ] && [ "$PENULTIMATE" == "no" ] ; then
		   	# The penultimate authentication attempt was (un?)successful. Let's count how many
			# When the penultimate line is "no", count the total consecutive backwards "no",
			#including that penultimate line
			NEGATIVES=0
			LINE=2
			while [ $LINE -le $NUMLINES ] ; do
			    if [ $NEGATIVES -ge $MAXNEGATIVECOUNT ] ; then
				    NEGATIVES="${MAXNEGATIVECOUNT}+";
				    break;
			    fi
			    if [ "`echo \"$FULLREPORT\" | tail -n $LINE | head -n 1 | awk 'END{print $(NF-1)}'`" == "no" ] ; then
                    if [ $NEGATIVES != "0" ] ; then
                        FIRSTINTHELINETIME=`echo "$FULLREPORT" | tail -n $LINE | head -n 1 | awk 'END{print $2 , $3}'`
                    fi
				    NEGATIVES=$(($NEGATIVES+1));
				    LINE=$(($LINE+1));
			    else
    				break;
			    fi
			done
            ADDTEXT=""
            if [ $1 = "true" ] ; then ADDTEXT="Startup message:\n" ; fi
			SHOWWARNING=true
			TITLE="AUDIT WARNING"
			if [ "$FIRSTINTHELINETIME" == "" ] ; then
    			MESSAGE="${ADDTEXT}Previous login @ $PENULTIMATETIME was <b>unsuccessful!</b>"
            else
			    MESSAGE="${ADDTEXT}Previous logins\n    @ $FIRSTINTHELINETIME \n    [...]\n    @ $PENULTIMATETIME\nwere <b>unsuccessful!</b>\n\n$NEGATIVES unsuccessful attempts in a row."
	        fi
    	else
			SHOWWARNING=true
			TITLE="EXCEPTION in software/code/lockscreen.sh"
			MESSAGE="Unhandled exception: Unexpected value"
		fi

		if [ "$SHOWWARNING" == "true" ] ; then 
	        echo "$(date) Alerting via popup window" >> $HOME/software/code/lockscreen.log
			zenity --no-wrap --warning --title="$TITLE" --text="$MESSAGE";
			echo "$TITLE"
			echo "$MESSAGE"
		fi

		#Clear big variables
		FULLREPORT=""
	fi
fi


