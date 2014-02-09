class bacula::client (
  $bacula_fd_pass,
  $bacula_mon_pass,
  $bacula_fd_name      = "${hostname}-fd",
  $bacula_fd_port      = 9102,
  $bacula_dir_name     = 'bacula-dir',
  $bacula_mon_name     = 'bacula-mon',
  $max_concurrent_jobs = 1,
) inherits bacula::params {
   package { $bacula::params::bacula_client_pkgs: ensure => latest }

   service { $bacula::params::bacula_client_service:
      ensure  => running,
      enable  => true,
      require => Package[$bacula::params::bacula_client_pkgs],
   }

   file { $bacula::params::bacula_fd_path:
      owner   => root,
      group   => root,
      mode    => 640,
      require => Package[$bacula::params::bacula_client_pkgs],
      content => template($bacula::params::bacula_fd_tmpl),
      notify  => Service[$bacula::params::bacula_client_service]
   }
}
