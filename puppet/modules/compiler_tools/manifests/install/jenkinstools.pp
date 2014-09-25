# == compiler_tools::install::jenkinstools
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
#
class compiler_tools::install::jenkinstools (
)
{
  include compiler_tools::params::jenkinstools
  if ! defined(File['/usr/local/jenkins'])
  {
    file { '/usr/local/jenkins':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  if ! defined(File['/usr/local/jenkins/slave_scripts'])
  {
    file { '/usr/local/jenkins/slave_scripts':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      recurse => true,
      purge   => true,
      force   => true,
      require => File['/usr/local/jenkins'],
      source  => 'puppet:///modules/jenkins/slave_scripts',
    }
  }

  if ! defined(File['/usr/local/jenkins/runtime_scripts'])
  {
    file { '/usr/local/jenkins/runtime_scripts':
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      recurse => true,
      purge   => true,
      force   => true,
      require => File['/usr/local/jenkins'],
      source  => 'puppet:///modules/runtime_project/jenkins/scripts',
    }
  }

  if ! defined(File['/etc/sudoers.d/jenkins-sudo-grep'])
  {
    file { '/etc/sudoers.d/jenkins-sudo-grep':
      ensure => present,
      source => 'puppet:///modules/jenkins/jenkins-sudo-grep.sudo',
      owner  => 'root',
      group  => 'root',
      mode   => '0440',
    }
  }

  if ! defined(File['/etc/sudoers.d/jenkins-sudo-salt-call'])
  {
    file { '/etc/sudoers.d/jenkins-sudo-salt-call':
      ensure => present,
      source => 'puppet:///modules/jenkins_config/jenkins-sudo-salt-call.sudo',
      owner  => 'root',
      group  => 'root',
      mode   => '0440',
    }
  }

  if ! defined(Vcsrepo['/opt/requirements'])
  {
    vcsrepo { '/opt/requirements':
      ensure   => latest,
      provider => git,
      revision => 'master',
      source   => 'https://git.openstack.org/openstack/requirements',
    }
  }
}
