#!/bin/bash
 
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
 
function get_hostname() {
  read -p "Enter hostname: " hostname
  if [ -z "$hostname" ]; then
    get_hostname
  fi
  HN=$hostname
  echo "Setting hostname to $HN"
}
 
get_hostname
 
if [[ -f "/etc/redhat-release" ]]; then
  OS='centos'
  VERSION=$(grep -o '\s[0-9]\.[0-9]' /etc/redhat-release | cut -d. -f1 | sed 's/^[ ]//g')
  DISTRO='redhat'
elif lsb_release 2> /dev/null; then
  . /etc/lsb-release
  OS=$DISTRIB_ID
  VERSION=$DISTRIB_RELEASE
  CODENAME=$DISTRIB_CODENAME
  DISTRO='debian'
fi
 
if [ $DISTRO == 'redhat' ]; then
  if [ $OS == 'centos' ]; then
    /bin/rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-$VERSION.noarch.rpm
    /usr/bin/yum -y update
    /usr/bin/yum install -y puppet
 
    if [[ $VERSION == 7 ]]; then
      hostname -b $HN
    else
      hostname $HN
    fi
 
    sed -e "s/HOSTNAME=.*/HOSTNAME=$HN/" /etc/sysconfig/network
    hostname $HN
 
    /etc/init.d/network restart
  fi
elif [ $DISTRO == 'debian' ]; then
  if [ $OS == 'Ubuntu' ]; then
    /bin/echo $HN > /etc/hostname
    if [ $DISTRIB_RELEASE > "13.03" ]; then
      /usr/bin/hostnamectl set-hostname $HN
    else
      /bin/hostname $HN
    fi
 
    /usr/bin/wget https://apt.puppetlabs.com/puppetlabs-release-$CODENAME.deb
    /usr/bin/dpkg -i puppetlabs-release-$CODENAME.deb
    /usr/bin/apt-get -y update
    /usr/bin/apt-get -y install puppet
  fi
fi
exit
 
 
#cat >> /etc/puppet/puppet.conf << "EOF"
 
#    server = puppet.adammalone.net
#    report = true
#    pluginsync = true
#EOF
 
#puppet agent --waitforcert 60 --test
