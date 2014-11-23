class repos::drupalcore {

  file { '/var/www/repo':
    ensure => 'directory',
  }

  vcsrepo { '/var/www/repo/drupal':
    ensure   => present,
    provider => git,
    source   => 'http://git.drupal.org/project/drupal.git',
    revision => '7.34'
  }
}
