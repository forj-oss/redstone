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
# Defined resource type to install jenkins plugins.
#
# Borrowed from: https://github.com/jenkinsci/puppet-jenkins
#

define jenkins_config::plugin(
  $version           = 0,
  $provider          = jenkins, # possible values jenkins , download
  $download_url      = undef,
  $download_md5      = undef,
  $jenkins_user      = 'jenkins',
  $jenkins_group     = 'jenkins',
  $update_site       = 'http://updates.jenkins-ci.org',
  $plugin_parent_dir = '/var/lib/jenkins',
  $plugin_dir        = '/var/lib/jenkins/plugins',
  $ensure            = present,
) {
  $plugin            = "${name}.hpi"

  if ( $ensure == present)
  {
    if (!defined(File[$plugin_dir])) {
      file {
        [
          $plugin_parent_dir,
          $plugin_dir,
        ]:
          ensure  => directory,
          owner   => $jenkins_user,
          group   => $jenkins_group,
          require => [Group[$jenkins_group], User[$jenkins_user]],
      }
    }

    if (!defined(Group[$jenkins_group])) {
      group { $jenkins_group :
        ensure => present,
      }
    }

    if (!defined(User[$jenkins_user])) {
      user { $jenkins_user :
        ensure => present,
      }
    }

    if ( $provider == jenkins )
    {
      if ($version != 0) {
        $base_url = "${update_site}/download/plugins/${name}/${version}"
      }
      else {
        $base_url   = "${update_site}/latest"
      }
      exec { "download-${name}" :
        command  => "wget --no-check-certificate ${base_url}/${plugin}",
        cwd      => $plugin_dir,
        require  => File[$plugin_dir],
        path     => ['/usr/bin', '/usr/sbin',],
        user     => 'jenkins',
        unless   => "test -f ${plugin_dir}/${name}.?pi",
    #    OpenStack modification: don't auto-restart jenkins so we can control
    #    outage timing better.
        notify   => Service['jenkins'],
      }
    } elsif ($provider == download)
    {
      if ($download_md5 != undef)
      {
        downloader { $download_url:
          ensure   => present,
          path     => "${plugin_dir}/${plugin}",
          md5      => $download_md5,
          owner    => $jenkins_user,
          group    => $jenkins_group,
          mode     => 644,
          replace  => true,
          provider => url,
          require  => File[$plugin_dir],
          notify   => Service['jenkins'],
        }
      }else
      {
        downloader { $download_url:
          ensure   => present,
          path     => "${plugin_dir}/${plugin}",
          owner    => $jenkins_user,
          group    => $jenkins_group,
          mode     => 644,
          replace  => true,
          provider => url,
          require  => File[$plugin_dir],
          notify   => Service['jenkins'],
        }
      }
    } else
    {
      fail("provider ${provider} not supported, choose another provider like jenkins or download.")
    }
  } elsif ( $ensure == absent )
  {
    file { "${plugin_dir}/${plugin}":
      ensure => absent,
    }
  } else {
    fail(" ensure , ${ensure}, is not supported.")
  }
}
