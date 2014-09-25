# == Class: cdk_project::static
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
class cdk_project::status (
  $sysadmins                        = hiera('cdk_project::status::sysadmins'                           ,[]),
  $gerrit_host                      = hiera('cdk_project::status::gerrit_host'                         ,''),
  $gerrit_ssh_host_key              = hiera('cdk_project::status::gerrit_ssh_host_key'                 ,''),
  $reviewday_ssh_public_key         = hiera('cdk_project::status::reviewday_ssh_public_key'            ,''),
  $reviewday_ssh_private_key        = hiera('cdk_project::status::reviewday_ssh_private_key'           ,''),
  $releasestatus_ssh_public_key     = hiera('cdk_project::status::releasestatus_ssh_public_key'        ,''),
  $releasestatus_ssh_private_key    = hiera('cdk_project::status::releasestatus_ssh_private_key'       ,''),
  $recheck_ssh_public_key           = hiera('cdk_project::status::recheck_ssh_public_key'              ,''),
  $recheck_ssh_private_key          = hiera('cdk_project::status::recheck_ssh_private_key'             ,''),
  $recheck_bot_passwd               = hiera('cdk_project::status::recheck_bot_passwd'                  ,''),
  $recheck_bot_nick                 = hiera('cdk_project::status::recheck_bot_nick'                    ,''),
  $vhost_name                       = hiera('cdk_project::status::vhost_name'                          ,$::fqdn),
  $zuul_server                      = hiera('cdk_project::status::zuul_server'                         ,''),
  $graphite_url                     = hiera('cdk_project::status::graphite_url'                        ,"http://${::fqdn}:8081"),
  $static_url                       = hiera('cdk_project::status::static_url'                          ,"http://${::fqdn}:8080"),
  $logo                             = hiera('cdk_project::status::logo'                                ,'puppet:///modules/openstack_project/openstack.png'),
) {
  require maestro::node_vhost_lookup
  $maestro_url = join(['http://',read_json('puppet','tool_url',$::json_config_location,true)])
  if $zuul_server == ''
  {
    $zuul_url = read_json('zuul','tool_url',$::json_config_location,false)
  }
  else
  {
    $zuul_url = $zuul_server
  }

  if $zuul_url != '' and $zuul_url != '#'
  {
      #include openstack_project
      # class { 'jenkins_config::jenkinsuser':
        # ssh_key => "",
      # }

      include apache

      a2mod { 'rewrite':
        ensure => present,
      }
    #  a2mod { 'proxy':
    #    ensure => present,
    #  }
    #  a2mod { 'proxy_http':
    #    ensure => present,
    #  }
      file { '/srv/static':
        ensure => directory,
      }

      ###########################################################
      # Status - Index

      apache::vhost { "status-${vhost_name}":
        port       => 8080,
        priority   => '50',
        docroot    => '/srv/static/status',
        template   => 'cdk_project/status/status.ipv4.vhost.erb',
        require    => File['/srv/static/status'],
        servername => 'localhost',
      }

      file { '/srv/static/status':
        ensure => directory,
      }

      package { 'libjs-jquery':
        ensure => present,
      }

      package { 'yui-compressor':
        ensure => present,
      }

      file { '/srv/static/status/index.html':
        ensure  => present,
        #source  => 'puppet:///modules/openstack_project/status/index.html',
        content => template('runtime_project/status/index.html.erb'),
        require => File['/srv/static/status'],
      }

      file { '/srv/static/status/favicon.ico':
        ensure  => present,
        source  => 'puppet:///modules/openstack_project/status/favicon.ico',
        require => File['/srv/static/status'],
      }

      file { '/srv/static/status/title.png':
        ensure  => present,
        source  => $logo,
        require => File['/srv/static/status'],
      }

      file { '/srv/static/status/common.js':
        ensure  => present,
        #source  => 'puppet:///modules/openstack_project/status/common.js',
        content => template('runtime_project/status/common.js.erb'),
        require => File['/srv/static/status'],
      }

      file { '/srv/static/status/jquery.min.js':
        ensure  => link,
        target  => '/usr/share/javascript/jquery/jquery.min.js',
        require => [File['/srv/static/status'],
                    Package['libjs-jquery']],
      }

      vcsrepo { '/opt/jquery-visibility':
        ensure   => latest,
        provider => git,
        revision => 'master',
        source   => 'https://github.com/mathiasbynens/jquery-visibility.git',
      }

      exec { 'install_jquery-visibility' :
        command     => 'yui-compressor -o /srv/static/status/jquery-visibility.min.js /opt/jquery-visibility/jquery-visibility.js',
        path        => '/bin:/usr/bin',
        refreshonly => true,
        subscribe   => Vcsrepo['/opt/jquery-visibility'],
        require     => [File['/srv/static/status'],
                        Vcsrepo['/opt/jquery-visibility']],
      }

      vcsrepo { '/opt/jquery-graphite':
        ensure   => latest,
        provider => git,
        revision => 'master',
        source   => 'https://github.com/prestontimmons/graphitejs.git',
      }

      file { '/srv/static/status/jquery-graphite.js':
        ensure  => link,
        target  => '/opt/jquery-graphite/jquery.graphite.js',
        require => [File['/srv/static/status'],
                    Vcsrepo['/opt/jquery-graphite']],
      }
      vcsrepo { '/opt/flot':
        ensure   => latest,
        provider => git,
        revision => 'master',
        source   => 'https://github.com/flot/flot.git',
      }

      exec { 'install_flot' :
        command     => 'yui-compressor -o \'.js\$:.min.js\' /opt/flot/jquery.flot*.js; mv /opt/flot/jquery.flot*.min.js /srv/static/status',
        path        => '/bin:/usr/bin',
        refreshonly => true,
        subscribe   => Vcsrepo['/opt/flot'],
        require     => [File['/srv/static/status'],
                        Vcsrepo['/opt/flot']],
      }

      ###########################################################
      # Status - elastic-recheck

      group { 'recheck':
        ensure => 'present',
      }

      user { 'recheck':
        ensure  => present,
        home    => '/home/recheck',
        shell   => '/bin/bash',
        gid     => 'recheck',
        require => Group['recheck'],
      }

      file { '/home/recheck':
        ensure  => directory,
        mode    => '0700',
        owner   => 'recheck',
        group   => 'recheck',
        require => User['recheck'],
      }

      vcsrepo { '/opt/elastic-recheck':
        ensure   => latest,
        provider => git,
        revision => 'master',
        source   => 'https://git.openstack.org/openstack-infra/elastic-recheck',
      }

      include pip
      exec { 'install_elastic-recheck' :
        command     => 'python setup.py install',
        cwd         => '/opt/elastic-recheck',
        path        => '/bin:/usr/bin',
        refreshonly => true,
        subscribe   => Vcsrepo['/opt/elastic-recheck'],
        require     => Class['pip'],
      }

      file { '/srv/static/status/elastic-recheck':
        ensure  => directory,
        owner   => 'recheck',
        group   => 'recheck',
        require => User['recheck'],
      }

      file { '/srv/static/status/elastic-recheck/index.html':
        ensure  => present,
        #source  => 'puppet:///modules/openstack_project/elastic-recheck/elastic-recheck.html',
        content => template('cdk_project/status/elastic-recheck/elastic-recheck.html.erb'),
        require => File['/srv/static/status/elastic-recheck'],
      }

      file { '/srv/static/status/elastic-recheck/elastic-recheck.js':
        ensure  => present,
        #source  => 'puppet:///modules/openstack_project/elastic-recheck/elastic-recheck.js',
        content => template('cdk_project/status/elastic-recheck/elastic-recheck.js.erb'),
        require => File['/srv/static/status/elastic-recheck'],
      }

      cron { 'elastic-recheck':
        user        => 'recheck',
        minute      => '*/15',
        hour        => '*',
        command     => 'elastic-recheck-graph /opt/elastic-recheck/queries.yaml -o /srv/static/status/elastic-recheck/graph-new.json && mv /srv/static/status/elastic-recheck/graph-new.json /srv/static/status/elastic-recheck/graph.json',
        environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin',
        require     => [Vcsrepo['/opt/elastic-recheck'],
                        User['recheck']],
      }

      ###########################################################
      # Status - zuul

      file { '/srv/static/status/zuul':
        ensure => directory,
      }

      file { '/srv/static/status/zuul/index.html':
        ensure  => present,
        #source  => 'puppet:///modules/openstack_project/zuul/status.html',
        content => template('cdk_project/status/zuul/status.html.erb'),
        require => File['/srv/static/status/zuul'],
      }

      file { '/srv/static/status/zuul/status.js':
        ensure  => present,
        #source  => 'puppet:///modules/openstack_project/zuul/status.js',
        content => template('cdk_project/status/zuul/status.js.erb'),
        require => File['/srv/static/status/zuul'],
      }

      file { '/srv/static/status/zuul/green.png':
        ensure  => present,
        source  => 'puppet:///modules/openstack_project/zuul/green.png',
        require => File['/srv/static/status/zuul'],
      }

      file { '/srv/static/status/zuul/red.png':
        ensure  => present,
        source  => 'puppet:///modules/openstack_project/zuul/red.png',
        require => File['/srv/static/status/zuul'],
      }

      file { '/srv/static/status/zuul/black.png':
        ensure  => present,
        source  => 'puppet:///modules/openstack_project/zuul/black.png',
        require => File['/srv/static/status/zuul'],
      }

      file { '/srv/static/status/zuul/grey.png':
        ensure  => present,
        source  => 'puppet:///modules/openstack_project/zuul/grey.png',
        require => File['/srv/static/status/zuul'],
      }

      file { '/srv/static/status/zuul/line-angle.png':
        ensure  => present,
        source  => 'puppet:///modules/openstack_project/zuul/line-angle.png',
        require => File['/srv/static/status/zuul'],
      }

      file { '/srv/static/status/zuul/line-t.png':
        ensure  => present,
        source  => 'puppet:///modules/openstack_project/zuul/line-t.png',
        require => File['/srv/static/status/zuul'],
      }

      file { '/srv/static/status/zuul/line.png':
        ensure  => present,
        source  => 'puppet:///modules/openstack_project/zuul/line.png',
        require => File['/srv/static/status/zuul'],
      }

    #  ###########################################################
    #  # Status - reviewday
    #
    #  include reviewday
    #
    #  reviewday::site { 'reviewday':
    #    git_url                       => 'git://git.openstack.org/openstack-infra/reviewday',
    #    serveradmin                   => 'webmaster@openstack.org',
    #    httproot                      => '/srv/static/reviewday',
    #    gerrit_url                    => 'review.openstack.org',
    #    gerrit_port                   => '29418',
    #    gerrit_user                   => 'reviewday',
    #    reviewday_gerrit_ssh_key      => $gerrit_ssh_host_key,
    #    reviewday_rsa_pubkey_contents => $reviewday_ssh_public_key,
    #    reviewday_rsa_key_contents    => $reviewday_ssh_private_key,
    #  }
    #
    #  ###########################################################
    #  # Status - releasestatus
    #
    #  class { 'releasestatus':
    #    releasestatus_prvkey_contents => $releasestatus_ssh_private_key,
    #    releasestatus_pubkey_contents => $releasestatus_ssh_public_key,
    #    releasestatus_gerrit_ssh_key  => $gerrit_ssh_host_key,
    #  }
    #
    #  releasestatus::site { 'releasestatus':
    #    configfile => 'integrated.yaml',
    #    httproot   => '/srv/static/release',
    #  }
  }
}
