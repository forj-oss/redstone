# == gerrit_config::firstopenidadmin
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
# When the first user logs on with an ldap account, This script
# will set them up as the admin user, to define the runtime state
# of the system.
#
#
class gerrit_config::firstldapadmin (
  $environment = $settings::environment,
  $debug_flag = false,
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
      fail("Unsupported osfamily: ${::osfamily}
            The 'jeepyb' module only supports osfamily Debian or RedHat.")
    }
  }
  if ! defined(Package[$package_yaml]) {
    package { $package_yaml:
      ensure => present,
    }
  }

  $gerrit_sql_file = '/tmp/gerrit_firstldap.sql.yaml'
  # the sql check here is same comments as whats in gerrit_firstldap.sql.yaml
  # we are just looking for if this account already has a record or not.
  # if not, then we run the insert script
  $sql_check = "select axt.account_id, axt.group_id
           from account_group_members agm
                          right outer join
           (
           select account_id, ag.group_id as group_id
               from account_external_ids axt
               inner join account_groups ag on ag.name=\\\"'Administrators'\\\"
               where external_id like \\\"'gerrit:%@%'\\\"
                 and NOT external_id like \\\"'username%'\\\"
                 and NOT external_id like \\\"'mailto:%'\\\"
                 order by account_id LIMIT 1
            ) axt
              on axt.account_id = agm.account_id
              and axt.group_id = agm.group_id
              where agm.account_id IS NULL
                    and agm.group_id is NULL;"
  $run_sql_config_opt  = "--sql_config_file ${gerrit_sql_file}"
  $lib_path = "/opt/config/${environment}/lib"
# sudo pip install pyyaml
  $src_yamlerb = 'gerrit_config/gsql/gerrit_firstldap.sql.yaml.erb'
  file { $gerrit_sql_file:
        ensure  => present,
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0555',
        content => template($src_yamlerb),
        replace => true,
        require => Package[$package_yaml],
      }
  # run sql
  exec { 'run firstldapadmin':
            path    => ['/bin', '/usr/bin'],
            command => "python ${lib_path}/gerrit_runsql.py ${debug_opts} ${run_sql_config_opt} --logfile /tmp/gerrit_firstldapadmin.log --loggername firstldapadmin",
            onlyif  => "test \$(${gerrit_config::params::gerrit_ssh} gerrit gsql --format JSON -c \"'${sql_check}'\"|grep 'columns' | wc -l) -gt 0",
            notify  => Service['gerrit'],
            require => [ File[$gerrit_sql_file],
                        File["${lib_path}/gerrit_runsql.py"]
            ],
        }
}
