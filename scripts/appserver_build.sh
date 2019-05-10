#!/bin/sh

DRUPAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.php

if [ ! -d "/app/exports" ]; then
  echo "Creating export directories"
  mkdir -p /app/exports/config && mkdir /app/exports/data
fi

# If we don't have a Drupal 8 install, download it.
if [ ! -d "/app/drupal8" ]; then
  echo "Downloading Drupal"
  composer create-project drupal-composer/drupal-project:8.x-dev /app/drupal8 --prefer-dist --no-progress --no-interaction
  
  # Download some common migration contrib modules.
  composer require --dev -d/app/drupal8 drupal/migrate_plus drupal/migrate_tools drupal/migrate_upgrade
fi

if [ ! -d "/app/drupal8/private" ]; then
  echo "Creating private Drupal files diectory"
  mkdir -p /app/drupal8/private
fi

if test -f "$DRUPAL_SETTINGS_FILE"; then
  echo "Updating Drupal Settings File"
  cat /app/config/drupal_settings >> $DRUPAL_SETTINGS_FILE
fi
