#!/bin/sh

PRIVATE_FILES_PATH = 'app/private'

if [ ! -d "$PRIVATE_FILES_PATH" ]; then
  mkdir PRIVATE_FILES_PATH
fi

// Append the private files and legacy database connection to settings.php
cat config/drupal_settings >> app/web/sites/default/settings.php

// Add common migrate contrib modules
cd app && composer require --dev drupal/migrate_plus drupal/migrate_tools drupal/migrate_upgrade

// Fix Column 'title' cannot be null issues.
drush sqlq --database=drupal7db "UPDATE node SET node.title = '<none>' WHERE title = '' or title IS NULL; UPDATE node SET node_revision.title = '<none>' WHERE title = '' or title IS NULL;"

// Fix issue with zero status redirect imports to Drupal 8 (Cred to Jaime Contreras)
drush sqlq --database=drupal7db "UPDATE redirect SET status_code=301 WHERE status_code=0;UPDATE redirect SET status_code=301 WHERE status_code IS NULL;"
