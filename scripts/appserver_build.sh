#!/bin/sh

DRUPAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.php

if [ ! -d "/app/exports" ]; then
  echo "Creating export directories"
  mkdir -p /app/exports/config && mkdir /app/exports/data
fi

# If we don't have a Drupal 8 install, download it.
if [ ! -d "/app/drupal8" ]; then
  echo "Downloading Drupal"
  git clone git@svegit01.thestables.net:dss/nidirect-d8.git /app/drupal8/
  composer install -d/app/drupal8
  composer drupal:scaffold
fi

if [ ! -d "/app/drupal8/private" ]; then
  echo "Creating private Drupal files directory"
  mkdir -p /app/drupal8/private
fi

if test -f "$DRUPAL_SETTINGS_FILE"; then
  echo "Updating Drupal Settings File"
  cat /app/config/drupal_settings >> $DRUPAL_SETTINGS_FILE
fi
