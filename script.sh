#!/bin/bash

# Linux MySQL Database FTP Backup Script
# Version: 1.1
# Script by: Pietro Marangon
# Skype: pe46dro
# Email: pietro.marangon@gmail.com
# SFTP function by unixfox and Pe46dro
# EDITED TO SUPPORT SQL Backup & Server Backup

backup_path="/root"

create_backup() {
  umask 177

  FILE="$db_name-$d.sql"
  mysqldump --user=$user --password=$password --host=$host $db_name > /home/backup/$FILE

  echo 'Backup Complete'
}

clean_backup() {
  rm -f $backup_path/$FILE.sql
  rm -f ./$FILE
  echo 'Local Backup Removed'
}

########################
# Edit Below This Line #
########################

# Database credentials

user="USER HERE"
password="DATABASE PASS"
host="localhost"
db_name="DATABASE NAME"

# FTP Login Data
USERNAME="root"
PASSWORD="SSH PASSWORD"
SERVER="SERVER IP"
PORT="22"

#Directory where thing to backup is located
DIR="/root"

#Remote directory where the backup will be placed
REMOTEDIR="/home/backup"


#Transfer type
#1=FTP
#2=SFTP
TYPE=2

##############################
# Don't Edit Below This Line #
##############################

d=$(date --iso)
cd $backup_path
create_backup

FILE=$FILE"_"$d".tar.gz"
tar -czvf ./$FILE $DIR #$DIR2
echo 'Tar Complete'

if [ $TYPE -eq 1 ]
then
ftp -n -i $SERVER <<EOF
user $USERNAME $PASSWORD
binary
mput $FILE $REMOTDIR/$FILE
quit
EOF
elif [ $TYPE -eq 2 ]
then
rsync --rsh="sshpass -p $PASSWORD ssh -p $PORT -o StrictHostKeyChecking=no -l $USERNAME" $backup_path/$FILE $SERVER:$REMOTEDIR
else
echo 'Please select a valid type'
fi

echo 'Remote Backup Complete'
clean_backup
#END
