#apache2

class apache2($version = 'latest') {

  $apache_package = $::osfamily ? {
    redhat  => "httpd",
    default => "apache2",
  }

#httpd
  package { $apache_package:
    ensure => $version,
    alias  => 'httpd'
  }

#services
  service { $apache_package:
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['httpd'],
    alias      => 'httpd'
  }


#executables
  exec { 'reload-apache2':
    command     => "/etc/init.d/${apache_package} reload",
    refreshonly => true
  }

#remove welcome.conf
  file { '/etc/httpd/conf.d/welcome.conf':
    ensure  => absent,
    owner   => "root",
    require => Package['httpd']
  }

}

#vitrual_host
define apache2::virtual_host (
  $document_root,
  $server_name,
  $template  = 'apache2/web_backend.erb',
  $aliases   = [],
  $ssl       = false,
  $certFile  = undef,
  $certKey   = undef,
  $certInter = undef,
  $authFile  = undef,
  $host_port = undef
  ) {

  $apache_conf_dir = $::osfamily ? {
    redhat  => "httpd",
    default => "apache2",
  }

  $apache_site_dir = $::osfamily ? {
    redhat  => "conf.d",
    default => "sites-enabled",
  }
  
  if ($ssl ) {
    $port   = 443
  } elsif ($host_port) {
    $port   = $host_port
  } else {
    $port   = 80
  }
  
  file { "/etc/${apache_conf_dir}/${apache_site_dir}/${name}.conf":
    ensure  => present,
    owner   => "root",
    content => template($template),
    require => Package['httpd'],
    notify  => Service['httpd']
  }
}

