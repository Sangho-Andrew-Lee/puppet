
class composer(){ }

define composer::install_composer ($dir='/opt/composer') {

  file{ "${dir}":
    ensure  => directory
  }

  exec { "composer-install":
    cwd     => "${dir}",
    command => '/usr/bin/curl -sS https://getcomposer.org/installer | php',
    require => File["${dir}"],
    creates => "${dir}/composer.phar" # Creates that file if it does not exists.
  }

  #Make sure the composer.phar is executable.
  file { "${dir}/composer.phar":
    ensure  => present,
    require => Exec['composer-install'],
    mode    => '0755'
  }

  #Create a symlink to the /usr/bin so Composer can be expose globally.
  file { '/usr/bin/composer':
    ensure  => link,
    target  => "${dir}/composer.phar",
    require => File["${dir}/composer.phar"]
  }

}