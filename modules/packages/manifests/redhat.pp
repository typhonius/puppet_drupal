class packages::redhat {

  $rh_packages = ['man', 'nc', 'vim-enhanced']

  package { $rh_packages:
    ensure => "installed",
  }

}
