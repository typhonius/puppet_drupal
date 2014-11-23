class repos {

  case $::osfamily {
    'debian': {
      include repos::debian
    }
    'redhat': {
      include repos::redhat
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }

}
