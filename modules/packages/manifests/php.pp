class packages::php {
  include php::fpm::daemon
  include php::cli

  $default = [
    'gd', 'ldap', 'mcrypt', 'memcache', 'pgsql'
  ]

  case $operatingsystem {
    'Centos': {
      $phpexts = [$default, 'mbstring', 'mysql', 'opcache', 'pdo', 'xml']
    }
    'Fedora': {
      $phpexts = [$default, 'mbstring', 'mysqlnd', 'opcache', 'pdo', 'xml']
    }
    default: {
      $phpexts = [$default, 'mysql']
    }
  }

  php::module { $phpexts: }

#  php::module::ini { 'opcache':
#    zend     => true,
#    settings => {
#      'opcache.enable'                  => '1',
#      'opcache.interned_strings_buffer' => '16',
#      'opcache.memory_consumption'      => '128',
#      'opcache.max_accelerated_files'   => '6000',
#      'opcache.fast_shutdown'           => '1',
#      'opcache.revalidate_freq'         => '15',
#      'opcache.blacklist_filename'      => '/etc/php.d/opcache*.blacklist',
      # @TODO disable this for Drupal 8
#      'opcache.save_comments'           => '0',
#      'opcache.load_comments'           => '0',
#      'opcache.enable_file_override'    => '1',
#    }
#  }

  php::ini { '/etc/php.ini':
    memory_limit        => '196M',
    upload_max_filesize => '256M',
    post_max_size       => '256M',
    session_save_path   => '/var/lib/php/session',
  }

  case $operatingsystem {
    centos: { $apache = "apache" }
    redhat: { $apache = "apache" }
    debian: { $apache = "www-data" }
    ubuntu: { $apache = "www-data" }
  }

  php::fpm::conf { 'www': ensure => 'absent' }
  php::fpm::conf { 'drupal':
    listen                    => '/var/run/drupal-php-fpm.sock',
    user                      => $apache,
    listen_owner              => $apache,
    listen_group              => $apache,
    pm_max_children           => '3',
    pm_start_servers          => '1',
    pm_min_spare_servers      => '1',
    pm_max_spare_servers      => '1',
    pm_max_requests           => '5',
    ping_path                 => '/MONITOR',
    require => [ Package['httpd'] ],
  }
# @TODO need webtatic repo for redhat

}
