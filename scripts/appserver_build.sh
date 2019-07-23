#!/bin/sh

DRUPAL_REPO_URL=git@svegit01.thestables.net:dss/nidirect-d8.git
DRUPAL_SETTINGS_FILE=/app/drupal8/web/sites/default/settings.php
DRUPAL_SERVICES_FILE=/app/drupal8/web/sites/default/services.yml
NODE_YARN_INSTALLED=/etc/NODE_YARN_INSTALLED

# Create export directories for config and data.
if [ ! -d "/app/exports" ]; then
  echo "Creating export directories"
  mkdir -p /app/exports/config && mkdir /app/exports/data
fi

# If we don't have a Drupal 8 install, download it.
if [ ! -d "/app/drupal8" ]; then
  echo "Downloading Drupal"
  git clone $DRUPAL_REPO_URL /app/drupal8/
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

# Set local environment settings at end of settings.php file.
chmod -R +rw /app/drupal8/web/sites/default
cp -v /app/drupal8/web/sites/default/default.settings.php $DRUPAL_SETTINGS_FILE

echo "Append local environment settings to settings.php file"
cat /app/config/drupal.settings >> $DRUPAL_SETTINGS_FILE

# Copy default services config and replace key values for local development.
cp /app/config/default.services.yml $DRUPAL_SERVICES_FILE
sed -i -e "s|\(gc_maxlifetime\:\) \(200000\)|\1 86400|g" $DRUPAL_SERVICES_FILE
sed -i -e "s|\(cookie_lifetime\:\) \(2000000\)|\1 86400|g" $DRUPAL_SERVICES_FILE
sed -i -e "s|\(http.response.debug_cacheability_headers\: \)|\1 false|g" $DRUPAL_SERVICES_FILE

chmod -w /app/drupal8/web/sites/default

# Set Simple test variable and put PHPUnit config in place.
sed -i -e "s|name=\"SIMPLETEST_BASE_URL\" value=\"\"|name=\"SIMPLETEST_BASE_URL\" value=\"http:\/\/${LANDO_APP_NAME}.${LANDO_DOMAIN}\"|g" /app/config/phpunit.lando.xml
if [ -f "/app/config/phpunit.lando.xml" ]; then
  echo "Copying PHPUnit config to Drupal webroot"
  ln -sf /app/config/phpunit.lando.xml /app/drupal8/web/core/phpunit.xml
fi

# Add yarn/nodejs packages to allow functional testing on this service.
if [ ! -f "$NODE_YARN_INSTALLED" ]; then
  # Update packages and add gnupg and https for apt to fetch yarn packages.
  apt update
  apt install -y gnupg apt-transport-https
  # Add yarn deb repo.
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
  apt update
  apt install -y yarn
  # Add and fetch up to date nodejs to allow yarn to run correctly.
  curl -sL https://deb.nodesource.com/setup_10.x | bash -
  apt install -y nodejs

  # Copy Drupal .env.example file, inject Lando vars and set in place for use by Nightwatch conf.
  cat /app/drupal8/web/core/.env.example | sed -e "s|\(^DRUPAL_TEST_BASE_URL\)\(.\+\)|\1=http:\/\/${LANDO_APP_NAME}.${LANDO_DOMAIN}|g" > /app/drupal8/web/core/.env
  # Alter a few more variables.
  sed -i -e "s|\(#\)\(DRUPAL_NIGHTWATCH_SEARCH_DIRECTORY\)=|\2=../|g" /app/drupal8/web/core/.env
  sed -i -e "s|sqlite:\/\/localhost\/sites\/default\/files/db.sqlite|mysql://drupal8:drupal8@database/drupal8|g" /app/drupal8/web/core/.env
  sed -i -e "s|\(^DRUPAL_TEST_WEBDRIVER_HOSTNAME\)=localhost|\1=chromedriver|g" /app/drupal8/web/core/.env
  sed -i -e "s|^DRUPAL_TEST_CHROMEDRIVER_AUTOSTART=true|DRUPAL_TEST_CHROMEDRIVER_AUTOSTART=false|g" /app/drupal8/web/core/.env
  sed -i -e "s|\(#\)\(DRUPAL_TEST_WEBDRIVER_CHROME_ARGS\)=|\2=\"--disable-gpu --headless --no-sandbox\"|g" /app/drupal8/web/core/.env
  sed -i -e "s|\(^DRUPAL_NIGHTWATCH_OUTPUT\)=reports/nightwatch|\1=/app/exports/nightwatch-reports|g" /app/drupal8/web/core/.env

  # Fetch and install node packages if they're not already present.
  if [ ! -d "/app/drupal8/web/core/node_modules" ]; then
    cd /app/drupal8/web/core && yarn install
  fi

  # Install any known extra npm packges for, eg: migrations.
  if [ ! -d "/app/drupal8/web/modules/migrate/nidirect-migrations/migrate_nidirect_node/node_modules" ]; then
    cd /app/drupal8/web/modules/migrate/nidirect-migrations/migrate_nidirect_node
    npm install
  fi

  if [ ! -d "/app/drupal8/web/modules/custom/node_modules" ]; then
    cd /app/drupal8/web/modules/custom
    npm install
  fi

  touch $NODE_YARN_INSTALLED

  # Install drupal-check for compatibility checks.
  if ! [ -f "/usr/local/bin/drupal-check" ]; then
    curl -O -L https://github.com/mglaman/drupal-check/releases/latest/download/drupal-check.phar
    mv drupal-check.phar /usr/local/bin/drupal-check
    chmod +x /usr/local/bin/drupal-check
  fi

fi

# Add talismanrc to all known repos in this project, so we don't accidentally commit anything sensitive.
cp /app/config/talismanrc /app/.talismanrc
cp /app/config/talismanrc /app/drupal8/.talismanrc
cp /app/config/talismanrc /app/drupal8/web/modules/migrate/nidirect-migrations/.talismanrc

cat << EOF

###########################################################
⚠️         INSTALL TALISMAN FOR LOCAL DEVELOPMENT        ⚠️

You are *STRONGLY* recommend to use Talisman (by Thoughtworks) to ensure that potential secrets or sensitive information do not leave your workstation:

Talisman runs on your host OS and scans your commits against open-source detector plugins for things like auth tokens, SSH keys, credit card numbers, unusual binary files that might represent unwanted sensitive data in a repository. If it finds something, it'll reject your local commit and tell you, allowing you to fix it or tell Talisman to ignore a false-positive.

🔮 Talisman is most effective as a global pre-commit git hook but can work on pre-push events too.
🔮 You can install it per repository, but it's more fiddly to use.
🔮 You need to install it on your HOST system, not in a container or guest VM, sorry!
🔮 It's a one-off task. But you should, it could save you a very awkward conversation in future.

👉 Follow the instructions at https://github.com/thoughtworks/talisman#installation-as-a-global-hook-template
   and develop with confidence!

EOF
