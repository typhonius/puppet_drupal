
node default {
  include misc
  include packages::default

  include users::groups
  include users::sudoers
  include users::root
  include users::drupal

  include packages::ssh
  # include docroot

  # include drush
  
  
#Ssh
#MySQL percona
#Php 5.5
#Apache
#User
#Sudoers
#Iptables
#Docroot location
#Settings include
#Vcsrepo
# firewall
# cron
#Common packages
#Motd
#Prompt
#Memcache
#Drush


}
