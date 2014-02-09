class bacula::server (
   $bacula_db_pass,
   $bacula_dir_pass,
   $bacula_sd_pass,
   $bacula_mon_pass,
   $bacula_dir_name     = 'bacula-dir',
   $bacula_dir_port     = 9101,
   $bacula_dir_address  = 'localhost',
   $bacula_sd_name      = 'bacula-sd',
   $bacula_sd_port      = 9103,
   $bacula_mon_name     = 'bacula-mon',
   $bacula_db_host      = '127.0.0.1',
   $bacula_db_name      = 'bacula',
   $bacula_db_user      = 'bacula',
   $dbi_mysql           = true,
   $dbi_postgresql      = false,
   $root_db_pass        = undef,
   $old_root_db_pass    = undef,
   $catalog_job_def     = 'DefaultJob',
   $bconsole_template   = $bacula::params::bconsole_tmpl,
   $bacula_dir_template = $bacula::params::bacula_dir_tmpl,
   $bacula_sd_template  = $bacula::params::bacula_sd_tmpl,
   $job_defs            = undef,
   $filesets            = {},
   $clients             = {},
   $storage             = {},
   $pools               = {},
   $max_concurrent_jobs = 1,
   $mail_from           = '\(Bacula\) \<%r\>',
   $mail_to             = 'root@localhost',
) inherits bacula::params {

   package { $bacula::params::bacula_server_pkgs: ensure => latest }

   file { $bacula::params::bconsole_path:
        owner   => root,
        group   => root,
        mode    => 644,
        content => template($bconsole_template),
        require => Package[$bacula::params::bacula_server_pkgs],
   }

   file { $bacula::params::bacula_dir_path:
        owner   => root,
        group   => root,
        mode    => 644,
        content => template($bacula_dir_template),
        #require => [Package["bacula-director"],Exec["bacula-mysql-db-populate"]],
        require => Package[$bacula::params::bacula_server_pkgs],
        notify  => Service[$bacula::params::bacula_dir_service]
   }

   file { $bacula::params::bacula_sd_path:
       owner   => root,
       group   => root,
       mode    => 640,
       content => template($bacula_sd_template),
       require => Package[$bacula::params::bacula_server_pkgs],
       notify  => Service[$bacula::params::bacula_sd_service]
   }

   if ($bacula::params::libbaccats) {
       if ($dbi_mysql) {
           $liblink = $bacula::params::dbi_mysql_lib
       } else {
           $liblink = $bacula::params::dbi_postgresql_lib
       }
       file { $bacula::params::libbaccats:
           ensure  => link,
           target  => $liblink,
           require => Package[$bacula::params::bacula_server_pkgs],
       }
   }

   if ($root_db_pass) {
       $mrp_opt = "-p'${root_db_pass}'"
       $root_password = $root_db_pass
   } else {
       $mrp_opt = ""
       $root_password = $mysql::params::root_password
   }

   if ($old_root_db_pass) {
       $old_root_password = $old_root_db_pass
   } else {
       $old_root_password = $mysql::params::old_root_password
   }

   if ($bacula_db_host == $hostname or $bacula_db_host == $ipaddress or $bacula_db_host == '127.0.0.1' or $bacula_db_host == 'localhost') {
       # Install the database
       case $operatingsystem {
           fedora: {
               class { 'mysql':
                   old_root_password => $old_root_password,
                   root_password => $root_password,
               }
               class { 'mysql::server':
                   service_provider => systemd,
                   service_name => 'mariadb.service'
               }
           }
           default: {
               class { 'mysql':
                   old_root_password => $old_root_password,
                   root_password => $root_password,
               }
               class { 'mysql::server': }
           }
       }
       mysql::db { $bacula_db_name:
           user     => $bacula_db_user,
           password => $bacula_db_pass,
           charset  => 'latin1',
           notify   => Exec["bacula-mysql-db-create"]
       }
   }


   exec { "bacula-mysql-db-create":
        command => "create_mysql_database -h ${bacula_db_host} ${mrp_opt}",
        path => [ '/usr/libexec/bacula' ],
        refreshonly => true,
        notify => Exec["bacula-mysql-grant"],
        timeout => 0
   }

   file { $bacula::params::bacula_mysql_grant:
        owner   => 'root',
        group   => 'root',
        mode    => 0755,
        source  => 'puppet:///modules/bacula/grant_mysql_privileges',
        require => Package[$bacula::params::bacula_server_pkgs]
   }
   
   exec { "bacula-mysql-grant":
        command => "$bacula::params::bacula_mysql_grant ${bacula_db_name} ${bacula_db_user} ${bacula_db_pass} -h ${bacula_db_host} ${mrp_opt}",
        path => [ '/usr/libexec/bacula' ],
        refreshonly => true,
        notify => Exec["bacula-mysql-db-populate"],
        timeout => 0
   }

   exec { "bacula-mysql-db-populate":
        command => "make_mysql_tables -h ${bacula_db_host} ${mrp_opt}",
        path => [ '/usr/libexec/bacula' ],
        refreshonly => true,
        timeout => 0
   }

   service { $bacula::params::bacula_dir_service:
       enable     => true,
       ensure     => running,
       hasrestart => true,
   }

   service { $bacula::params::bacula_sd_service:
       enable     => true,
       ensure     => running,
       hasrestart => true,
   }
}
