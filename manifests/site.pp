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

node 'ip-172-31-25-212' {

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


  ################################################################
  ##
  ## Start of the PHP5 settings
  ##
  ################################################################


  file { "/etc/php5/apache2/conf.d/20-mcrypt.ini":
    ensure  => link,
    target  => '/etc/php5/conf.d/mcrypt.ini',
    require => Package['php5-mcrypt'],
    alias   => 'apache2-mcrypt-symlink'
  }

  file { "/etc/php5/cli/conf.d/20-mcrypt.ini":
    ensure  => link,
    target  => '/etc/php5/conf.d/mcrypt.ini',
    require => Package['php5-mcrypt'],
    alias   => 'cli-mcrypt-symlink'
  }

  ################################################################
  ##
  ## Start of the Composer installation
  ##
  ################################################################

  class { 'composer': }

  composer::install_composer {'composer-install':  }

  ################################################################
  ##
  ## Start of the CakePHP installation
  ##
  ################################################################

  #Make sure this is updated
  file { '/usr/share/php5/includes/composer.json':
    ensure  => file,
    require => [Package['php5-mcrypt'], Composer::Install_composer['composer-install'], File['cli-mcrypt-symlink'], File['apache2-mcrypt-symlink']],
    source  => 'puppet:///files/composer/composer.json'
  }

  #Creating a vendor/
  exec { 'cakephp-install':
    cwd         => '/usr/share/php5/includes',
    command     => 'composer update',
    environment => ["COMPOSER_HOME=/usr/bin/composer"],
    path        => ["/usr/local/bin", "/usr/bin"],
    require     => File['/usr/share/php5/includes/composer.json']
  }

  file { '/etc/php5/apache2/conf.d/cakephp.ini':
    ensure  => file,
    source  => 'puppet:///files/php5/cakephp.ini',
    require => Exec['cakephp-install']
  }

}

