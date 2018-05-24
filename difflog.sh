#!/bin/bash

# Written by: Unmil Bind
# Compare two files if same or not and will write the differrence in a different log file to keep record of changes happened.
#
# How to run?
# ./differ /path/to/file.txt /path/to/new/backups/directory/of/changes/
# Logs can be found in /var/log/filechange.log
#

# File where logs will be written
touch /var/log/filechange.log

#original=/etc/elasticsearch/elasticsearch.yml
original=$1
#copy=/home/differ/main/elasticsearch.yml
copy=$2
#fileexist=/home/differ/main/
fileexist=$2

# Copy a file from actual file to be compared as it will not be originally present.
exist=`ls $fileexist | grep elasticsearch.yml | wc -l`
if [ $exist -eq 0 ]
then cp $original $fileexist
else echo 'Comparing with an already present file in the directory.'
fi

# Save difference of files in a variable
output=`/usr/bin/diff -y --suppress-common-lines $original $copy`
opcount=`/usr/bin/diff -y --suppress-common-lines $original $copy | wc -l`

if [ $opcount -ne 0 ]
then cp -rf $original   $copy
        echo $original 'is different, has changed from past known file'
        echo "$output" >> /var/log/filechange.log
        echo -e 'Output Logged as \n \n' $output '\n'
	echo 'Sending Mail'

/usr/sbin/sendmail -t -oi  <<EOF
To:<your email id>
Subject: Config File changed.

Configurations changes took place for

$original

Please find the details below :-

$output

EOF

else
        echo 'Files are same'
fi
exit 0;

