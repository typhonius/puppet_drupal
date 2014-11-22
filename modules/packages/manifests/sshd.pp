class packages::sshd {

  $port = 22

  file { '/etc/ssh/sshd_config':
    ensure  => file,
    mode    => '0600',
    # source  => 'puppet:///modules/services/sshd_config',
    content => template('services/sshd_config.erb'),
  }
  service { 'sshd':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/ssh/sshd_config'],
  }
