<?php

// @codingStandardsIgnoreFile
$settings['file_private_path'] = getenv('FILE_PRIVATE_PATH');

$databases['default']['default'] = [
  'database'  => getenv('DB_NAME'),
  'username'  => getenv('DB_USER'),
  'password'  => getenv('DB_PASS'),
  'prefix'    => getenv('DB_PREFIX'),
  'host'      => getenv('DB_HOST'),
  'port'      => getenv('DB_PORT'),
  'namespace' => getenv('DB_NAMESPACE'),
  'driver'    => getenv('DB_DRIVER'),
];

$databases['drupal7db']['default'] = array (
  'database' => getenv('MIGRATE_SOURCE_DB_NAME'),
  'username' => getenv('MIGRATE_SOURCE_DB_USER'),
  'password' => getenv('MIGRATE_SOURCE_DB_PASS'),
  'prefix' => getenv('MIGRATE_SOURCE_DB_PREFIX'),
  'host' => getenv('MIGRATE_SOURCE_DB_HOST'),
  'port' => getenv('MIGRATE_SOURCE_DB_PORT'),
  'namespace' => getenv('MIGRATE_SOURCE_DB_NAMESPACE'),
  'driver' => getenv('MIGRATE_SOURCE_DB_DRIVER'),
);

// Prevent SqlBase from moaning.
$databases['migrate']['default'] = $databases['drupal7db']['default'];

// Custom configuration sync directory under web root.
$settings['config_sync_directory'] = getenv('CONFIG_SYNC_DIRECTORY');

// Set config split environment.
$config['config_split.config_split.local']['status'] = TRUE;
$config['config_split.config_split.development']['status'] = FALSE;
$config['config_split.config_split.production']['status'] = FALSE;

// Site hash salt.
$settings['hash_salt'] = getenv('HASH_SALT');

// Config readonly settings.
$settings['config_readonly'] = getenv('CONFIG_READONLY');

if (PHP_SAPI === 'cli') {
  // Override for drupal console/drush client.
  $settings['config_readonly'] = FALSE;
}

// Configuration that is allowed to be changed in readonly environments.
$settings['config_readonly_whitelist_patterns'] = [
  'system.site',
];

// Environment indicator config.
$settings['simple_environment_indicator'] = sprintf('%s %s', getenv('SIMPLEI_ENV_COLOUR'), getenv('SIMPLEI_ENV_NAME'));

// Geocoder API key.
$config['geolocation.settings']['google_map_api_key'] = getenv('GOOGLE_MAP_API_KEY');
