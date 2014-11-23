class docroot {

  if ! defined(File['/var/www']) {
    file { '/var/www':
      ensure => 'directory',
    }
  }
  if ! defined(File['/var/www/html']) {
    file { '/var/www/html':
      ensure => 'directory',
    }
  }
  if ! defined(File["/var/www/repo"]) {
    file { "/var/www/repo":
      ensure => 'directory',
    }
  }

  file { '/var/www/fpm':
    ensure  => 'directory',
    require => File['/var/www'],
  }

  file { '/var/www/site-settings-php':
    ensure => 'directory',
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
    docroot_owner => 'drupal',
    docroot_group => $apache,
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

}

