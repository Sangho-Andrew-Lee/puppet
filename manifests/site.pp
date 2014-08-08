################################################################
################################################################
##
## Start of the Evergreenhill installation
##
################################################################
################################################################

stage { 'first':
  before => Stage['main'],
}

node 'common' {

   #This is where all of the common packages go for all servers
  package {
     [
        'php5',
        'htop',
        'iotop',
        'git',
        'apache2',
        'php5-mcrypt',
        'php5-mysqlnd',
        'libssh2-php',
        'mysql-client',
        'php5-xdebug',
        'vim'
     ]:
     ensure     => 'present',
     require    => Exec['apt-update']

  }

  exec { 'apt-update':
    command     => 'apt-get update',
    path        => ["/bin", "/usr/bin"],
  }

  file { '/root/.ssh/authorized_keys':
    ensure  => file,
    owner   => 'root',
    mode    => '0600',
    group   => 'root',
    source  => 'puppet:///files/common/ssh/authorized_keys'
  }

}

