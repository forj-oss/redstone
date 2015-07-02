# == Define: site
# Copyright 2013 OpenStack Foundation.
# Copyright 2013 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
define lodgeit_config::site(
  $port,
  $vhost_name    = "paste.${name}.org",
  $image         = '', # was header-bg2.png
  $image_source  = '', # was puppet:///modules/logedit/header-bg2.png
  $serveraliases = '',
  ) {

  include apache

  apache::vhost::proxy { $vhost_name:
    port          => 80,
    dest          => "http://localhost:${port}",
    serveraliases => $serveraliases,
    require       => File["/srv/lodgeit/${name}"],
  }

  file { "/etc/init/${name}-paste.conf":
    ensure  => present,
    content => template('lodgeit/upstart.erb'),
    replace => true,
    require => Package['apache2'],
    notify  => Service["${name}-paste"],
  }

  file { "/srv/lodgeit/${name}":
    ensure  => directory,
    recurse => true,
    source  => '/tmp/lodgeit-main',
  }

  if $image != '' and $image_source != '' {
    file { "/srv/lodgeit/${name}/lodgeit/static/${image}":
      ensure  => present,
      source  => $image_source,
      replace => true,
    }
  }

  file { "/srv/lodgeit/${name}/manage.py":
    ensure  => present,
    mode    => '0755',
    replace => true,
    content => template('lodgeit_config/manage.py.erb'),
    notify  => Service["${name}-paste"],
  }

  file { "/srv/lodgeit/${name}/lodgeit/views/layout.html":
    ensure  => present,
    replace => true,
    content => template('lodgeit/layout.html.erb'),
  }

  service { "${name}-paste":
    ensure   => running,
    provider => upstart,
    require  => Service['apache2'],
  }
}
