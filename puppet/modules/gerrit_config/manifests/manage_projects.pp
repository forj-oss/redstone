# == gerrit_config::manage_projects
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
# Manage the gerrit projects.
#
#
class gerrit_config::manage_projects (
  $environment     = $settings::environment,
  $debug_flag      = false,
  $project_file    = UNDEF,
  $runtime_module  = UNDEF,
  $local_git_dir   = UNDEF,
  $script_user     = UNDEF,
  $script_key_file = UNDEF,
  $jeepyb_version  = hiera('jeepyb_config::jeepyb_version',undef),
)
{
  include pip::python2
  include gerrit_config::params


  if ($jeepyb_version != undef)
  {
    if !defined(Class['jeepyb_config'])
    {
      class { 'jeepyb_config':
        jeepyb_version => $jeepyb_version,
      }
    }
  }
  else
  {
    include jeepyb_config
  }
# we should only start managing projects if we have at least 1 real
# administrative user
  $sql_check = "select account_id, ag.group_id as group_id
                from account_external_ids axt
               inner join account_groups ag on ag.name=\\\"'Administrators'\\\"
                where NOT external_id like \\\"'gerrit%'\\\"
                  and NOT external_id like \\\"'username%'\\\"
                  and NOT external_id like \\\"'mailto:%'\\\"
                  order by account_id LIMIT 1;"

  $manage_t = "test \$(${gerrit_config::params::gerrit_ssh} gerrit gsql --format JSON -c \"'${sql_check}'\"|grep \'columns\' | wc -l) -gt 0"
  $prj_yaml = '/home/gerrit2/projects.yaml'

# we only want to preset the file to only put it in place
# if we need to exec the file
  file { "${prj_yaml}.preset":
    ensure  => present,
    owner   => 'gerrit2',
    group   => 'gerrit2',
    mode    => '0444',
    content => template("${runtime_module}/gerrit/config/${environment}/${project_file}"),
    replace => true,
  } ->

  file { '/home/gerrit2/acls':
    ensure  => directory,
    owner   => 'gerrit2',
    group   => 'gerrit2',
    mode    => '0744',
    recurse => true,
    replace => true,
    source  => "puppet:///modules/${runtime_module}/gerrit/acls/${environment}",
  }

  $md5_t1 = "md5sum ${prj_yaml} |awk '{print \$1}'"
  $md5_t2 = "md5sum ${prj_yaml}.preset | awk '{print \$1}'"
  exec { 'move /home/gerrit2/projects.yaml.preset':
        path    => [ '/bin/', '/sbin/' , '/usr/bin/',
                      '/usr/sbin/' , '/usr/local/bin/'],
        command => "cp ${prj_yaml}.preset ${prj_yaml}",
        onlyif  => [
          $manage_t, # only run if the account exist, value returns 1
          "test -f ${prj_yaml}.preset",
          "test ! \"\$(${md5_t1})\" = \"\$(${md5_t2})\"",
        ],
        require => File['/home/gerrit2/acls'],
  }

  # only run if the account exist
  exec { 'manage_projects':
    path        => [  '/bin/', '/sbin/' , '/usr/bin/',
                      '/usr/sbin/' , '/usr/local/bin/'],
    command     => '/usr/local/bin/manage-projects -v > /tmp/manage_projects.log 2<&1',
    timeout     => 900, # 15 minutes
    subscribe   => [
        Exec['move /home/gerrit2/projects.yaml.preset'],
        File['/home/gerrit2/acls'],
      ],
    refreshonly => true,
    onlyif      => $manage_t,
    require     => [
        Exec['move /home/gerrit2/projects.yaml.preset'],
        File['/home/gerrit2/acls'],
        Class['jeepyb_config'],
      ],
  }
}