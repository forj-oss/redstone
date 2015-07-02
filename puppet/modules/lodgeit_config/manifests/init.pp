#!/bin/bash

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
class lodgeit_config {
  $packages = [ 'python-imaging',
                'python-jinja2',
                'python-pybabel',
                'python-werkzeug',
                'python-simplejson',
                'python-pygments']

  include apache

  include pip::python2
  a2mod { 'proxy':
    ensure => present,
  }
  a2mod { 'proxy_http':
    ensure => present,
  }

  package { $packages:
    ensure => present,
  }

  if ! defined(Package['python-mysqldb']) {
    package { 'python-mysqldb':
      ensure   => present,
    }
  }

  package { 'SQLAlchemy':
    ensure   => present,
    provider => pip,
    require  => Class[pip::python2],
  }

  file { '/srv/lodgeit':
    ensure => directory,
  }

  vcsrepo { '/tmp/lodgeit-main':
    ensure   => latest,
    provider => git,
    source   => 'https://git.openstack.org/openstack-infra/lodgeit',
  }

}
