class misc {

  # Make the timezone UTC
  case $::osfamily {
    'debian': {
      $file = '/etc/timezone'
      $content = 'Etc/UTC'
    }
    'redhat', 'freebsd': {
      $file = '/etc/localtime'
      $content = 'TZif2UTCTZif2UTC
      UTC0'
    }
    default: {
      $file = '/etc/localtime'
      $content = 'TZif2UTCTZif2UTC
      UTC0'
    }
  }

  file {'timezone':
    path    => "${file}",
    content => "${content}",
    replace => true,
  }
}
