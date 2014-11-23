
node default {
  include misc
  include packages::default
  include packages::sshd

  include users::groups
  include users::sudoers
  include users::root
  include users::drupal

  include repos
  include repos::drupalcore
  include packages::php
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
