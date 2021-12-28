#!/bin/bash
echo Uninstall old php7.x installation
apt remove -y libapache2-mod-php7.4* php-apcu-bc* php7.0-apcu* php7.0-apcu-bc* php7.0-imagick* php7.1-apcu* php7.1-apcu-bc* php7.1-imagick* php7.2-apcu* php7.2-apcu-bc* php7.2-imagick* php7.3-apcu* php7.3-apcu-bc* php7.3-bcmath* php7.3-bz2* php7.3-cli* php7.3-common* php7.3-curl* php7.3-fpm* php7.3-gd* php7.3-imagick* php7.3-intl* php7.3-json* php7.3-ldap* php7.3-mbstring* php7.3-mysql* php7.3-opcache* php7.3-readline* php7.3-xml* php7.3-zip* php7.4* php7.4-apcu* php7.4-apcu-bc* php7.4-bcmath* php7.4-bz2* php7.4-cli* php7.4-common* php7.4-curl* php7.4-fpm* php7.4-gd* php7.4-gmp* php7.4-igbinary* php7.4-imagick* php7.4-intl* php7.4-json* php7.4-mbstring* php7.4-mysql* php7.4-opcache* php7.4-readline* php7.4-redis* php7.4-smbclient* php7.4-soap* php7.4-xml* php7.4-zip*

# Add Repo for PHP8
echo "deb [arch=amd64] https://packages.sury.org/php/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/php.list

echo Import Key for trusting to source
wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -

echo Update local sources
apt update 

echo Install PHP8
apt install php8.0-{fpm,gd,mysql,curl,xml,zip,intl,mbstring,bz2,ldap,apcu,bcmath,gmp,imagick,igbinary,redis,smbclient,cli,common,opcache,readline} imagemagick

a2enmod proxy_fcgi setenvif
a2enconf php8.0-fpm
systemctl reload apache2

echo Do some modifications
cp /etc/php/8.0/fpm/pool.d/www.conf /etc/php/8.0/fpm/pool.d/www.conf.bak
cp /etc/php/8.0/fpm/php-fpm.conf /etc/php/8.0/fpm/php-fpm.conf.bak
cp /etc/php/8.0/cli/php.ini /etc/php/8.0/cli/php.ini.bak
cp /etc/php/8.0/fpm/php.ini /etc/php/8.0/fpm/php.ini.bak
cp /etc/php/8.0/fpm/php-fpm.conf /etc/php/8.0/fpm/php-fpm.conf.bak
cp /etc/php/8.0/mods-available/apcu.ini /etc/php/8.0/mods-available/apcu.ini.bak
cp /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.bak

AvailableRAM=$(awk '/MemAvailable/ {printf "%d", $2/1024}' /proc/meminfo)
AverageFPM=$(ps --no-headers -o 'rss,cmd' -C php-fpm8.0 | awk '{ sum+=$1 } END { printf ("%d\n", sum/NR/1024,"M") }')
FPMS=$((AvailableRAM/AverageFPM))
PMaxSS=$((FPMS*2/3))
PMinSS=$((PMaxSS/2))
PStartS=$(((PMaxSS+PMinSS)/2))

sed -i "s/;env\[HOSTNAME\] = /env[HOSTNAME] = /" /etc/php/8.0/fpm/pool.d/www.conf
sed -i "s/;env\[TMP\] = /env[TMP] = /" /etc/php/8.0/fpm/pool.d/www.conf
sed -i "s/;env\[TMPDIR\] = /env[TMPDIR] = /" /etc/php/8.0/fpm/pool.d/www.conf
sed -i "s/;env\[TEMP\] = /env[TEMP] = /" /etc/php/8.0/fpm/pool.d/www.conf
sed -i "s/;env\[PATH\] = /env[PATH] = /" /etc/php/8.0/fpm/pool.d/www.conf
sed -i 's/pm.max_children =.*/pm.max_children = '$FPMS'/' /etc/php/8.0/fpm/pool.d/www.conf
sed -i 's/pm.start_servers =.*/pm.start_servers = '$PStartS'/' /etc/php/8.0/fpm/pool.d/www.conf
sed -i 's/pm.min_spare_servers =.*/pm.min_spare_servers = '$PMinSS'/' /etc/php/8.0/fpm/pool.d/www.conf
sed -i 's/pm.max_spare_servers =.*/pm.max_spare_servers = '$PMaxSS'/' /etc/php/8.0/fpm/pool.d/www.conf
sed -i "s/;pm.max_requests =.*/pm.max_requests = 1000/" /etc/php/8.0/fpm/pool.d/www.conf
sed -i "s/allow_url_fopen =.*/allow_url_fopen = 1/" /etc/php/8.0/fpm/php.ini

sed -i "s/output_buffering =.*/output_buffering = 'Off'/" /etc/php/8.0/cli/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 3600/" /etc/php/8.0/cli/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php/8.0/cli/php.ini
sed -i "s/post_max_size =.*/post_max_size = 10240M/" /etc/php/8.0/cli/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 10240M/" /etc/php/8.0/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = Europe\/\Berlin/" /etc/php/8.0/cli/php.ini

sed -i "s/memory_limit = 128M/memory_limit = 2048M/" /etc/php/8.0/fpm/php.ini
sed -i "s/output_buffering =.*/output_buffering = 'Off'/" /etc/php/8.0/fpm/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 3600/" /etc/php/8.0/fpm/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php/8.0/fpm/php.ini
sed -i "s/post_max_size =.*/post_max_size = 10240M/" /etc/php/8.0/fpm/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 10240M/" /etc/php/8.0/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = Europe\/\Berlin/" /etc/php/8.0/fpm/php.ini
sed -i "s/;session.cookie_secure.*/session.cookie_secure = True/" /etc/php/8.0/fpm/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/8.0/fpm/php.ini
sed -i "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" /etc/php/8.0/fpm/php.ini
sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php/8.0/fpm/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php/8.0/fpm/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/" /etc/php/8.0/fpm/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=1/" /etc/php/8.0/fpm/php.ini
sed -i "s/;opcache.save_comments=.*/opcache.save_comments=1/" /etc/php/8.0/fpm/php.ini

sed -i "s|;emergency_restart_threshold.*|emergency_restart_threshold = 10|g" /etc/php/8.0/fpm/php-fpm.conf
sed -i "s|;emergency_restart_interval.*|emergency_restart_interval = 1m|g" /etc/php/8.0/fpm/php-fpm.conf
sed -i "s|;process_control_timeout.*|process_control_timeout = 10|g" /etc/php/8.0/fpm/php-fpm.conf

sed -i '$aapc.enable_cli=1' /etc/php/8.0/mods-available/apcu.ini

sed -i "s/rights=\"none\" pattern=\"PS\"/rights=\"read|write\" pattern=\"PS\"/" /etc/ImageMagick-6/policy.xml
sed -i "s/rights=\"none\" pattern=\"EPS\"/rights=\"read|write\" pattern=\"EPS\"/" /etc/ImageMagick-6/policy.xml
sed -i "s/rights=\"none\" pattern=\"PDF\"/rights=\"read|write\" pattern=\"PDF\"/" /etc/ImageMagick-6/policy.xml
sed -i "s/rights=\"none\" pattern=\"XPS\"/rights=\"read|write\" pattern=\"XPS\"/" /etc/ImageMagick-6/policy.xml

systemctl reload apache2
systemctl restart php8.0-fpm

echo Done - you can now use PHP8
