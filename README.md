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

Usage
-----

### Example

This is a simple example to configure the bacula client, using the password *PASS*.

**Using the bacula client module**

```bacula::client
class { 'bacula::client':
    fdpass => 'PASS',
}
```

Limitations
------------

* Only the client customizations are currently supported

Contributors
------------

* https://github.com/desalvo/puppet-bacula/graphs/contributors

Release Notes
-------------

**0.1.0**

* Initial version
