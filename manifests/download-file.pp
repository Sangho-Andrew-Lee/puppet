define download_file(
  $site="",
  $cwd="",
  $creates="",
  $requires="",
  $user="") {

  exec { $name:
    command => "/usr/bin/wget ${site}/${name}",
    cwd     => $cwd,
    creates => "${cwd}/${name}",
    user    => $user
  }

}
