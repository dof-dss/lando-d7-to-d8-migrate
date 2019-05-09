## Getting started
Ensure you have the following installed:

 1. Docker CE [https://docs.docker.com/install/](https://docs.docker.com/install/)
 2. Lando [https://docs.devwithlando.io/](https://docs.devwithlando.io/)
 3. Composer [https://getcomposer.org/](https://getcomposer.org/)
 4. Drupal Console [https://drupalconsole.com/](https://drupalconsole.com/)

Now we can download Drupal 8 and import our Drupal 7 assets.

 1. Run *'drupal site:new'*
 2. Select the repository (usually *[1] drupal-composer/drupal-project*)
 3. Enter  *'drupal8'* as the "directory" placeholder.
 4. Copy your Drupal 7 database dump to `./imports/data`
 5. Copy your Drupal 7 sites/default/files to `./imports/files`
 6. Run *'lando start'*
 7. Run *'lando db-import -h drupal7db ./imports/data/[SQL DUMP FILENAME].sql'*
 8. Run *'lando mi-init'*
 9. Open your lando site url (displayed during step 6, or use *'lando info'*)
 10. Proceed with the Drupal 8 installation.  

## File structure

 - **.lando.yml** - Lando recipe file.
 - **config** - Container settings (php.ini etc), database cleanup scripts etc.
 - **drupal8** - Drupal 8 source folder.
 - **exports** - Drupal 8 exports.
	 - **config** - Configuration manager exports. 
	 - **data** - Database dumps.
 - **imports** - Drupal 7 imports
	 - **data** - Database dumps (to import to drupal7db container).
	 - **files** - /sites/default/files from Drupal 7. 
 - **scripts** - Utilities, site and DB scripts.

## Migration tools
Run the following utils using: *lando [command]*

 - **mi-init** - Migration init:  (Run after Drupal 8 project files are in place but the site is not installed and Drupal 7 database has been imported).
 - **mist** - Migrate status: Alias of *'drush migrate-status'* 
 - **miup** - Migrate upgrade: Exports Drupal 8 database to /exports/data and runs *'drush migrate-upgrade'*
 - **miip** - Migrate import: Alias of *'drush migrate-import'*  
 - **mirs** - Migrate reset status: Alias of *'drush migrate-reset-status'*
