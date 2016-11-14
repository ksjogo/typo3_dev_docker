#!/bin/bash

for ((i=0;i<15;i++))
do
    MYSQL_CONNECTABLE=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P3306 -e 'status' >/dev/null 2>&1; echo "$?")
    if [[ MYSQL_CONNECTABLE -eq 0 ]]; then
        break
    fi
    sleep 3
done

vendor/helhum/typo3-console/Scripts/typo3cms install:generatepackagestates --activate-default=true
vendor/helhum/typo3-console/Scripts/typo3cms install:setup --non-interactive \
                                             --database-user-name="$MYSQL_USER" \
                                             --database-host-name="$MYSQL_HOST" \
                                             --database-port="3306" \
                                             --database-name="$MYSQL_DATABASE" \
                                             --database-user-password="$MYSQL_PASSWORD" \
                                             --database-create=0 \
                                             --admin-user-name="$MYSQL_USER" \
                                             --admin-password="$MYSQL_PASSWORD" \
                                             --site-name="TYPO3 Importr Demo"

vendor/helhum/typo3-console/Scripts/typo3cms extension:activate semantic_eye
vendor/helhum/typo3-console/Scripts/typo3cms cache:flush
vendor/helhum/typo3-console/Scripts/typo3cms extension:setupactivate

chown -R www-data:www-data /var/www/html
apache2-foreground
