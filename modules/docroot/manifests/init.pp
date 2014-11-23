class docroot {

  file { '/var/www':
    ensure => 'directory',
  }

  file { '/var/www/html':
    ensure => 'directory',
    require => File['/var/www'],
  }

  file { '/var/www/fpm':
    ensure  => 'directory',
    require => File['/var/www'],
  }

  class {'apache':
    default_mods        => false,
    default_confd_files => false,
    default_vhost       => false,
    mpm_module          => worker,
  }

  apache::listen { '80': }

  include apache::mod::mime
  include apache::mod::dir
  case $::operatingsystem {
    'Fedora': {
      include apache::mod::fcgid
      apache::mod { 'proxy_fcgi': }
      apache::mod { 'access_compat': }

      # Hax to load unixd before any other mods.
      file {'/etc/httpd/conf.d/aunixd.load':
        ensure => 'link',
        target => '/etc/httpd/conf.d/unixd.load',
      }
    }
    'Ubuntu': {
      include apache::mod::fastcgi
      if $::operatingsystemmajrelease > 13.09 {
        apache::mod { 'access_compat': }
      }
      else {
        apache::mod { 'authz_default': }
      }
    }
    default: {
      include apache::mod::fastcgi
      apache::mod { 'authz_default': }
    }
  }

  include apache::mod::rewrite
  include apache::mod::proxy
  include apache::mod::actions
  include apache::mod::auth_basic
  include apache::mod::setenvif

  apache::mod { 'authn_file': }
  apache::mod { 'authz_user': }

  case $::osfamily {
    'debian': {
      $apache              = 'www-data'
      $fpm                 = 'php5-fpm'
    }
    'redhat': {
      $apache              = 'apache'
      $fpm                 = 'php-fpm'
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }

  file { '/var/www/fpm/drupal':
    ensure => 'link',
    target => "/usr/sbin/${fpm}",
  }
  file { '/var/www/fpm/drupal-ssl':
    ensure => 'link',
    target => "/usr/sbin/${fpm}",
  }

  apache::vhost { 'drupal':
    docroot     => '/var/www/html/drupal',
    docroot_owner => $apache,
    docroot_group => 'drupal',
    port => 80,
    fastcgi_server => '/var/www/fpm/drupal -pass-header Authorization -idle-timeout 600',
    fastcgi_socket => '/var/run/drupal-php-fpm.sock',
    fastcgi_dir => '/var/www/fpm/drupal',
    action => 'php-fastcgi',
    scriptalias => '/var/www/fpm/drupal',
    directories => [ {
      directoryindex => 'index.php',
      addhandlers => [ { handler => 'php-fastcgi', extensions => ['.php']} ],
      path => '/var/www/html/drupal',
      allow_override => ['All'],
      options => ['FollowSymLinks','ExecCGI'],
    } ],
    require => File['/var/www/fpm/drupal'],
  }

#  exec { 'self signed cert drupal @TODO':
#    command => '/usr/bin/openssl req -new -nodes -x509 -subj "/C=AU/ST=ACT/L=Canberra/O=1337/CN=seed.glo5.com" -days 3650 -keyout /etc/ssl/certs/seed.glo5.com.key -out /etc/ssl/certs/seed.glo5.com.cert',
#    creates => ['/etc/ssl/certs/seed.glo5.com.cert', '/etc/ssl/certs/seed.glo5.com.key'],
#    user => 'root',
#  }

#  apache::vhost { 'drupal_ssl':
#    docroot     => '/var/www/html/',
#    docroot_owner => 'seedbox',
#    docroot_group => 'apache',
#    port => 443,
#    ssl => true,
#    ssl_cert => '/etc/ssl/certs/seed.glo5.com.cert',
#    ssl_key  => '/etc/ssl/certs/seed.glo5.com.key',
#    fastcgi_server => '/var/www/fpm/seedbox-ssl -pass-header Authorization -idle-timeout 600',
#    fastcgi_socket => '/var/run/seedbox-php-fpm.sock',
#    fastcgi_dir => '/var/www/fpm/seedbox-ssl',
#    action => 'php-fastcgi',
#    scriptalias => '/var/www/fpm/seedbox-ssl',
#    directories => [ {
#      directoryindex => 'index.php',
#      addhandlers => [ { handler => 'php-fastcgi', extensions => ['.php']} ],
#      path => '/var/www/html/seedbox',
#      allow_override => ['All'],
#      options => ['FollowSymLinks','ExecCGI'],
##    } ],
#    require => [ File['/var/www/fpm/seedbox-ssl'], Exec['self signed cert seed.glo5.com'] ]
#  }

#file { '/etc/init.d/mysqld':
#   ensure => 'link',
#   target => '/etc/init.d/mysql',
#}
 
#class { 'mysql': 
#  require 	=> [ Yumrepo["Percona"], File['/etc/init.d/mysqld'] ],
#  package_name => 'Percona-Server-client-55',
#  package_ensure => latest,
#}
 
#class { 'mysql::server': 
#  require 	=> [ Yumrepo["Percona"], File['/etc/init.d/mysqld'] ],
#  package_name => 'Percona-Server-server-55',
#  package_ensure => latest,
#  service_name => 'mysql',
#  config_hash => {
#    'pidfile'     => '/var/lib/mysql/localhost.localdomain.pid',
#    'bind_address' => '0.0.0.0',
#  },

  exec {'rsync drupal to docroot':
    path    => '/usr/bin',
    command => "rsync -avPh --exclude='.git' /var/www/repo/drupal/ /var/www/html/drupal/",
    creates => '/var/www/html/drupal/index.php',
  }

  file {'/var/www/html/drupal/sites/default/files':
    ensure  => directory,
    require => Exec['rsync drupal to docroot'],
    owner   => 'drupal',
    group   => 'drupal',
    mode    => 0750,
  }

#  file {'/var/www/html/drupal/sites/default/settings.php':
#    ensure   => present,
#    replace  => false,
#    content  => template('docroot/settings-php.erb'),
#    require => Exec['rsync drupal to docroot'],
#  }

  # Set all the permissions
  $permissions = [
    'find /var/www/html/drupal/ -type d -not -path "/var/www/html/drupal/sites/default/files" -exec chown www-data:drupal {} \; -exec chmod 550 {} \;',
    'find /var/www/html/drupal/ -type f -not -path "/var/www/html/drupal/sites/default/files" -exec chown www-data:drupal {} \; -exec chmod 440 {} \;',
    'find /var/www/html/drupal/sites/default/files/ -type d -exec chown drupal:drupal {} \; -exec chmod 775 {} \;',
    'find /var/www/html/drupal/sites/default/files/ -type f -exec chown drupal:drupal {} \; -exec chmod 664 {} \;',
  ]

  exec {$permissions:
    require => Exec['rsync drupal to docroot'],
    path    => ['/bin', '/usr/bin'],
  }
}

