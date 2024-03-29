<?php

// @codingStandardsIgnoreFile
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

$settings['container_yamls'][] = $app_root . '/' . $site_path . '/services.development.yml';

// Set config split environment.
$config['config_split.config_split.local']['status'] = TRUE;
$config['config_split.config_split.development']['status'] = FALSE;
$config['config_split.config_split.production']['status'] = FALSE;

// Redis Cache.
// Due to issues with enabling Redis during install/config import. We cannot enable the cache backend by default.
// Once you have a site/db installed. Enable the Redis module and change the $redis_enabled to true.
$redis_enabled = FALSE;
if ($redis_enabled && !\Drupal\Core\Installer\InstallerKernel::installationAttempted() && extension_loaded('redis') && class_exists('Drupal\redis\ClientFactory')){
    $settings['redis.connection']['interface'] = 'PhpRedis';
    $settings['redis.connection']['host'] = getenv('REDIS_HOSTNAME');
    $settings['redis.connection']['port'] = getenv('REDIS_PORT');
    $settings['cache']['default'] = 'cache.backend.redis';
    $settings['container_yamls'][] = $app_root . '/' . $site_path . '/redis.services.yml';

    // Manually add the classloader path, this is required for the container cache bin definition below
    // and allows to use it without the redis module being enabled.
    $class_loader->addPsr4('Drupal\\redis\\', $app_root . '/' . $site_path . '/modules/contrib/redis/src');

    // Use redis for container cache.
    // The container cache is used to load the container definition itself, and
    // thus any configuration stored in the container itself is not available
    // yet. These lines force the container cache to use Redis rather than the
    // default SQL cache.
    $settings['bootstrap_container_definition'] = [
        'parameters' => [],
        'services' => [
            'redis.factory' => [
                'class' => 'Drupal\redis\ClientFactory',
            ],
            'cache.backend.redis' => [
                'class' => 'Drupal\redis\Cache\CacheBackendFactory',
                'arguments' => ['@redis.factory', '@cache_tags_provider.container', '@serialization.phpserialize'],
            ],
            'cache.container' => [
                'class' => '\Drupal\redis\Cache\PhpRedis',
                'factory' => ['@cache.backend.redis', 'get'],
                'arguments' => ['container'],
            ],
            'cache_tags_provider.container' => [
                'class' => 'Drupal\redis\Cache\RedisCacheTagsChecksum',
                'arguments' => ['@redis.factory'],
            ],
            'serialization.phpserialize' => [
                'class' => 'Drupal\Component\Serialization\PhpSerialize',
            ],
        ],
    ];
}

