#!/bin/sh

# Collection of migration init and cleanup scripts.

// Fix Column 'title' cannot be null issues.
drush sqlq -r /app/drupal8/web --database=drupal7db "UPDATE node SET node.title = '<none>' WHERE title = '' or title IS NULL; UPDATE node SET node_revision.title = '<none>' WHERE title = '' or title IS NULL;"

// Fix issue with zero status redirect imports to Drupal 8 (Cred to Jaime Contreras)
drush sqlq -r /app/drupal8/web --database=drupal7db "UPDATE redirect SET status_code=301 WHERE status_code=0;UPDATE redirect SET status_code=301 WHERE status_code IS NULL;"
