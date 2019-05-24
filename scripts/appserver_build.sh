#!/bin/sh

DRUPAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.php
DRUPAL_LOCAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.local.php

if [ ! -d "/app/exports" ]; then
  echo "Creating export directories"
  mkdir -p /app/exports/config && mkdir /app/exports/data
fi

# If we don't have a Drupal 8 install, download it.
if [ ! -d "/app/drupal8" ]; then
  echo "Downloading Drupal"
  git clone git@svegit01.thestables.net:dss/nidirect-d8.git /app/drupal8/
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
if ! [ -f "/app/drupal8/web/sites/default/settings.local.php" ]; then
  echo "Creating settings.local.php"
  cp /app/drupal8/web/sites/example.settings.local.php /app/drupal8/web/sites/default/settings.local.php
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
