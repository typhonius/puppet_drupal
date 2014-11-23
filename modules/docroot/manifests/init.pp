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
  if $::operatingsystem == 'Fedora' {
    include apache::mod::fcgid
    apache::mod { 'proxy_fcgi': }
    apache::mod { 'access_compat': }

    # Hax to load unixd before any other mods.
    file {'/etc/httpd/conf.d/aunixd.load':
      ensure => 'link',
      target => '/etc/httpd/conf.d/unixd.load',
    }
  }
  else {
    include apache::mod::fastcgi
    apache::mod { 'authz_default': }
  }

include apache::mod::status
  include apache::mod::rewrite
  include apache::mod::proxy
  include apache::mod::actions
  include apache::mod::auth_basic
  include apache::mod::setenvif

  apache::mod { 'authn_file': }
  apache::mod { 'authz_user': }

}

