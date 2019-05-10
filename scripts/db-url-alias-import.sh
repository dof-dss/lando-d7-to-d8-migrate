#!/bin/sh
#
# Exports and imports D7 url_aliases table into D8.
#
# Backup current aliases, just in case.
drush sql-dump --tables-list=url_alias --result-file=/app/exports/data/urlaliases_backup.sql
# Export D7 url aliases.
drush sql-dump --database=drupal7db --tables-list=url_alias --result-file=/app/exports/data/drupal7_urlaliases.sql
# Import D7 url aliases.
drush sqlq --file=/app/exports/data/drupal7_urlaliases.sql
# Rename imported table column to D8 schema.
drush sqlq "ALTER TABLE url_alias CHANGE language langcode varchar(12);"
# Prepend imported source and alias columns with forward slash.
drush sqlq "UPDATE url_alias SET url_alias.source = concat("/",url_alias.source), url_alias.alias = concat("/",url_alias.alias);"
rm -f /app/exports/data/drupal7_urlaliases.sql

