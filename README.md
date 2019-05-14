## Getting started
Ensure you have the following installed:

 1. Docker CE [https://docs.docker.com/install/](https://docs.docker.com/install/)
 2. Lando [https://docs.devwithlando.io/](https://docs.devwithlando.io/)
 3. Composer [https://getcomposer.org/](https://getcomposer.org/)

Now we can download Drupal 8 and import our Drupal 7 assets.

 1. Copy your Drupal 7 database dump to ./imports/data and site files to ./imports/files (Note that you should copy the 'sites' directory into here, so that the path './imports/files/sites/default/files/articles' exists)
 2. Run *'lando start'*
 3. Run *'lando db-import -h drupal7db ./imports/data/[SQL DUMP FILENAME].sql'*
 4. Open your lando site url (displayed at the end of 'lando start', or use *'lando info'*)
 5. Proceed with the Drupal 8 installation.  

## File structure

 - **.lando.yml** - Lando recipe file.
 - **config** - Container settings (php.ini etc).
 - **drupal8** - Drupal 8 source folder.
 - **exports** - Drupal 8 exports.
	 - **config** - Configuration manager exports. 
	 - **data** - Database dumps.
 - **imports** - Drupal 7 imports
	 - **data** - Database dumps (to import to drupal7db container).
	 - **files** - /sites/default/files from Drupal 7 (Note that you should copy the 'sites' directory into here, so that the path './imports/files/sites/default/files/articles' exists)
 - **scripts** - Utilities, site and DB scripts.

## Migration tools
Run the following utils using: *lando [command]*

 - **mi-init** - Migration init: Runs common migrate clean/setup scripts.
 - **mist** - Migrate status: Alias of *'drush migrate-status'* 
 - **miup** - Migrate upgrade: Exports Drupal 8 database to /exports/data and runs *'drush migrate-upgrade'*
 - **miip** - Migrate import: Alias of *'drush migrate-import'*  
 - **mirs** - Migrate reset status: Alias of *'drush migrate-reset-status'*
