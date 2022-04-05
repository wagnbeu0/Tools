#!/bin/bash
echo Take Nexcloud back online
export ncroot=/var/www/html/nextcloud
cd $ncroot
sudo -u www-data php occ maintenance:mode --off
