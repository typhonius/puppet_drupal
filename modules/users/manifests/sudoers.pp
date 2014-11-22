class users::sudoers {

  require users::groups

  file { "/etc/sudoers.d/sudoers_ad_admin":
    ensure => present,
    content => "%ad_admin  ALL=(ALL) NOPASSWD:     ALL",
    owner => "root",
    group => "root",
    mode => "0440",
    require => Group["ad_admin"],
  }

  file { "/etc/sudoers.d/sudoers.ad_admin":
    ensure => absent,
  }

}
