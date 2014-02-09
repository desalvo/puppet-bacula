class bacula::web (
  $db_pass,
  $db_user = 'bacula',
  $db_name = 'bacula',
  $db_host = 'localhost',
  $sudo = false,
  $bacula_web_template = "bacula/webacula_config.ini.erb",
  $auth_user_file = "/etc/httpd/conf/webacula.users",
) inherits bacula::params {
    include apache::params
    include apache::service

    package { $bacula::params::webacula_pkgs: ensure => latest, notify => Class['apache::service'] }
    package { $apache::params::mod_packages['ssl']: ensure => latest, notify => Class['apache::service'] }

    augeas { 'set webacula access':
        context => "/files$bacula::params::webacula_conf",
        changes => [
                    "rm Directory[arg='$bacula::params::webacula_dir']/directive[.='Deny']",
                    "set Directory[arg='$bacula::params::webacula_dir']/directive[.='Allow']/arg[2] all",
                    "set Directory[arg='$bacula::params::webacula_dir']/directive[.='AuthType'] AuthType",
                    "set Directory[arg='$bacula::params::webacula_dir']/directive[.='AuthType']/arg Basic",
                    "set Directory[arg='$bacula::params::webacula_dir']/directive[.='AuthName'] AuthName",
                    "set Directory[arg='$bacula::params::webacula_dir']/directive[.='AuthName']/arg Webacula",
                    "set Directory[arg='$bacula::params::webacula_dir']/directive[.='AuthUserFile'] AuthUserFile",
                    "set Directory[arg='$bacula::params::webacula_dir']/directive[.='AuthUserFile']/arg ${bacula::params::webacula_user_auth}",
                    "set Directory[arg='$bacula::params::webacula_dir']/directive[.='Require'] Require",
                    "set Directory[arg='$bacula::params::webacula_dir']/directive[.='Require']/arg valid-user",
                   ],
        require => [Package[$bacula::params::webacula_pkgs],Package[$apache::params::mod_packages['ssl']]],
        notify => Class['apache::service'],
    }

    exec { 'fix webacula index.php':
        command => "sed -i 's/\(^define(.BACULA_VERSION., *\)\([0-9]*\)/\114/' $bacula::params::webacula_index",
        path    => [ "/bin", "/usr/bin" ],
        unless  => "grep -q '^define(.BACULA_VERSION., *14' $bacula::params::webacula_index",
        require => Package[$bacula::params::webacula_pkgs]
    }

    file { $bacula::params::webacula_user_auth:
        owner   => root,
        group   => root,
        mode    => 644,
        source  => $auth_user_file,
        require => Package[$bacula::params::webacula_pkgs],
    }

    file { "/etc/webacula/config.ini":
        owner   => root,
        group   => root,
        mode    => 644,
        content => template($bacula_web_template),
        require => Package[$bacula::params::webacula_pkgs],
    }
}

