
node default {
  include misc
  include packages::default
  include packages::sshd

  include users::groups
  include users::sudoers
  include users::root
  include users::drupal

  include packages::php
  include repos::drupalcore
  include docroot

  # include drush
  
  
#MySQL percona
#Php 5.5
#Apache
#Iptables
#Docroot location
#Settings include
#Vcsrepo
# firewall
# cron
#Prompt
#Memcache
#Drush


}
