class packages::sshd {

  $port = 22

  file { '/etc/ssh/sshd_config':
    ensure  => file,
    mode    => '0600',
    content => template('packages/sshd_config.erb'),
  }

  case $::osfamily {
    'debian': {
      $service              = 'ssh'
    }
    'redhat': {
      $service              = 'sshd'
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }

  service { $service:
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/ssh/sshd_config'],
  }
}
