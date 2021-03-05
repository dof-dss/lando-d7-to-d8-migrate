#!/bin/bash

. /helpers/log.sh

if [ ! -e /app/config/.htpasswd ]
then
    lando_yellow "Password file not found, exiting."
    lando_yellow "To create: 'sudo htpasswd -c <project-path>/config/.htpasswd <username>'"
    exit 1
fi

WEB_ROOT=/app/drupal8/web

if grep -Fxq "AuthType Basic" $WEB_ROOT/.htaccess
then
    lando_green "Basic authentication: Disabled";

    sed -i -e '/^# Apache basic authentication$/d' $WEB_ROOT/.htaccess
    sed -i -e '/^AuthType Basic$/d' $WEB_ROOT/.htaccess
    sed -i -e '/^AuthName "Restricted Content"$/d' $WEB_ROOT/.htaccess
    sed -i -e '/^AuthUserFile \/app\/config\/.htpasswd$/d' $WEB_ROOT/.htaccess
    sed -i -e '/^Require valid-user$/d' $WEB_ROOT/.htaccess
else
    lando_green "Basic authentication: Enabled";

    echo '# Apache basic authentication' >> $WEB_ROOT/.htaccess
    echo 'AuthType Basic' >> $WEB_ROOT/.htaccess
    echo 'AuthName "Restricted Content"' >> $WEB_ROOT/.htaccess
    echo 'AuthUserFile /app/config/.htpasswd' >> $WEB_ROOT/.htaccess
    echo 'Require valid-user' >> $WEB_ROOT/.htaccess
fi
