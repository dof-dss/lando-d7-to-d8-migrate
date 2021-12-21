## IMPORTANT

To enable Redis cache you will first need a completed install of the site. Enable the Redis module and update /sites/default/settings.php file to set $redis_enabled to true.

The recent update to Drupal Core composer scaffolding scripts can cause a Runtime Exception that the default.services.yml could not be deleted. To fix this in Lando:

1. cd /mysite/drupal8/web/sites
2. chmod u+w default
 

## Getting started
Ensure you have the following installed:

 1. Docker CE [https://docs.docker.com/install/](https://docs.docker.com/install/)
 2. Lando [https://docs.devwithlando.io/](https://docs.devwithlando.io/)
 3. Composer [https://getcomposer.org/](https://getcomposer.org/)

Now we can download Drupal 8 and import our Drupal 7 assets.

 1. Make a copy of .lando.example.yml naming it .lando.local.yml and edit with your own unique project name.
 2. Create config/.env with any local changes you require: `cp config/.env.sample config/.env`. 
	As a minimum you'll need to set the 'HASH_SALT' to a random string and set CONFIG_SYNC_DIRECTORY to '../config/sync'
 3. Run *'lando start'*
 4. From the /drupal directory run 'lando composer install'
 5. Open your lando site url (displayed at the end of 'lando start', or use *'lando info'*)
 6. Proceed with the Drupal 9 installation.
 7. On the 'Select an installation profile', check 'Standard' and continue.
 8. Once Drupal has successfully installed you may want to download a database dump from Platform.sh and
	use 'lando db-import <filename>' to load it into Drupal
 9. Read the following tips to ensure you are using the right development and configuration settings.

If you wish to run migrations:

 1. Copy your Drupal 7 database dump to ./imports/data and site files to ./imports/files (Note that you should copy the 'sites' directory into here, so that the path './imports/files/sites/default/files/articles' exists)
 2. Run *'lando db-import -h drupal7db ./imports/data/[SQL DUMP FILENAME].sql'*

 ## Tips
 - In your .env file update the CONFIG_SYNC_DIRECTORY to point to the correct path in Lando (e.g. CONFIG_SYNC_DIRECTORY=../config/sync)
 - To get a hash_salt for your .env file run `platform drush -p <project> -e <environment> php-eval 'echo \Drupal\Core\Site\Settings::getHashSalt();'`
 - If configuration import is taking a long time (> 60 mins) stop the install, clean the database and reboot your machine. 
 - Edit settings.local.php file to toggle development settings.
 - Edit settings.php and uncomment the *'config split environment'* settings, checking the appropriate boolean assignment is set.
 - Use the 'lando drush/drupal csex' command to import configuration splits.
 - After installing the site, within .lando.local.yml, consider enabling the TurboMode option to improve performance. See the comments in lando.local.yml for more details.

## File structure

 - **.lando.yml** - Lando recipe file.
 - **config** - Container settings (php.ini etc).
 - **drupal8** - Drupal 8 source folder.
 - **exports** - Drupal 8 exports.
	 - **config** - Configuration manager exports.
	 - **data** - Database dumps.
 - **imports** - Drupal 7 imports
	 - **data** - Database dumps (to import to drupal7db container).
	 - **files** - `/sites/default/files` from Drupal 7 (Note that you should copy the 'sites' directory into here, so that the path `./imports/files/sites/default/files/articles` exists)
 - **scripts** - Utilities, site and DB scripts.

## Migration tools
Run the following utils using: `lando [command]`

 - **mi-init** - Migration init: Runs common migrate clean/setup scripts.
 - **mist** - Migrate status: Alias of *'drush migrate-status'*
 - **miup** - Migrate upgrade: Exports Drupal 8 database to /exports/data and runs *'drush migrate-upgrade'*
 - **miip** - Migrate import: Alias of *'drush migrate-import'*
 - **mirs** - Migrate reset status: Alias of *'drush migrate-reset-status'*

### FAQ

Q: Can this be installed and run as a Lando task?\
A: Unfortunately not, as that would require you to run git within the container which isn't ideal or convenient. It's super easy to install
, only needs to be done once and Talisman auto-updates too.

Q: It won't let me commit my composer.lock file because it contains suspicious base64 encoded strings. How do I work around that?\
A: Talisman is technology agnostic; you see the same issues with Go and node.js projects. You have two choices here:

1. Carefully review the changes, then override the pre-commit hook: `git commit -m "Your message" -n`
2. Carefully manage the ignore stanzas of `.talismanrc` files per repo, ensuring that the checksums are updated each time the corresponding files are changed.

Option 2 is significantly more secure, but also significantly more inconvenient. Teams will need to decide and agree which approach to take on a case-by-case basis.

https://github.com/thoughtworks/talisman/issues/122 shows efforts to introduce permanent ignore scope for specific files, which may offer a helpful middle ground.
