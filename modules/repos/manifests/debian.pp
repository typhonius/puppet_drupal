class repos::debian {

  class { 'apt':
    always_apt_update => false,
    update_timeout    => 300,
    update_tries      => 1,
  }

  apt::source { 'percona':
    key         => '1C4CBDCDCD2EFD2A',
    key_server  => 'keys.gnupg.net',
    location    => 'http://repo.percona.com/apt',
    repos       => 'main',
    include_src => true,
    include_deb => true
  }

}
