#!/bin/sh

DRUPAL_REPO_URL=git@svegit01.thestables.net:dss/nidirect-d8.git
DRUPAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.php
DRUPAL_LOCAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.local.php
NODE_YARN_INSTALLED=/etc/NODE_YARN_INSTALLED

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

# Copy example.settings.local.php for local development settings.
if ! [ -f "$DRUPAL_LOCAL_SETTINGS_FILE" ]; then
  echo "Creating settings.local.php"
  cp /app/drupal8/web/sites/example.settings.local.php $DRUPAL_LOCAL_SETTINGS_FILE
fi

# Append our lando specific config to the end of settings.php. 
if ! grep -q "D7 to D8 Migrate settings" "$DRUPAL_SETTINGS_FILE"; then
  echo "Updating settings.php"
  cat /app/config/drupal_settings >> $DRUPAL_SETTINGS_FILE
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

  # Link back to our yarn env file.
  ln -s /app/config/lando.yarn.env /app/drupal8/web/core/.env

  touch $NODE_YARN_INSTALLED
fi
