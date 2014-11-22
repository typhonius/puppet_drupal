class users::root {

  user { 'root':
    ensure => present,
    shell => "/bin/bash",
    home => "/root",
    managehome => true,
  }

}
