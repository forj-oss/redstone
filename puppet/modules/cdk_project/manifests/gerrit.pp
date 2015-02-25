# == Class: cdk_project::gerrit
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
# A wrapper class around the main gerrit class that sets gerrit
# up for launchpad single sign on and bug/blueprint links


class cdk_project::gerrit (
  $vhost_name_def                   = hiera('cdk_project::gerrit::vhost_name'                       ,$::fqdn),
  $ip_vhost_name                    = hiera('cdk_project::gerrit::ip_vhost_name'                    ,$::fqdn),
  $canonicalweburl                  = hiera('cdk_project::gerrit::canonicalweburl'                  ,"https://${::fqdn}/"),
  $serveradmin                      = hiera('cdk_project::gerrit::serveradmin'                      ,"webmaster@${::domain}"),
  $ssh_host_key                     = hiera('cdk_project::gerrit::ssh_host_key'                     ,''),
  #TODO : figure out if we should keep this or not. same as $script_key_file
  $ssh_project_key                  = hiera('cdk_project::gerrit::ssh_project_key'                  ,''),
  $ssl_cert_file                    = hiera('cdk_project::gerrit::ssl_cert_file'                    ,''),
  $ssl_key_file                     = hiera('cdk_project::gerrit::ssl_key_file'                     ,''),
  $ssl_chain_file                   = hiera('cdk_project::gerrit::ssl_chain_file'                   ,''),
  $ssl_cert_file_contents           = hiera('cdk_project::gerrit::ssl_cert_file_contents'           ,''),
  $ssl_key_file_contents            = hiera('cdk_project::gerrit::ssl_key_file_contents'            ,''),
  $ssl_chain_file_contents          = hiera('cdk_project::gerrit::ssl_chain_file_contents'          ,''),
  # if empty puppet will not create file
  $ssh_dsa_key_contents             = hiera('cdk_project::gerrit::ssh_dsa_key_contents'             ,''),
  # if empty puppet will not create file
  $ssh_dsa_pubkey_contents          = hiera('cdk_project::gerrit::ssh_dsa_pubkey_contents'          ,''),
  # If left empty puppet will not create file.
  $ssh_rsa_key_contents             = hiera('cdk_project::gerrit::ssh_rsa_key_contents'             ,''),
  # If left empty puppet will not create file.
  $ssh_rsa_pubkey_contents          = hiera('cdk_project::gerrit::ssh_rsa_pubkey_contents'          ,''),
  # If left empty puppet will not create file.
  $ssh_project_rsa_key_contents     = hiera('cdk_project::gerrit::ssh_project_rsa_key_contents'     ,''),
  # If left empty will not create file.
  $ssh_project_rsa_pubkey_contents  = hiera('cdk_project::gerrit::ssh_project_rsa_pubkey_contents'  ,''),
  # If left empty will not create file.
  $email                            = hiera('cdk_project::gerrit::email'                            ,''),
  $database_poollimit               = hiera('cdk_project::gerrit::database_poollimit'               ,''),
  $container_heaplimit_def          = hiera('cdk_project::gerrit::container_heaplimit'              ,''),
  $core_packedgitopenfiles          = hiera('cdk_project::gerrit::core_packedgitopenfiles'          ,''),
  $core_packedgitlimit              = hiera('cdk_project::gerrit::core_packedgitlimit'              ,''),
  $core_packedgitwindowsize         = hiera('cdk_project::gerrit::core_packedgitwindowsize'         ,''),
  $sshd_threads                     = hiera('cdk_project::gerrit::sshd_threads'                     ,''),
  $httpd_acceptorthreads            = hiera('cdk_project::gerrit::httpd_acceptorthreads'            ,''),
  $httpd_minthreads                 = hiera('cdk_project::gerrit::httpd_minthreads'                 ,''),
  $httpd_maxthreads                 = hiera('cdk_project::gerrit::httpd_maxthreads'                 ,''),
  $httpd_maxwait                    = hiera('cdk_project::gerrit::httpd_maxwait'                    ,''),
  $war                              = hiera('cdk_project::gerrit::war'                              ,''),
  $contactstore                     = hiera('cdk_project::gerrit::contactstore'                     ,false),
  $contactstore_appsec              = hiera('cdk_project::gerrit::contactstore_appsec'              ,''),
  $contactstore_pubkey              = hiera('cdk_project::gerrit::contactstore_pubkey'              ,''),
  $contactstore_url                 = hiera('cdk_project::gerrit::contactstore_url'                 ,''),
  $script_user                      = hiera('cdk_project::gerrit::script_user'                      ,'update'),
  $script_key_file                  = hiera('cdk_project::gerrit::script_key_file'                  ,'/home/gerrit2/.ssh/id_rsa'),
  $script_logging_conf              = hiera('cdk_project::gerrit::script_logging_conf'              ,'/home/gerrit2/.sync_logging.conf'),
  $projects_file                    = hiera('cdk_project::gerrit::projects_file'                    ,'UNDEF'),
  $projects_config                  = hiera('cdk_project::gerrit::projects_config'                  ,'UNDEF'),
  $github_username                  = hiera('cdk_project::gerrit::github_username'                  ,''),
  $github_oauth_token               = hiera('cdk_project::gerrit::github_oauth_token'               ,''),
  $github_project_username          = hiera('cdk_project::gerrit::github_project_username'          ,''),
  $github_project_password          = hiera('cdk_project::gerrit::github_project_password'          ,''),
  $mysql_password                   = hiera('cdk_project::gerrit::mysql_password'                   ,''),
  $mysql_root_password              = hiera('cdk_project::gerrit::mysql_root_password'              ,''),
  $trivial_rebase_role_id           = hiera('cdk_project::gerrit::trivial_rebase_role_id'           ,''),
  $email_private_key                = hiera('cdk_project::gerrit::email_private_key'                ,''),
  $local_git_dir                    = hiera('cdk_project::gerrit::local_git_dir'                    ,'/var/lib/git'),
  $jeepyb_cache_dir                 = hiera('cdk_project::gerrit::jeepyb_cache_dir'                 ,'/opt/lib/jeepyb'),
  # OpenStack Individual Contributor License Agreement'
  $cla_description                  = hiera('cdk_project::gerrit::cla_description'                  ,'OpenStack ICLA'),
  $cla_file                         = hiera('cdk_project::gerrit::cla_file'                         ,'static/cla.html'),
  $cla_id                           = hiera('cdk_project::gerrit::cla_id'                           ,'2'),
  $cla_name                         = hiera('cdk_project::gerrit::cla_name'                         ,'ICLA'),
  $testmode                         = hiera('cdk_project::gerrit::testmode'                         ,false),
  $sysadmins                        = hiera('cdk_project::gerrit::sysadmins'                        ,[]),
  $swift_username                   = hiera('cdk_project::gerrit::swift_username'                   ,''),
  $swift_password                   = hiera('cdk_project::gerrit::swift_password'                   ,''),
  $ca_certs_db                      = hiera('cdk_project::gerrit::ca_certs_db'                      ,'/opt/config/cacerts'),
  $runtime_module                   = hiera('cdk_project::gerrit::runtime_module'                   ,'runtime_project'),
  $logo                             = hiera('cdk_project::gerrit::logo'                             ,'puppet:///modules/openstack_project/openstack.png'),
  $environment                      = hiera('cdk_project::gerrit::environment'                      ,$settings::environment),
  $override_vhost                   = hiera('cdk_project::gerrit::override_vhost'                   ,false),
  $demo_enabled                     = hiera('cdk_project::gerrit::demo_enabled'                     ,false),
  $buglinks_enabled                 = hiera('cdk_project::gerrit::buglinks_enabled'                 ,true),
  $replicate_local                  = hiera('cdk_project::gerrit::replicate_local'                  ,true),
  $replication_targets              = hiera('cdk_project::gerrit::replication'                      ,''),

  # gerrit authorization mehtod LDAP or OPENID
  $auth_type                 = hiera('cdk_project::gerrit::auth_type', 'OPENID_SSO'),
  $openidssourl                     = hiera('cdk_project::gerrit::openidssourl'                     ,'https://login.launchpad.net/+openid'), # TODO : fix 'https://www.google.com/accounts/o8/id?id='
  $ldap_server                      = hiera('cdk_project::gerrit::ldap_server', ''),
  $ldap_account_base                = hiera('cdk_project::gerrit::ldap_account_base', ''),
  $ldap_username                    = hiera('cdk_project::gerrit::ldap_username', ''),
  $ldap_password                    = hiera('cdk_project::gerrit::ldap_password', ''),
  $ldap_account_pattern             = hiera('cdk_project::gerrit::ldap_account_pattern', ''),
  $ldap_account_email_address       = hiera('cdk_project::gerrit::ldap_account_emailaddress', ''),
  $ldap_account_fullname            = hiera('cdk_project::gerrit::ldap_account_fullname', ''),
  $ldap_sslverify                   = hiera('cdk_project::gerrit::ldap_sslverify', false),
  $ldap_ssh_account_name            = hiera('cdk_project::gerrit::ldap_ssh_account_name', ''),

  $ldap_groupscope                  = hiera('cdk_project::gerrit::ldap_groupscope', ''),
  $ldap_groupbase                   = hiera('cdk_project::gerrit::ldap_groupbase', ''),
  $ldap_group_pattern               = hiera('cdk_project::gerrit::ldap_group_pattern', ''),
  $ldap_group_member_pattern        = hiera('cdk_project::gerrit::ldap_group_member_pattern', ''),

  $require_contact_information      = hiera('cdk_project::gerrit::require_contact_information'      ,'N'), #This parameter is to be able to commit to a project with a contribution agreement enabled.
  $custom_link                      = hiera_hash('cdk_project::gerrit::custom_link',undef),
  $first_account_classes            = hiera_array('cdk_projects::gerrit::first_account_classes',['gerrit_config::firstopenidadmin']), # if we enable ldap we can add admin classes here.
) {
  if $replication_targets == ''
  {
    $replication =  [
                      {
                        name                 => 'local',
                          url                  => 'file:///var/lib/git/',
                          replicationDelay     => '0',
                          threads              => '4',
                          mirror               => true,
                        }
                    ]
  }
  else
  {
    $replication = $replication_targets
  }

  if !defined(Class['pip::python2']) {
    include pip::python2
  }
  # this configuration should be differegerrit_confignt if we are registered with a dns
  # name.   For now we use ipv4, otherwise we would use fqdn

  # system config
  if str2bool($::vagrant_guest) == true {
    if $container_heaplimit_def == '' {
      $container_heaplimit = '112m'
    } else {
      $container_heaplimit = $container_heaplimit_def
    }
  } else {
    if $container_heaplimit_def == '' {
      $container_heaplimit = '900m'
    } else {
      $container_heaplimit = $container_heaplimit_def
    }
  }

  if $vhost_name_def == '' {
    $vhost_name = 'precise32'
  } else {
    $vhost_name = $vhost_name_def
  }

  Exec {path => [ '/bin/', '/sbin/','/usr/bin/','/usr/sbin/',
                  '/usr/local/bin/']}
  notify{"working on ${vhost_name}":}
  notify{"The server admin is :  ${serveradmin}":}

  # TODO we currently only support cdkdev.org domain, this needs to be enhanced.
  include ::cacerts
  # chained configuration to execute after gerrit is setup.
  # configure gerrit
  include gerrit_config::patch_gerrit_deploy

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

  # Setup MySQL
  class { 'gerrit::mysql':
    mysql_root_password => $mysql_root_password,
    database_name       => 'reviewdb',
    database_user       => 'gerrit2',
    database_password   => $mysql_password,
  } ->

  # lets setup jeepy
  # TODO: jeepy class jeepyb:openstackwatch was commented out, is this cool?
  #       and so removed to make puppet-lint happy

  class {'gerrit_config::setup':
          demo_enabled                => $demo_enabled,
          buglinks_enabled            => $buglinks_enabled,
          require_contact_information => $require_contact_information,
          first_account_classes       => $first_account_classes,
          require                     => Class['::gerrit_config'],
      }


  if ($custom_link != undef)
  {
    $custom_link_arr = [$custom_link]
  } else
  {
    $custom_link_arr = []
  }
  $comment_links_data1 = concat(
  [
    {
      name  => 'bugheader',
      match => '([Cc]loses|[Pp]artial|[Rr]elated)-[Bb]ug:\\s*#?(\\d+)',
      link  => 'https://launchpad.net/bugs/$2',
    },
    {
      name  => 'bug',
      match => '\\bbug:? #?(\\d+)',
      link  => 'https://launchpad.net/bugs/$1',
    },
    {
      name  => 'story',
      match => '\\bstory:? #?(\\d+)',
      link  => 'https://storyboard.openstack.org/#!/story/$1',
    },
    {
      name  => 'blueprint',
      match => '(\\b[Bb]lue[Pp]rint\\b|\\b[Bb][Pp]\\b)[ \\t#:]*([A-Za-z0-9\\-]+)',
      link  => 'https://blueprints.launchpad.net/openstack/?searchtext=$2',
    },
    {
      name  => 'testresult',
      match => '<li>([^ ]+) <a href=\"[^\"]+\" target=\"_blank\">([^<]+)</a> : ([^ ]+)([^<]*)</li>',
      html  => '<li class=\"comment_test\"><span class=\"comment_test_name\"><a href=\"$2\">$1</a></span> <span class=\"comment_test_result\"><span class=\"result_$3\">$3</span>$4</span></li>',
    },
    {
      name  => 'launchpadbug',
      match => '<a href=\"(https://bugs\\.launchpad\\.net/[a-zA-Z0-9\\-]+/\\+bug/(\\d+))[^\"]*\">[^<]+</a>',
      html  => '<a href=\"$1\">$1</a>'
    },
    {
      name  => 'changeid',
      match => '(I[0-9a-f]{8,40})',
      link  => '#q,$1,n,z',
    },
    {
      name  => 'gitsha',
      match => '(<p>|[\\s(])([0-9a-f]{40})(</p>|[\\s.,;:)])',
      html  => '$1<a href=\"#q,$2,n,z\">$2</a>$3',
    },
  ],
    $::gerrit_config::connect_bugs::commentlink
    )
  $comment_links_data = concat($comment_links_data1, $custom_link_arr)
  class { '::gerrit_config':
      vhost_name                      => $vhost_name,
      canonicalweburl                 => $canonicalweburl,
      # opinions
      enable_melody                   => true,
      melody_session                  => true,
      robots_txt_source               => "puppet:///modules/${runtime_module}/gerrit/robots.txt",
      # passthrough
      ssl_cert_file                   => $ssl_cert_file,
      ssl_key_file                    => $ssl_key_file,
      ssl_chain_file                  => $ssl_chain_file,
      ssl_cert_file_contents          => $ssl_cert_file_data,
      ssl_key_file_contents           => $ssl_key_file_data,
      ssl_chain_file_contents         => $ssl_chain_file_data,
      ssh_dsa_key_contents            => $ssh_dsa_key_contents,
      ssh_dsa_pubkey_contents         => $ssh_dsa_pubkey_contents,
      ssh_rsa_key_contents            => $ssh_rsa_key_contents,
      ssh_rsa_pubkey_contents         => $ssh_rsa_pubkey_contents,
      ssh_project_rsa_key_contents    => $ssh_project_rsa_key_contents,
      ssh_project_rsa_pubkey_contents => $ssh_project_rsa_pubkey_contents,
      email                           => $email,

      openidssourl                    => $openidssourl,
      gerrit_auth_type                => $auth_type,
      ldap_server                     => $ldap_server,
      ldap_account_base               => $ldap_account_base,
      ldap_username                   => $ldap_username,
      ldap_password                   => $ldap_password,
      ldap_account_pattern            => $ldap_account_pattern,
      ldap_account_email_address      => $ldap_account_email_address,
      ldap_sslverify                  => $ldap_sslverify,
      ldap_ssh_account_name           => $ldap_ssh_account_name,
      ldap_accountfullname            => $ldap_account_fullname,

      ldap_groupscope                 => $ldap_groupscope,
      ldap_groupbase                  => $ldap_groupbase,
      ldap_group_pattern              => $ldap_group_pattern,
      ldap_group_member_pattern       => $ldap_group_member_pattern,


      database_poollimit              => $database_poollimit,
      container_heaplimit             => $container_heaplimit,
      core_packedgitopenfiles         => $core_packedgitopenfiles,
      core_packedgitlimit             => $core_packedgitlimit,
      core_packedgitwindowsize        => $core_packedgitwindowsize,
      sshd_threads                    => $sshd_threads,
      httpd_acceptorthreads           => $httpd_acceptorthreads,
      httpd_minthreads                => $httpd_minthreads,
      httpd_maxthreads                => $httpd_maxthreads,
      httpd_maxwait                   => $httpd_maxwait,

      commentlinks                    => $comment_links_data,

      war                             => $war,
      contactstore                    => $contactstore,
      contactstore_appsec             => $contactstore_appsec,
      contactstore_pubkey             => $contactstore_pubkey,
      contactstore_url                => $contactstore_url,
      mysql_password                  => $mysql_password,
      email_private_key               => $email_private_key,
      replicate_local                 => $replicate_local,
      replication                     => $replication,
      testmode                        => $testmode,
  }

  if $override_vhost == true
  {
    $site_instance = '50'
    notice("implement ${ip_vhost_name} and remove /etc/apache2/sites-enabled/${site_instance}-${vhost_name}.conf")
    exec { "clean up /etc/apache2/sites-enabled/${site_instance}-${vhost_name}.conf":
            command => "rm -f /etc/apache2/sites-enabled/${site_instance}-${vhost_name}.conf" ,
            onlyif  => "test -f /etc/apache2/sites-enabled/${site_instance}-${vhost_name}.conf" ,
            require => Class['::gerrit_config'],
    } ->
    apache::vhost { "${vhost_name}-ipv4":
        port     => 443,
        docroot  => 'MEANINGLESS ARGUMENT',
        priority => $site_instance,
        template => 'cdk_project/gerrit.ipv4.vhost.erb',
        ssl      => true,
    }
  }

  # Remove the old cron
#  mysql_backup::backup { 'gerrit':
#    require => Class['::gerrit_config'],
#  }
  cron { 'gerrit-backup':
    ensure => 'absent'
  }

  if ($testmode == false) {
    class { 'gerrit_config::cron':
      script_user     => $script_user,
      script_key_file => $script_key_file,
      require         => Class['gerrit_config::createfirstaccount'],
    }

    if ($github_username != '')
    {
      class { 'github_config':
        username         => $github_username,
        project_username => $github_project_username,
        project_password => $github_project_password,
        oauth_token      => $github_oauth_token,
        require          => Class['::gerrit_config']
      }
    }
  }

  notice("installing files from module ${runtime_module}")

  file { '/home/gerrit2/review_site/static/echosign-cla.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => "puppet:///modules/${runtime_module}/gerrit/echosign-cla.html",
    replace => true,
    require => Class['::gerrit_config'],
  }

  file { '/home/gerrit2/review_site/static/cla.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => "puppet:///modules/${runtime_module}/gerrit/cla.html",
    replace => true,
    require => Class['::gerrit_config'],
  }

  file { '/home/gerrit2/review_site/static/usg-cla.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => "puppet:///modules/${runtime_module}/gerrit/usg-cla.html",
    replace => true,
    require => Class['::gerrit_config'],
  }

  file { '/home/gerrit2/review_site/static/system-cla.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => "puppet:///modules/${runtime_module}/gerrit/system-cla.html",
    replace => true,
    require => Class['::gerrit_config'],
  }

  file { '/home/gerrit2/review_site/static/title.png':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => $logo,
    replace => true,
    require => Class['::gerrit_config'],
    notify  => Exec['reload_gerrit_header'],
  }

  file { '/home/gerrit2/review_site/static/openstack-page-bkg.jpg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => "puppet:///modules/${runtime_module}/branding/openstack-page-bkg.jpg",
    require => Class['::gerrit_config'],
  }

  package { 'libjs-jquery':
    ensure => present,
  }

  file { '/home/gerrit2/review_site/static/jquery.min.js':
    ensure  => present,
    source  => '/usr/share/javascript/jquery/jquery.min.js',
    require => [Class['::gerrit_config'],
                Package['libjs-jquery']],
    notify  => Exec['reload_gerrit_header'],
  }

  file { '/home/gerrit2/review_site/static/hideci.js':
    ensure  => present,
    source  => "puppet:///modules/${runtime_module}/gerrit/hideci.js",
    require => Class['::gerrit_config'],
    notify  => Exec['reload_gerrit_header'],
  }

  file { '/home/gerrit2/review_site/etc/GerritSite.css':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => "puppet:///modules/${runtime_module}/gerrit/GerritSite.css",
    require => Class['::gerrit_config'],
  }

  file { '/home/gerrit2/review_site/etc/GerritSiteHeader.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => "puppet:///modules/${runtime_module}/gerrit/GerritSiteHeader.html",
    require => Class['::gerrit_config'],
  }

  file { '/home/gerrit2/review_site/etc/GerritSiteFooter.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => "puppet:///modules/${runtime_module}/gerrit/GerritSiteFooter.html",
    require => Class['::gerrit_config'],
  }

  exec { 'reload_gerrit_header':
    command     => 'touch /home/gerrit2/review_site/etc/GerritSiteHeader.html',
    path        => 'bin:/usr/bin',
    refreshonly => true,
  }

  cron { 'gerritsyncusers':
    ensure => absent,
  }

  cron { 'sync_launchpad_users':
    ensure => absent,
  }

  file { '/home/gerrit2/review_site/hooks/change-merged':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    source  => "puppet:///modules/${runtime_module}/gerrit/change-merged",
    replace => true,
    require => Class['::gerrit_config'],
  }

  file { '/home/gerrit2/review_site/hooks/patchset-created':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    content => template("${runtime_module}/gerrit/hooks/gerrit_patchset-created.erb"),
    replace => true,
    require => Class['::gerrit_config'],
  }

  if ($projects_file != 'UNDEF') {
    if ($replicate_local) {
      file { $local_git_dir:
        ensure  => directory,
        owner   => 'gerrit2',
        require => Class['::gerrit_config'],
      }
      cron { 'mirror_repack':
        user        => 'gerrit2',
        weekday     => '0',
        hour        => '4',
        minute      => '7',
        command     => 'find /var/lib/git/ -type d -name "*.git" -print -exec git --git-dir="{}" repack -afd \;',
        environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
        require     => Class['::gerrit_config'],
      }
    }

    class { 'gerrit_config::manage_projects':
          project_file    => $projects_file,
          project_config  => $projects_config,
          runtime_module  => $runtime_module,
          local_git_dir   => $local_git_dir,
          script_user     => $script_user,
          script_key_file => $script_key_file,
          require         => Class['gerrit_config::setup'],
    }
  }
}
