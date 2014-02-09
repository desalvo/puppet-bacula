class bacula::params {

  case $::osfamily {
    'RedHat': {
      $bconsole_tmpl      = 'bacula/bconsole.conf.erb'
      $bconsole_path      = '/etc/bacula/bconsole.conf'
      $bacula_dir_tmpl    = 'bacula/bacula-dir.conf.erb'
      $bacula_dir_path    = '/etc/bacula/bacula-dir.conf'
      $bacula_sd_tmpl     = 'bacula/bacula-sd.conf.erb'
      $bacula_sd_path     = '/etc/bacula/bacula-sd.conf'
      $bacula_fd_path     = '/etc/bacula/bacula-fd.conf'
      $bacula_fd_tmpl     = 'bacula/bacula-fd.conf.erb'
      $webacula_conf      = '/etc/httpd/conf.d/webacula.conf'
      $webacula_dir       = '/usr/share/webacula/html'
      $webacula_user_auth = "/etc/httpd/conf/webacula.users"
      $webacula_index     = "/usr/share/webacula/html/index.php"
      $webacula_pkgs      = [
                             'webacula',
                             'php-ZendFramework-Db-Adapter-Pdo-Mysql',
                            ]

      $bacula_client_pkgs = [
                             'bacula-client',
                            ]

      $bacula_server_pkgs = [
                             'bacula-console',
                             'bacula-director',
                             'bacula-storage',
                             'bacula-libs-sql'
                            ]
      $bacula_client_service = 'bacula-fd'
      $bacula_dir_service    = 'bacula-dir'
      $bacula_sd_service     = 'bacula-sd'
      $bacula_mysql_grant    = '/usr/libexec/bacula/grant_mysql_privileges.password'
      case $::operatingsystem {
        fedora:  {
                   $libbaccats         = '/etc/alternatives/libbaccats.so'
                   $dbi_mysql_lib      = '/usr/lib64/libbaccats-mysql.so'
                   $dbi_postgresql_lib = '/usr/lib64/libbaccats-postgresql.so'
                 }
        default: {
                   $libbaccats         = undef
                   $dbi_mysql_lib      = undef
                   $dbi_postgresql_lib = undef
        }
      }
    }
    default:   {
    }
  }

}
