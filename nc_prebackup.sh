#!/bin/bash
echo set variables

export ncroot=/var/www/html/nextcloud
export dbusername=`cat $ncroot/config/config.php | grep dbuser | cut -f 2 -d "=" | cut -f2 -d "'"`
export dbpassword=`cat $ncroot/config/config.php | grep dbpassword | cut -f 2 -d "=" | cut -f2 -d "'"`
export dbdatabase=`cat $ncroot/config/config.php | grep dbname | cut -f 2 -d "=" | cut -f2 -d "'"`
export dbbackuppath=$ncroot/data/backups
[[ ! -d $dbbackuppath ]] && mkdir -p $dbbackuppath


echo Take Nextcloud offline into Maintenance mode
cd $ncroot
sudo -u www-data php occ maintenance:mode --on
 
mysqldump --single-transaction -h localhost -u $dbusername -p$dbpassword --databases $dbdatabase > $dbbackuppath/nextcloud-sqlbkp_`date +"%Y%m%d"`.bak
