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
  $vhost_name   ="paste.${name}.org",
  $image_name   ='', # was header-bg2.png
  $image_source = '', # was puppet:///modules/logedit/header-bg2.png
  ) {

  include apache

  apache::vhost::proxy { $vhost_name:
    port    => 80,
    dest    => "http://localhost:${port}",
    require => File["/srv/lodgeit/${name}"],
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

  if $image_name != '' and $image_source != '' {
    file { "/srv/lodgeit/${name}/lodgeit/static/${image_name}":
      ensure => present,
      source =>  $image_source,
    }
  }

  file { "/srv/lodgeit/${name}/manage.py":
    ensure  => present,
    mode    => '0755',
    replace => true,
    content => template('lodgeit/manage.py.erb'),
    notify  => Service["${name}-paste"],
  }

  file { "/srv/lodgeit/${name}/lodgeit/views/layout.html":
    ensure  => present,
    replace => true,
    content => template('lodgeit/layout.html.erb'),
  }

  exec { "create_database_${name}":
    command => "drizzle --user=root -e \"create database if not exists ${name};\"",
    path    => '/bin:/usr/bin',
    unless  => 'drizzle --disable-column-names -r --batch -e "show databases like \'openstack\'" | grep -q openstack',
    require => Service['drizzle'],
  }

# create a backup .sql file in git

  exec { "create_db_backup_${name}":
    command => "touch ${name}.sql && git add ${name}.sql && git commit -am \"Initial commit for ${name}\"",
    cwd     => '/var/backups/lodgeit_db/',
    path    => '/bin:/usr/bin',
    onlyif  => "test ! -f /var/backups/lodgeit_db/${name}.sql",
  }

# cron to take a backup and commit it in git

  cron { "update_backup_${name}":
    user    => root,
    hour    => 6,
    minute  => 23,
    command => "sleep $((RANDOM\\%60+60)) && cd /var/backups/lodgeit_db && drizzledump -uroot ${name} > ${name}.sql && git commit -qam \"Updating DB backup for ${name}\""
  }

  service { "${name}-paste":
    ensure    => running,
    provider  => upstart,
    require   => [Service['drizzle', 'apache2'], Exec["create_database_${name}"]],
    subscribe => Service['drizzle'],
  }
}