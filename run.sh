#!/bin/bash

for ((i=0;i<15;i++))
do
    MYSQL_CONNECTABLE=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P3306 -e 'status' >/dev/null 2>&1; echo "$?")
    if [[ MYSQL_CONNECTABLE -eq 0 ]]; then
        break
    fi
    sleep 3
done

bin/typo3cms install:generatepackagestates --activate-default=true

if [ ! -f typo3conf/LocalConfiguration.php ];
then
    bin/typo3cms install:setup --non-interactive \
                 --database-host-name="$MYSQL_HOST" \
                 --database-port="3306" \
                 --database-user-name="$MYSQL_USER" \
                 --database-user-password="$MYSQL_PASSWORD" \
                 --database-name="$MYSQL_DATABASE" \
                 --useExistingDatabase=false \
                 --admin-user-name="$MYSQL_USER" \
                 --admin-password="$MYSQL_PASSWORD" \
                 --site-name="TYPO3 Docker Demo"
fi

bin/typo3cms cache:flush
bin/typo3cms extension:activate introduction
bin/typo3cms extension:setupactive

chown -R www-data:www-data /var/www/html
apache2-foreground
