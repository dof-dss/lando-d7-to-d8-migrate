#!/bin/sh
set -x

PRIVATE_FILES_PATH='/app/private'
LOCAL_SETTINGS='/app/drupal8/web/sites/default/settings.local.php'

if [ ! -d "$PRIVATE_FILES_PATH" ]; then
  mkdir $PRIVATE_FILES_PATH
fi

if [ ! -f "$LOCAL_SETTINGS" ]; then
  # Append the private files and legacy database connection to settings.php
  echo "<?php\n" > $LOCAL_SETTINGS
  cat /app/config/drupal_settings >> $LOCAL_SETTINGS
fi

# Composer file sits under the D8 root??
cd /app/drupal8
# Add common migrate contrib modules
composer require --dev drupal/migrate_plus drupal/migrate_tools drupal/migrate_upgrade

# Fix Column 'title' cannot be null issues.
drush sql:query --database=drupal7db "UPDATE node SET node.title = '<none>' WHERE title = '' or title IS NULL; UPDATE node_revision SET title = '<none>' WHERE title = '' or title IS NULL;"

# Fix issue with zero status redirect imports to Drupal 8 (Cred to Jaime Contreras)
drush sql:query --database=drupal7db "UPDATE redirect SET status_code=301 WHERE status_code=0;UPDATE redirect SET status_code=301 WHERE status_code IS NULL;"

drush en -y migrate migrate_plus miigrate_tools migrate_upgrade
