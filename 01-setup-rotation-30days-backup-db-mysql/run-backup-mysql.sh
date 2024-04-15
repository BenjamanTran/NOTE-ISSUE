#!/bin/sh
### System Setup ###
NOW=$(date +%Y-%m-%d)
KEEPDAYS=30
MUSER="username" # XXXX is mt gs number
MPASS="password" # set to MySQL password
MHOST="host"     # XXXX is mt gs number
DBS="db_name"    # space separated list of databases to backup
MDIR="/home/usr/backup"
EMAILID="youremail@gmail.vn" # the email you want notification sent to
attempts=0
for db in $DBS; do                     # for each listed database
	attempts=$(expr $attempts + 1)        # count the backup attempts
	FILE=$MDIR/db-redmine-$db.$NOW.sql.gz # Set the backup filename
	mysqldump -q -u $MUSER -h $MHOST -p$MPASS $db | gzip -9 >$FILE
done
find $MDIR/db-redmine*.sql.gz -type f -daystart -mtime +$KEEPDAYS -exec rm {} \;

localfiles=$(ls $MDIR/*.$NOW.sql.gz)
count=0 # count local files from today
for file in $localfiles; do count=$(expr $count + 1); done
mail -s "Redmine Backups Report $NOW" $EMAILID <<END
Success with $count of $attempts
The following databases were attempted backed up
$DBS
Files stored:
$localfiles
END

# set up crontab -e * 8 1,2,3,4,5 * * /bin/bash mysql_backup.sh
# send notification to SLACKCHANEL
curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"Redmine Backup: \", \"attachments\": [{\"fields\": [{\"title\": \"Date: \", \"value\": \"$NOW\", \"short\": false}, {\"title\": \"DBNAME: \", \"value\": \"$DBS\", \"short\": false}, {\"title\": \"Files stored: \", \"value\": \"$localfiles\", \"short\": false}]}]}" "$SLACKCHANEL"
