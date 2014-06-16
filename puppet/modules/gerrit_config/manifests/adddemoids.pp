# == gerrit_config::adddemoids
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
# When the first user logs on with an open-id account, This script
# will set them up as the admin user, to define the runtime state
# of the system.
#
#
class gerrit_config::adddemoids (
  $environment     = $settings::environment,
  $debug_flag      = false,
  $demo_group_name = 'tutorials-core',
  $enabled         = false,
)
{
  include gerrit_config::params
  include gerrit_config::pyscripts

  if($debug_flag)
  {
    $debug_opts = '--loglevel debug'
  }
  else
  {
    $debug_opts = ''
  }
  # A lot of things need yaml, be conservative requiring this package to avoid
  # conflicts with other modules.
  case $::osfamily {
    'Debian': {
      $package_yaml = 'python-yaml'
    }
    'RedHat': {
      $package_yaml = 'PyYAML'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'jeepyb' module only supports osfamily Debian or RedHat.")
    }
  }
  if ! defined(Package[$package_yaml]) {
    package { $package_yaml:
      ensure => present,
    }
  }

  $run_sql_log_opt = '--logfile /tmp/adddemoids.log --loggername adddemoids'
  $gerrit_sql_file = '/tmp/adddemoids.sql.yaml'
  #
  # this query will add any user that logs into gerrit into petclinic-core group
  # this way they can submit and approve changes.
  $sql_check = "select axt.account_id, axt.group_id
                 from account_group_members agm
                                right outer join
                 (
                 select account_id, ag.group_id as group_id
                        from account_external_ids axt
                          inner join account_groups ag on ag.name=\\\"'${demo_group_name}'\\\"
                        where NOT external_id like \\\"'gerrit%'\\\"
                          and NOT external_id like \\\"'username%'\\\"
                          and NOT external_id like \\\"'mailto:%'\\\"
                  ) axt
                    on axt.account_id = agm.account_id
                    and axt.group_id = agm.group_id
                    where agm.account_id IS NULL
                          and agm.group_id is NULL;"

  $run_sql_config_opt  = "--sql_config_file ${gerrit_sql_file}"
  $lib_path = "/opt/config/${environment}/lib"
# load sql to use
  if ($enabled == true)
  {
    file { $gerrit_sql_file:
        ensure  => present,
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0555',
        content => template('gerrit_config/gsql/adddemoids.sql.yaml.erb'),
        replace => true,
        require => Package[$package_yaml],
      } ->
    # run sql
    exec { 'run adddemoids':
              path        => ['/bin', '/usr/bin'],
              command     => "python ${lib_path}/gerrit_runsql.py ${debug_opts} ${run_sql_config_opt} ${run_sql_log_opt}",
              require     => File["${lib_path}/gerrit_runsql.py"],
              onlyif      => "test $(${gerrit_config::params::gerrit_ssh} gerrit gsql --format JSON -c \"'${sql_check}'\"|grep 'columns' | wc -l) -gt 0",
              notify      => Service['gerrit'],
          }
  }
  #
  # create demo user account as a demo-core user account so that we can test
  # gerrit
  # the account is created only if the group $demo_group_name exist.
  # TODO: create a parser function that can download the latest pub key from github
  #       this way if the pub key changes, we can always get the latest... otherwise
  #       let it default to this well known key for now.
  # the reference to .../miqui/pet-clinic/... has to be changed to .tutorials.
  # once we add the keys to the forjio github
  # see https://github.com/miqui/pet-clinic/blob/stackato/keys/README.md for more info
  # to download the private key, run :
  # wget -O ~/.ssh/demo_keys https://raw.github.com/miqui/pet-clinic/stackato/keys/demo_keys
  gerrit_config::createbatchaccount{'demouser':
        fullname            => 'Demo User',
        email_address       => 'demouser@localhost',
        group               => $demo_group_name,
        ssh_pub_key_content => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqNeRscG2zVEP9UAbM02++n8CsFaDnb0pkwE7zcmTB/4GTKgXsYZYKnr4LSVAiXXTUcPIgnuxiqy72HRYNs5FovNzBJrRJtzkiP7Ehkwjbxd85q6D1EGfF0C3dBJVKuvwzQ+qIb6quyvmF9GdHKSZ4CXQ2aaEKkvDPXmY30hS69ud1wEeadX4jjgbnlPsnkuns+wqmvntltM2ODbwBa/SbYVC2BsloLr8SM3p3hLhPWvGCCxb/3Q9//JKOxn5TzpmprkkuHGIj6fznGtjQAacqUr/LkWEihMJIjcFRfJUeU1EuH87xlzfO5u1hvabLXobcME0NT33YM+7oowG9L1FF demouser@localhost',
  }
}