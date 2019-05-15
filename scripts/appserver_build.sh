#!/bin/sh

DRUPAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.php
LOCAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.lando.php

if [ ! -d "/app/exports" ]; then
  echo "Creating export directories"
  mkdir -p /app/exports/config && mkdir /app/exports/data
fi

if [ ! -d "/app/drupal8/private" ]; then
  echo "Creating private Drupal files directory"
  mkdir -p /app/drupal8/private
fi

if [ ! -f "$LOCAL_SETTINGS_FILE" ]; then
  echo "Updating Drupal Settings File"

  # Heredoc to include the local lando settings file at the end of the existing settings.php file in Drupal.
cat << EOF >> ${DRUPAL_SETTINGS_FILE}

/**
 * Allow localised settings override.
 */
if (file_exists(__DIR__ . '/settings.lando.php')) {
  include __DIR__ . '/settings.lando.php';
}
EOF

  # Move our Lando settings file into place
  cp /app/config/settings.lando.php $LOCAL_SETTINGS_FILE
fi

# Kick off a Drupal installation.
drush -r /app/drupal8/web si -y standard --account-pass=admin --site-mail=admin@example.com --site-name="NI Direct D8"
