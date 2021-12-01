#!/usr/bin/env bash

# Variables to indicate key settings files or directories for Drupal.
DRUPAL_REPO_URL=git@github.com:dof-dss/nidirect-drupal.git

DRUPAL_ROOT=/app/drupal/web
DRUPAL_SETTINGS_FILE=$DRUPAL_ROOT/sites/default/settings.php
DRUPAL_SERVICES_FILE=$DRUPAL_ROOT/sites/default/services.yml
DRUPAL_CUSTOM_CODE=$DRUPAL_ROOT/modules/custom
DRUPAL_MIGRATE_CODE=$DRUPAL_ROOT/modules/migrate/nidirect-migrations
DRUPAL_TEST_PROFILE=$DRUPAL_ROOT/profiles/custom/test_profile

# Semaphore files to control whether we need to trigger an install
# of supporting software or config files.
NODE_YARN_INSTALLED=/etc/NODE_YARN_INSTALLED
CKEDITOR_PATCHED=/etc/CKEDITOR_PATCHED

# Update APT cache and install Vim.
apt update
apt install -y vim

# Create export directories for config and data.
if [ ! -d "/app/exports" ]; then
  echo "Creating export directories"
  mkdir -p /app/exports/config && mkdir /app/exports/data
fi

# If we don't have a Drupal install, download it.
if [ ! -d "/app/drupal" ]; then
  echo "Downloading Drupal"
  git clone $DRUPAL_REPO_URL /app/drupal/
  echo "Installing Drupal"
  composer -d/app/drupal install
fi

# Create Drupal public files directory and set IO permissions.
if [ ! -d "/app/drupal/web/sites/default/files" ]; then
  echo "Creating public Drupal files directory"
  mkdir -p /app/drupal/web/sites/default/files
  chmod -R 0777 /app/drupal/web/sites/default/files
fi

# Create Drupal private file directory above web root.
if [ ! -d "/app/drupal/private" ]; then
  echo "Creating private Drupal files directory"
  mkdir -p /app/drupal/private
fi

# Set local environment settings.php file.
echo "Creating settings.local.php file using our Lando copy"
chmod +w $DRUPAL_ROOT/sites/default

cp -v /app/config/drupal.settings.php $DRUPAL_ROOT/sites/default/settings.local.php

echo "Updating config sync to enable install profile"
# Playing it safe here and matching only the exact strings vs matches against 'standard'.
sed -i 's/standard: 1000/minimal: 1000/g' /app/drupal/config/sync/core.extension.yml
sed -i 's/profile: standard/profile: minimal/g' /app/drupal/config/sync/core.extension.yml

# Copy default services config and replace key values for local development.
cp -v /app/config/drupal.services.yml $DRUPAL_SERVICES_FILE

echo "Copying Redis service overrides"
cp -v /app/config/redis.services.yml $DRUPAL_ROOT/sites/default/redis.services.yml

# Close off write access to the folder.
chmod -w $DRUPAL_ROOT/sites/default

# Set Simple test variables and put PHPUnit config in place.
if [ ! -f "${DRUPAL_ROOT}/core/phpunit.xml" ]; then
  echo "Adding localised PHPUnit config to Drupal webroot"
  cp $DRUPAL_ROOT/core/phpunit.xml.dist $DRUPAL_ROOT/core/phpunit.xml
  # Fix bootstrap path
  sed -i -e "s|bootstrap=\"tests/bootstrap.php\"|bootstrap=\"${DRUPAL_ROOT}/core/tests/bootstrap.php\"|g" $DRUPAL_ROOT/core/phpunit.xml
  # Inject database params for kernel tests.
  sed -i -e "s|name=\"SIMPLETEST_DB\" value=\"\"|name=\"SIMPLETEST_DB\" value=\"${DB_DRIVER}://${DB_USER}:${DB_PASS}@${DB_HOST}/${DB_NAME}\"|g" $DRUPAL_ROOT/core/phpunit.xml
  # Uncomment option to switch off Symfony deprecatons helper (we use drupal-check for this).
  sed -i -e "s|<!-- <env name=\"SYMFONY_DEPRECATIONS_HELPER\" value=\"disabled\"/> -->|<env name=\"SYMFONY_DEPRECATIONS_HELPER\" value=\"disabled\"/>|g" $DRUPAL_ROOT/core/phpunit.xml
  # Set the base URL for kernel tests.
  sed -i -e "s|name=\"SIMPLETEST_BASE_URL\" value=\"\"|name=\"SIMPLETEST_BASE_URL\" value=\"http:\/\/${LANDO_APP_NAME}.${LANDO_DOMAIN}\"|g" $DRUPAL_ROOT/core/phpunit.xml
fi

# Add yarn/nodejs packages to allow functional testing on this service.
if [ ! -f "$NODE_YARN_INSTALLED" ]; then
  # Update packages and add gnupg and https for apt to fetch yarn packages.
  apt install -y gnupg apt-transport-https
  # Add yarn deb repo.
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
  apt update
  apt install -y yarn
  # Add and fetch up to date nodejs to allow yarn to run correctly.
  curl -sL https://deb.nodesource.com/setup_16.x | bash -
  apt install -y nodejs

  # Copy Drupal .env.example file, inject Lando vars and set in place for use by Nightwatch conf.
  cat $DRUPAL_ROOT/core/.env.example | sed -e "s|\(^DRUPAL_TEST_BASE_URL\)\(.\+\)|\1=http:\/\/${LANDO_APP_NAME}.${LANDO_DOMAIN}|g" > $DRUPAL_ROOT/core/.env
  # Alter a few more variables.
  sed -i -e "s|\(#\)\(DRUPAL_NIGHTWATCH_SEARCH_DIRECTORY\)=|\2=../|g" $DRUPAL_ROOT/core/.env
  sed -i -e "s|sqlite:\/\/localhost\/sites\/default\/files/db.sqlite|${DB_DRIVER}://${DB_USER}:${DB_PASS}@${DB_HOST}/${DB_NAME}|g" $DRUPAL_ROOT/core/.env
  sed -i -e "s|\(^DRUPAL_TEST_WEBDRIVER_HOSTNAME\)=localhost|\1=chromedriver|g" $DRUPAL_ROOT/core/.env
  sed -i -e "s|^DRUPAL_TEST_CHROMEDRIVER_AUTOSTART=true|DRUPAL_TEST_CHROMEDRIVER_AUTOSTART=false|g" $DRUPAL_ROOT/core/.env
  sed -i -e "s|\(#\)\(DRUPAL_TEST_WEBDRIVER_CHROME_ARGS\)=|\2=\"--disable-gpu --headless --no-sandbox\"|g" $DRUPAL_ROOT/core/.env
  sed -i -e "s|\(^DRUPAL_NIGHTWATCH_OUTPUT\)=reports/nightwatch|\1=/app/exports/nightwatch-reports|g" $DRUPAL_ROOT/core/.env

  # Fetch and install node packages if they're not already present.
  if [ ! -d "${DRUPAL_ROOT}/core/node_modules" ]; then
    cd $DRUPAL_ROOT/core && yarn install
  fi

  # Install any known extra npm packges for, eg: migrations.
  if [ ! -d "${DRUPAL_MIGRATE_CODE}/migrate_nidirect_node/node_modules" ]; then
    cd $DRUPAL_MIGRATE_CODE/migrate_nidirect_node
    npm install
  fi

  if [ ! -d "${DRUPAL_CUSTOM_CODE}/node_modules" ]; then
    cd $DRUPAL_CUSTOM_CODE
    npm install
  fi

  touch $NODE_YARN_INSTALLED

fi

if [ ! -f "$CKEDITOR_PATCHED" ]; then
  # Replace vanilla CKEditor config with a custom one to fix the click/drag bug with embedded entities.
  echo "Replace vanilla CKEditor config with a custom one to fix the click/drag bug with embedded entities"
  git clone https://github.com/dof-dss/ckeditor4-fix-widget-dnd.git /tmp/ckeditor4-fix-widget-dnd
  rm -rf $DRUPAL_ROOT/core/assets/vendor/ckeditor
  mv -v /tmp/ckeditor4-fix-widget-dnd/build/ckeditor $DRUPAL_ROOT/core/assets/vendor/ckeditor
  rm -rf /tmp/ckeditor4-fix-widget-dnd

  touch $CKEDITOR_PATCHED
fi