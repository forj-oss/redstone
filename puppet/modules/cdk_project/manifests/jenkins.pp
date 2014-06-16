# == Class: jenkins::master
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
#
class cdk_project::jenkins (
  $vhost_name                 = hiera('cdk_project::jenkins::vhost_name'                ,$::fqdn),
  $jenkins_jobs_password      = hiera('cdk_project::jenkins::jenkins_jobs_password'     ,''),
  $jenkins_jobs_username      = hiera('cdk_project::jenkins::jenkins_jobs_username'     ,'gerrig'),
  $manage_jenkins_jobs        = hiera('cdk_project::jenkins::manage_jenkins_jobs'       ,true),
  $ssl_cert_file              = hiera('cdk_project::jenkins::ssl_cert_file'             ,''),
  $ssl_key_file               = hiera('cdk_project::jenkins::ssl_key_file'              ,''),
  $ssl_chain_file             = hiera('cdk_project::jenkins::ssl_chain_file'            ,''),
  $ssl_cert_file_contents     = hiera('cdk_project::jenkins::ssl_cert_file_contents'    ,''),
  $ssl_key_file_contents      = hiera('cdk_project::jenkins::ssl_key_file_contents'     ,''),
  $ssl_chain_file_contents    = hiera('cdk_project::jenkins::ssl_chain_file_contents'   ,''),
  $jenkins_private_key        = hiera('cdk_project::jenkins::jenkins_private_key'       ,''),
  $ca_certs_db                = hiera('cdk_project::jenkins::ca_certs_db'               ,'/opt/config/cacerts'),
  $gerrit_url                 = hiera('cdk_project::jenkins::gerrit_url'                ,''),
  $gerrit_user                = hiera('cdk_project::jenkins::gerrit_user'               ,'jenkins'),
  $gerrit_port                = hiera('cdk_project::jenkins::gerrit_port'               ,29418),
  $install_fortify            = hiera('cdk_project::jenkins::install_fortify'           ,false),
  $jenkins_solo               = hiera('cdk_project::jenkins::jenkins_solo'              ,false),
  $zmq_event_receivers        = hiera('cdk_project::jenkins::zmq_event_receivers'       ,[]),
  $sysadmins                  = hiera('cdk_project::jenkins::sysadmins'                 ,[]),
  $job_builder_configs        = hiera('cdk_project::jenkins::job_builder_configs'       ,[]),
  $openidssourl               = hiera('cdk_project::jenkins::openidssourl'              ,'https://login.launchpad.net/+openid') # TODO: fix https://www.google.com/accounts/o8/id
) {

  if $gerrit_url == ''
  {
    $gerrit_server = read_json('gerrit','tool_url',$::json_config_location,true)
  }
  else
  {
    $gerrit_server = $gerrit_url
  }

  if $jenkins_private_key == ''
  {
    $jenkins_ssh_private_key = cacerts_getkey(join([$ca_certs_db , '/ssh_keys/jenkins']))
  }
  else
  {
    $jenkins_ssh_private_key = $jenkins_private_key
  }

  if ( $jenkins_ssh_private_key != '' )  and ( $gerrit_server != '') {

    stackato_cli{'my-stackato-cli':
      }

    if $install_fortify == true {
        fortify_cli{'my-fortify-cli':
        }
    }

    if $ssl_cert_file_contents == '' {
    $ssl_cert_file_data = cacerts_getkey(join([$ca_certs_db ,
                                          "/ca2013/certs/${::fqdn}.crt"]))
    } else {
      $ssl_cert_file_data = $ssl_cert_file_contents
    }
    if $ssl_key_file_contents == '' {
      $ssl_key_file_data = cacerts_getkey(join([$ca_certs_db , "/ca2013/certs/${::fqdn}.key"]))
    } else {
      $ssl_key_file_data = $ssl_key_file_contents
    }

    if $ssl_chain_file_contents == '' {
      $ssl_chain_file_data = cacerts_getkey(join([$ca_certs_db ,
                                          '/ca2013/chain.crt']))
    } else {
      $ssl_chain_file_data = $ssl_chain_file_contents
    }

    ::sysadmin_config::swap { '512':
    } ->
    class {'jenkins::jenkinsuser':
    } ->
    class { 'jenkins_config::master':
      vhost_name                      => $vhost_name,
      serveradmin                     => "webmaster@${::domain}",
      logo                            => 'openstack.png',
      ssl_cert_file                   => $ssl_cert_file,
      ssl_key_file                    => $ssl_key_file,
      ssl_chain_file                  => $ssl_chain_file,
      ssl_cert_file_contents          => $ssl_cert_file_data,
      ssl_key_file_contents           => $ssl_key_file_data,
      ssl_chain_file_contents         => $ssl_chain_file_data,
      jenkins_ssh_private_key         => $jenkins_ssh_private_key,
      jenkins_ssh_public_key          => cacerts_getkey(join([$ca_certs_db , '/ssh_keys/jenkins.pub'])),
    }
    if( $jenkins_solo == true )
    {
      class { 'jenkins_config::slave':
        ssh_key      => '',
        sudo         => false,
        bare         => false,
        user         => true,
        python3      => false,
        include_pypy => false,
        do_fortify   => $install_fortify,
        require      => Class['jenkins_config::master'],
      }
    }
    jenkins_config::plugin { 'ansicolor':
      version => '0.3.1',
    }
    jenkins_config::plugin { 'bazaar':
      version => '1.20',
    }
    jenkins_config::plugin { 'build-timeout':
      version => '1.10',
    }
    jenkins_config::plugin { 'copyartifact':
      version => '1.22',
    }
    jenkins_config::plugin { 'dashboard-view':
      version => '2.3',
    }
    jenkins_config::plugin { 'envinject':
      version => '1.70',
    }
    jenkins_config::plugin { 'gearman-plugin':
      version => '0.0.3',
    }
    jenkins_config::plugin { 'git':
      version => '1.1.23',
    }
    jenkins_config::plugin { 'github-api':
      version => '1.33',
    }
    jenkins_config::plugin { 'github':
      version => '1.4',
    }
    jenkins_config::plugin { 'greenballs':
      version => '1.12',
    }
    jenkins_config::plugin { 'htmlpublisher':
      version => '1.0',
    }
    jenkins_config::plugin { 'extended-read-permission':
      version => '1.0',
    }
    jenkins_config::plugin { 'postbuild-task':
      version => '1.8',
    }
  #  TODO(clarkb): release
  #  jenkins_config::plugin { 'zmq-event-publisher':
  #    version => '1.0',
  #  }
    jenkins_config::plugin { 'jclouds-jenkins':
      version => '2.3.1',
    }
  #  TODO(jeblair): release
  #  jenkins_config::plugin { 'scp':
  #    version => '1.9',
  #  }
    jenkins_config::plugin { 'violations':
      version => '0.7.11',
    }
    jenkins_config::plugin { 'jobConfigHistory':
      version => '1.13',
    }
    jenkins_config::plugin { 'monitoring':
      version => '1.40.0',
    }
    jenkins_config::plugin { 'nodelabelparameter':
      version => '1.2.1',
    }
    jenkins_config::plugin { 'notification':
      version => '1.4',
    }
    jenkins_config::plugin { 'openid':
      version => '1.5',
    }
    jenkins_config::plugin { 'parameterized-trigger':
      version => '2.15',
    }
    jenkins_config::plugin { 'publish-over-ftp':
      version => '1.7',
    }
    jenkins_config::plugin { 'rebuild':
      version => '1.14',
    }
    jenkins_config::plugin { 'simple-theme-plugin':
      version => '0.2',
    }
    jenkins_config::plugin { 'timestamper':
      version => '1.3.1',
    }
    jenkins_config::plugin { 'token-macro':
      version => '1.5.1',
    }
    jenkins_config::plugin { 'url-change-trigger':
      version => '1.2',
    }
    jenkins_config::plugin { 'urltrigger':
      version => '0.24',
    }
    file { '/var/lib/jenkins/hudson.plugins.gearman.GearmanPluginConfig.xml':
      ensure      => present,
      owner       => 'jenkins',
      group       => 'nogroup',
      mode        => '0644',
      source      => 'puppet:///modules/runtime_project/jenkins/hudson.plugins.gearman.GearmanPluginConfig.xml',
      require     => Class['jenkins_config::master'],
    }
    file { '/var/lib/jenkins/hudson.plugins.git.GitSCM.xml':
      ensure      => present,
      owner       => 'jenkins',
      group       => 'nogroup',
      mode        => '0644',
      source      => 'puppet:///modules/runtime_project/jenkins/hudson.plugins.git.GitSCM.xml',
      require     => Class['jenkins_config::master'],
    }
    file { '/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml':
      ensure      => present,
      owner       => 'jenkins',
      group       => 'nogroup',
      mode        => '0644',
      content     => template('runtime_project/jenkins/jenkins.model.JenkinsLocationConfiguration.xml.erb'),
      require     => Class['jenkins_config::master'],
    }
    file { '/etc/default/jenkins':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/cdk_project/jenkins/jenkins.default',
    }
    # requires $openidssourl
    file { '/var/lib/jenkins/config.xml':
      ensure      => present,
      owner       => 'jenkins',
      group       => 'nogroup',
      mode        => '0644',
      content     => template('runtime_project/jenkins/config.xml.erb'),
      require     => Class['jenkins_config::master'],
      replace     => false,
    }
    service {'jenkins':
        ensure  => running,
        enable  => true,
        require => [
          File['/etc/default/jenkins'],
          Class['jenkins_config::master'],
          File['/var/lib/jenkins/config.xml'],
        ],
    }
    exec { 'Create jenkins_jobs_username account and get the apiToken':
      command     => "curl https://${vhost_name}/user/${jenkins_jobs_username}/configure --insecure | grep apiToken | awk -F\'apiToken\\\" value=\' \'{print \$2}\' | awk -F\'\"\' \'{print \$2}\' >> /tmp/jenkins.tok",
      path        => '/bin:/usr/bin:/usr/local/bin',
      onlyif      => 'test ! -s /tmp/jenkins.tok',
      logoutput   => true,
      require     => Service['jenkins'],
    }
    if $manage_jenkins_jobs == true and $::jenkins_user_token != '' {
      class { '::jenkins::job_builder':
        url      => "https://${vhost_name}/",
        username => $jenkins_jobs_username,
        password => inline_template("<% if scope.lookupvar('jenkins_jobs_password') == '' %>${::jenkins_user_token}<% else %><%= scope.lookupvar('jenkins_jobs_password') %><% end %>"),
        require  => [
          Exec['Create jenkins_jobs_username account and get the apiToken'],
          Service['jenkins'],
        ],
      }
      file { '/etc/jenkins_jobs/config':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        recurse => true,
        purge   => true,
        force   => true,
        source  =>
          'puppet:///modules/runtime_project/jenkins_job_builder/config',
        notify  => Exec['jenkins_jobs_update'],
      } ->
      jenkins_config::copy_job_templates{ $job_builder_configs:
        require => File['/etc/jenkins_jobs/config'],
      } ->
      exec { 'jenkins_jobs_create':
        command     => 'jenkins-jobs --ignore-cache update /etc/jenkins_jobs/config',
        path        => '/bin:/usr/bin:/usr/local/bin',
        require     => [
          Service['jenkins'],
          Class['::jenkins::job_builder'],
        ],
        logoutput   => true,
      }->
      exec {'remove admin permissions for anonymous users':
        command       => 'sed -i.bak \'/hudson.model.Hudson.Administer:anonymous/d\' /var/lib/jenkins/config.xml | service jenkins restart',
        path          => '/bin:/usr/bin:/usr/local/bin',
        onlyif        => [
                          'grep \'hudson.model.Hudson.Administer:anonymous\' /var/lib/jenkins/config.xml',
                          'test -s /tmp/jenkins.tok'
                        ]
      } ->
      class { 'jenkins_config::createfirstaccount':
      }
    }
  }
}
