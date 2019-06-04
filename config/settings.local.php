<?php

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
  'username' => 'MIGRATE_SOURCE_DB_USER',
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
$config_directories[CONFIG_SYNC_DIRECTORY] = getenv('CONFIG_SYNC_DIRECTORY');

// Memcache - uncomment when required.
// $settings['cache']['default'] = 'cache.backend.memcache';
$settings['memcache']['servers'] = [sprintf('%s:%s', getenv('MEMCACHE_HOSTNAME'), getenv('MEMCACHE_PORT')) => 'default'];

// Include settings.local.php.
if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}
