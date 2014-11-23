class packages::default {

  #include repos::epel

  $default = [
    'bash-completion',
    'ccze',
    'clamav',
    'dstat',
    'git',
    'htop',
    'iftop',
    'multitail',
    'nmap',
    'nethogs',
    'openssh-server',
    'percona-toolkit',
    'screen',
    'socat',
    'strace',
    'sudo',
    'telnet',
    'tree',
  ]

  case $::operatingsystem {
    'Debian','Ubuntu': {
      include packages::debian
    }
    'CentOS'         : {
      include packages::redhat
    }
  }

  package { $default:
    ensure => "installed",
  }
}
