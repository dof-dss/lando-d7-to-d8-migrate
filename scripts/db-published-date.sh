#!/bin/sh
#
# Remove time from published date field data.
# TODO: Allow parameters for passing in a list of date fields for processing. 
#

# Backup current aliases, just in case.
drush sql-dump --tables-list=node__field_published_date --result-file=../../exports/data/node__field_published_date.sql
drush sqlq "UPDATE node__field_published_date SET field_published_date_value = TRIM(TRAILING 'T00:00:00' FROM field_published_date_value)"
