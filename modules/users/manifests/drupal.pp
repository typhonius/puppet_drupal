class users::drupal {

  user { 'drupal':
    ensure => present,
    shell => "/bin/bash",
    home => "/home/drupal",
    managehome => true,
    groups => "ad_admin",
    require => Group['ad_admin'],
  }

}
