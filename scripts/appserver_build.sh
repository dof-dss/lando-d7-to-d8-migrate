#!/bin/sh

DRUPAL_REPO_URL=git@svegit01.thestables.net:dss/nidirect-d8.git
DRUPAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.php
DRUPAL_LOCAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.local.php
NODE_YARN_INSTALLED=/etc/NODE_YARN_INSTALLED
DRUPAL_LOCAL_CONF=/etc/DRUPAL_LOCAL_CONF

# Create export directories for config and data.
if [ ! -d "/app/exports" ]; then
  echo "Creating export directories"
  mkdir -p /app/exports/config && mkdir /app/exports/data
fi

# If we don't have a Drupal 8 install, download it.
if [ ! -d "/app/drupal8" ]; then
  echo "Downloading Drupal"
  git clone $DRUPAL_REPO_URL /app/drupal8/
  composer -d/app/drupal8 install
  echo "Building Drupal files"
  composer -d/app/drupal8 drupal:scaffold
  composer -d/app/drupal8 run-script post-install-cmd
fi

# Create Drupal private file directory above web root.
if [ ! -d "/app/drupal8/private" ]; then
  echo "Creating private Drupal files directory"
  mkdir -p /app/drupal8/private
fi

# Copy settings.local.php for local development settings.
if ! [ -f "$DRUPAL_LOCAL_CONF" ]; then
  chmod -R +rw /app/drupal8/web/sites/default
  cp -v /app/drupal8/web/sites/default/default.settings.php /app/drupal8/web/sites/default/settings.php

  echo "Creating settings.local.php"
  cp -v /app/config/settings.local.php $DRUPAL_LOCAL_SETTINGS_FILE

  echo "Including settings.local.php at end of settings.php"
  cat << EOF >> $DRUPAL_SETTINGS_FILE
if (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {
  include \$app_root . '/' . \$site_path . '/settings.local.php';
}
EOF
  chmod -w /app/drupal8/web/sites/default

  # Set a marker to say we're done.
  touch $DRUPAL_LOCAL_CONF
fi

# Put PHPUnit config in place.
if [ -f "/app/config/phpunit.lando.xml" ]; then
  echo "Copying PHPUnit config to Drupal webroot"
  ln -sf /app/config/phpunit.lando.xml /app/drupal8/web/core/phpunit.xml
fi

# Add yarn/nodejs packages to allow functional testing on this service.
if [ ! -f "$NODE_YARN_INSTALLED" ]; then
  # Update packages and add gnupg and https for apt to fetch yarn packages.
  apt update
  apt install -y gnupg apt-transport-https
  # Add yarn deb repo.
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
  apt update
  apt install -y yarn
  # Add and fetch up to date nodejs to allow yarn to run correctly.
  curl -sL https://deb.nodesource.com/setup_10.x | bash -
  apt install -y nodejs

  # Copy Drupal .env.example file, inject Lando vars and set in place for use by Nightwatch conf.
  cat /app/drupal8/web/core/.env.example | sed -e "s|\(^DRUPAL_TEST_BASE_URL\)\(.\+\)|\1=http:\/\/${LANDO_APP_NAME}.${LANDO_DOMAIN}|g" > /app/drupal8/web/core/.env
  # Alter a few more variables.
  sed -i -e "s|\(#\)\(DRUPAL_NIGHTWATCH_SEARCH_DIRECTORY\)=|\2=../|g" /app/drupal8/web/core/.env
  sed -i -e "s|sqlite:\/\/localhost\/sites\/default\/files/db.sqlite|mysql://drupal8:drupal8@database/drupal8|g" /app/drupal8/web/core/.env
  sed -i -e "s|\(^DRUPAL_TEST_WEBDRIVER_HOSTNAME\)=localhost|\1=chromedriver|g" /app/drupal8/web/core/.env
  sed -i -e "s|^DRUPAL_TEST_CHROMEDRIVER_AUTOSTART=true|DRUPAL_TEST_CHROMEDRIVER_AUTOSTART=false|g" /app/drupal8/web/core/.env
  sed -i -e "s|\(#\)\(DRUPAL_TEST_WEBDRIVER_CHROME_ARGS\)=|\2=\"--disable-gpu --headless --no-sandbox\"|g" /app/drupal8/web/core/.env
  sed -i -e "s|\(^DRUPAL_NIGHTWATCH_OUTPUT\)=reports/nightwatch|\1=/app/exports/nightwatch-reports|g" /app/drupal8/web/core/.env

  # Fetch and install node packages if they're not already present.
  if [ ! -d "/app/drupal8/web/core/node_modules" ]; then
    cd /app/drupal8/web/core && yarn install
  fi

  touch $NODE_YARN_INSTALLED
fi
