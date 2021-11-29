#!/bin/bash

# email myself info about upcoming tasks in a pretty HTML format
# Basic idea conceived by Kevin Owens at: 
#   http://taskwarrior.org/boards/1/topics/495#message-552
# Requires ssmtp and ansi2html script. It should be easy to substitute
#   another smtp program, if you do, please let me know and I'll update this
# cron: 30 5 * * 1-6 /home/user/bin/taskwarrior-notifications/task-email.sh

# Pull in the config variables
dir="$( cd "$( dirname "$0" )" && pwd )"

if [ -f $dir/config ]
then
  source $dir/config
else
  echo "No configuration file found. Maybe you need to copy and edit the example.config file to config."
  exit 1
fi

if [ $(task rc.verbose=nothing today | wc -l) != 0 ]
then
	(echo "<pre>" ; task today ; echo "</pre>") | /usr/bin/mutt -e "set content_type=text/html" -s "Task Report other for $(date)" $sendto 
fi
