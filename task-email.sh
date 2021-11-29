#!/usr/bin/env bash

#email myself info about upcoming tasks in a pretty HTML format
# Requires ssmtp
# cron: 30 5 * * 1-6 /home/user/bin/taskwarrior-notifications/task-email.sh

# Pull in the config variables
dir="$( cd "$( dirname "$0" )" && pwd )"
 
if [ -f "${dir}"/config ]; then
  source "${dir}"/config
else
  echo "No configuration file found. Maybe you need to copy and edit the example.config file to config."
  exit 1
fi

# taskrc defaults
taskrc="rc.json.array=off rc.verbose=nothing"

# Format time string
date=$(date '+%F') #07/09/2012

echo > "${tmp_email}"

eow=$(date -d "monday" +%F) # end of week
eonw=$(date -d "1 week monday" +%F) # end of next week

# Get the template loaded up
cat "${templates}"/html_email_head.template >> "${tmp_email}"
echo "<h1>Task Info: $date</h1>" >> "${tmp_email}"

# Overdue
echo "<h2>Overdue</h2>" >> "${tmp_email}"
echo $(task "+OVERDUE and +PENDING" export "${taskrc}" | sed 's?\\/?/?g' | "${scripts}"/export-html.py) >> "${tmp_email}"

if [[ $(date +%u) -lt 6 ]] ; then # Weekday

# Today
echo "<h2>Today</h2>" >> "${tmp_email}"
echo $(task "+TODAY and +PENDING" export "${taskrc}" | sed 's?\\/?/?g' | "${scripts}"/export-html.py) >> "${tmp_email}"
# This Week (but not today)
echo "<h2>This Week</h2>" >> "${tmp_email}"
echo $(task "+WEEK and -DELETED and -COMPLETED and +PENDING" export "${taskrc}" | sed 's?\\/?/?g' | "${scripts}"/export-html.py) >> "${tmp_email}"

else

# This Weekend
echo "<h2>This Weekend</h2>" >> "${tmp_email}"
if [[ $(date +%u) -eq 6 ]] ; then # Saturday 
  echo $(task "(+TODAY or +TOMORROW) and +PENDING" export "${taskrc}" | sed 's?\\/?/?g' | "${scripts}"/export-html.py) >> "${tmp_email}"
else # Sunday
  echo $(task "(+YESTERDAY or +TODAY) and +PENDING" export "${taskrc}" | sed 's?\\/?/?g' | "${scripts}"/export-html.py) >> "${tmp_email}"
fi

fi

# Next Week
echo "<h2>Next Week</h2>" >> "${tmp_email}"
echo $(task "(due.after:${eow} and (due.before:${eonw} or due:${eonw}) and +PENDING)" export "${taskrc}" | sed 's?\\/?/?g' | "${scripts}"/export-html.py) >> "${tmp_email}"

cat "${templates}"/html_email_foot.template >> "${tmp_email}"

# Send the email
/usr/bin/mutt -e "set content_type=text/html" -s "Task Report for $(date)" $sendto < "${tmp_email}"
#$mail_prog $sendto < "${tmp_email}"
rm "${tmp_email}"
