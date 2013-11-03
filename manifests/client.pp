class bacula::client ($fdpass) {
   package{'bacula-client': ensure => latest}

   service { "bacula-fd":
      ensure  => running,
      enable  => true,
      require => Package["bacula-client"],
   }

   file { "/etc/bacula/bacula-fd.conf":
      owner   => root,
      group   => root,
      mode    => 640,
      require => Package["bacula-client"],
      content => template("bacula/bacula-fd.erb"),
      notify  => Service["bacula-fd"]
   }
}
