#!/bin/bash

#read config file
source $1
echo read config file

CURRENTDIRECTORY=$(pwd)

# cd into directory of VM and ssh to start wordmove
cd "$DIRECTORYNAME"
#vagrant ssh -c '/home/vagrant/prenesi.sh && exit'
vagrant ssh -c 'cd /vagrant && wordmove push --all && exit'
cd "$CURRENTDIRECTORY"
echo moved wp, sql dump file is on server

# remove old sql dump file, download of new one
rm "$SQLDUMPNAME"
echo removed old sql dump file
wget $WPURL/wp-content/dump.sql
echo saved local copy of sql dump file

# replace strings in sql dump for compatibility with 5.1 mysql server
sed -ie 's/utf8mb4_unicode_520_ci/utf8_general_ci/g' dump.sql
sed -ie 's/utf8mb4/utf8/g' dump.sql

# delete edit file and rename sql dump
rm dump.sqle
mv dump.sql "$SQLDUMPNAME"
echo patched sql dump file for compatibility

# ssh into server to remove sql dump
ssh $SSHLOGIN "rm $PATHTOWPINSTALL/wp-content/dump.sql"
echo removed sql dump file from wp install on server
echo please login into phpmyadmin and import "$SQLDUMPNAME" from current folder

# open phpmyadmin to import the generated sql dump
firefox "$PHPMYADMINURL"
