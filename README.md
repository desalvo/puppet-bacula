puppet-bacula
======

Puppet module for managing Bacula.

#### Table of Contents
1. [Overview - What is the bacula module?](#overview)

Overview
--------

This module is intended to be used to manage the Bacula backup system configuration.
[Bacula](http://www.bacula.org) is a high-performance, enterprise-grade backup system.
Currently only the client configuration is supported.

Parameters
----------

**Client parameters**
```
class { bacula::client }
```

* **bacula_fd_pass**: the bacula FD (client service) password
* **bacula_mon_pass**: the bacula Mon password
* **bacula_fd_name**: the name of the client (FD), defaults to ${hostname}-fd
* **bacula_fd_port**: the FD port to be used, default is 9102
* **bacula_dir_name**: the bacula DIR (server) name, default is bacula-dir
* **bacula_mon_name**: the bacula Mon (monitoring tray agent) name, default is to bacula-mon
* **max_concurrent_jobs**: the maximum number of allowed concurrent jobs, default is 1

**Server parameters**
```
class { bacula::server }
```

* **bacula_db_pass**: the bacula DB password
* **bacula_dir_pass**: the bacula Director password
* **bacula_sd_pass**: the bacula Storage Daemon (SD) password
* **bacula_mon_pass**: the bacula Mon password
* **bacula_dir_name**: [optional] the bacula Director name, default is bacula-dir
* **bacula_dir_port**: [optional] the bacula Director port, default is 9101
* **bacula_dir_address**: [optional] the bacula Director hostname, default is localhost
* **bacula_sd_name**: [optional] the bacula SD name, default is bacula-sd
* **bacula_sd_port**: [optional] the bacula SD port, default is 9103
* **bacula_mon_name**: [optional] the bacula Mon name, default is bacula-mon,
* **bacula_db_host**: [optional] the bacula DB host, default is 127.0.0.1
* **bacula_db_name**: [optional] the bacula DB name, default is bacula
* **bacula_db_user**: [optional] the bacula DB username, default is bacula
* **dbi_mysql**: [optional] set this to true to enable the MySQL engine, default is true
* **dbi_postgresql**: [optional] set this to true to enable the Postgresql engine, default is false
* **root_db_pass**: [optional] the root DB password, default is undef. You need to set the password when installing the Bacula DB for the first time in a host
* **old_root_db_pass**: [optional] the old DB password, default is undef, needed when you want to change an existing DB password
* **catalog_job_def**: [optional] the job def used for the catalog, default is DefaultJob
* **bconsole_template**: [optional] used to specify a custom bconsole configuration template
* **bacula_dir_template**: [optional] used to specify a custom bacula director configuration template
* **bacula_sd_template**: [optional] used to specify a custom storage daemon configuration template
* **job_defs**: hash containing the job definitions
* **filesets**: hash containing the fileset definitions
* **clients**: hash containingthe clients definitions
* **storage**: hash containing the storage area definitions
* **pools**: hash containing the pool definitions
* **max_concurrent_jobs**: [optional] the maximum number of allowed concurrent jobs, default is 1
* **mail_from**: [optional] the from header of the mail notifications, default is '\(Bacula\) \<%r\>'
* **mail_to**: [optional] the recipient of the mail notifications, default is root@localhost

**Web interface (webacula) parameters**
```
class { bacula::web }
```

* **db_pass**: the bacula DB password
* **db_user**: [optional] the bacula db user, deafult is bacula
* **db_name**: [optional] the bacula db name, default is bacula
* **db_host**: [optional] the bacula DB host, default is localhost
* **sudo**: [optional] use sudo in contacting bacula services, default is false
* **bacula_web_template**: custom template for webacula
* **auth_user_file**: custom auth user file

Hash definitions
----------------

**Job definitions**

The job definitions are the main structure to define backup and restore jobs.
The job_defs has the following structure:

```bacula::jobdef
$job_defs = { jobname => { option => value } }
```

Jobname is a custom job name. The following options are accepted:

* **backup**: the backup job name
* **client**: the client name
* **fileset**: the fileset name
* **level**: [optional] the backup level, default is Incremental
* **messages**: [optional] the messages type, default is Standard
* **pool**: the pool name
* **priority**: [optional] the job priority, default is 10
* **restore**: the restore job name
* **schedule**: the schedule name, currently only WeeklyCycle is supported 
* **storage**: the storage name

**Filesets definitions**

The filesets define the list of files to be backed up or restored during a job.
The filesets has the following structure:

```bacula::filesets
$filesets = { fileset_name => { option => value } }
```

Fileset_name is a custom file name. The following options are accepted:

* **include**: a list of file paths to include in the fileset, like ['/etc', '/var']
* **exclude**: a list of file paths to exclude from the fileset, like ['/boot', '/proc']

**Client definitions**

The clients hash is used to describe the backup clients.
The hash structure is:

```bacula::clients
$clients = { client_name => { option => value } }
```

The supported options are:

* **address**: the hostname of the client
* **port**: [optional] the FD port, default is 9102
* **password**: the FileDaemon password
* **file_retention**: [optional] the retention time for files, default is 30 days
* **job_retention**: [optional] the retention time for jobs, default is 6 months

**Storage definitions**

The storage hash is used to describe the storage devices.
The hash structure is:

```bacula::storage
$storage = { storage_name => { option => value } }
```

The supported options are:

* **address**:
* **port**: [optional] the SD port, default is 9103
* **password**: the SD password
* **device**: a name describing the storage device 
* **archive_device**: the path to the archive device 
* **media_type**: [optional] the media type, default is File

**Pool definitions**

The pools hash describes the storage pools.
The hash structure is:

```bacula::pools
$pools = { pool_name => { option => value } }
```

The supported options are:

* **volume_retention**: [optional] the volume retention time, defaul is 1 year
* **max_vol_bytes**: [optional] the maximum size of the volumes
* **max_vols**: [optional] the maximum number of volumes
* **next_pool**: [optional] the next pool name
* **storage**: [optional] the storage name of the pool

Usage
-----

### Examples

This is a simple example to configure the bacula client, using the password *PASS*.

**Using the bacula client module**

```bacula::client
class { 'bacula::client':
    fdpass => 'PASS',
}
```

Example configuration of a bacula server:
 * to configure the bacula client, using the password *PASS*.

**Using the bacula client module**

```bacula::server
$clients  = {
              'host1'  => {
                           'address' => 'host1.example.com',
                           'password' => 'FDpass',
                           'file_retention' => '20 days',
                           'job_retention' => '2 months',
                          },
              'host2'  => {
                           'address' => 'host2.example.com',
                           'password' => 'FDpass',
                           'file_retention' => '20 days',
                           'job_retention' => '2 months',
                          }
            }

$storage  = {
              'File'    => {
                            'address' => 'pc-ads-03.roma1.infn.it',
                            'password' => 'BaculaSDBackup',
                            'device' => 'FileStorage',
                            'archive_device' => '/bacula/file/data',
                           },
              'Scratch' => {
                            'address' => 'pc-ads-03.roma1.infn.it',
                            'password' => 'BaculaSDBackup',
                            'device' => 'ScratchStorage',
                            'archive_device' => '/bacula/scratch/data',
                           },
            }

$pools    = {
              'Default' => {
                            'volume_retention' => '365 days',
                            'next_pool' => 'File',
                           },
              'File'    => {
                            'volume_retention' => '20 days',
                            'max_vol_bytes' => '50G',
                            'max_vols' => '100',
                            'next_pool' => 'Scratch',
                           },
              'Scratch' => {
                            'volume_retention' => '20 days',
                            'max_vol_bytes' => '50G',
                            'max_vols' => '100',
                            'storage' => 'Scratch',
                           },
            }

$job_defs = {
             'job1' => {
                        'backup'   => 'BackupHost1',
                        'restore'  => 'RestoreHost1',
                        'client'   => 'host1-fd',
                        'fileset'  => 'Workstation1',
                        'schedule' => 'WeeklyCycle',
                        'storage'  => 'File',
                        'pool'     => 'File',
                       },
             'job2' => {
                        'backup'   => 'BackupHost2',
                        'restore'  => 'RestoreHost2',
                        'client'   => 'host2-fd',
                        'fileset'  => 'Workstation2',
                        'schedule' => 'WeeklyCycle',
                        'storage'  => 'File',
                        'pool'     => 'File',
                       },
            }

$filesets = {
              'Workstation1' => { 'include' => [ '/home', '/etc' ] },
              'Workstation2' => {
                                  'include' => [ '/var', '/etc' ],
                                  'exclude' => [ '/var/log' ],
                                }
            }

class { 'bacula::server':
    catalog_job_def => 'host1',
    job_defs        => $job_defs,
    filesets        => $filesets,
    clients         => $clients,
    storage         => $storage,
    pools           => $pools,
    bacula_dir_pass => 'bacula_dir_pass',
    bacula_sd_pass  => 'bacula_sd_pass',
    bacula_mon_pass => 'bacula_mon_pass',
    bacula_db_user  => 'bacula',
    bacula_db_pass  => 'bacula_db_pass',
    mail_to         => 'root@example.com',
    max_concurrent_jobs => 10,
    old_root_db_pass => undef,
    root_db_pass     => 'db_pass',
}

class { 'bacula::web':
    db_user => 'bacula',
    db_pass => 'bacula_db_pass',
    auth_user_file => 'puppet:///modules/mymodule/webacula.users'
}

```

Limitations
------------

* Only mysql is currently supported

Contributors
------------

* https://github.com/desalvo/puppet-bacula/graphs/contributors

Release Notes
-------------

**0.2.1**

Fixes for mylsql::server

**0.2.0**

Added support for bacula server

**0.1.0**

* Initial version
