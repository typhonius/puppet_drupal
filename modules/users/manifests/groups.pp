class users::groups {

  group { 'ad_admin':
    gid => 672,
    ensure => "present",
  }

  group { 'ad_user':
    gid => 673,
    ensure => "present",
  }

}
