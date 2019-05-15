<?php

/**
 * -:: D7 to D8 Migrate settings ::-.
 *
 * These are picked up from settings.php.
 */

$settings['file_private_path'] = '../private';

$databases['default']['default'] = [
  'database' => 'drupal8',
  'username' => 'drupal8',
  'password' => 'drupal8',
  'prefix' => '',
  'host' => 'database',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
];

$databases['drupal7db']['default'] = [
  'database' => 'drupal7',
  'username' => 'drupal7',
  'password' => 'drupal7',
  'prefix' => '',
  'host' => 'drupal7db',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
];

// Default/legacy db for any migrate plugins that don't pick up the drupal7db entry.
$databases['migrate']['default'] = $databases['drupal7db']['default'];
