#!/bin/bash

. /helpers/log.sh

WEB_ROOT=/app/drupal8/web

if grep -Fxq "AuthType Basic" $WEB_ROOT/.htaccess
then
    lando_green "Disable basic authentication";

    sed -i -e '/^# Apache basic authentication$/d' $WEB_ROOT/.htaccess
    sed -i -e '/^AuthType Basic$/d' $WEB_ROOT/.htaccess
    sed -i -e '/^AuthName "Restricted Content"$/d' $WEB_ROOT/.htaccess
    sed -i -e '/^AuthUserFile \/app\/config\/.htpasswd$/d' $WEB_ROOT/.htaccess
    sed -i -e '/^Require valid-user$/d' $WEB_ROOT/.htaccess
else
    lando_green "Enable basic authentication";

    echo '# Apache basic authentication' >> $WEB_ROOT/.htaccess
    echo 'AuthType Basic' >> $WEB_ROOT/.htaccess
    echo 'AuthName "Restricted Content"' >> $WEB_ROOT/.htaccess
    echo 'AuthUserFile /app/config/.htpasswd' >> $WEB_ROOT/.htaccess
    echo 'Require valid-user' >> $WEB_ROOT/.htaccess
fi
