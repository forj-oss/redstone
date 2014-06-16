# == gerrit_config::gerrit_init
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
# Initialize gerrit with default configuration from gerrit_init.sql.yaml
#

class gerrit_config::gerrit_init (
  $environment = $settings::environment,
  $debug_flag = false,
  $require_contact_information = 'N',
)
{
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

  $gerrit_sql_file    = '/tmp/gerrit_init.sql.yaml'
  $sql_check          = 'SELECT * FROM accounts WHERE ACCOUNT_ID=0;'
  $lib_path           = "/opt/config/${environment}/lib"

# sudo pip install pyyaml
  file { $gerrit_sql_file:
        ensure  => present,
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0555',
        content => template('gerrit_config/gsql/gerrit_init.sql.yaml.erb'),
        replace => true,
        require => Package[$package_yaml],
      } ->
  exec { "run ${gerrit_sql_file}":
            path    => ['/bin', '/usr/bin'],
            command => "python ${lib_path}/gerrit_runsql.py ${debug_opts} --sql_config_file ${gerrit_sql_file} --logfile /tmp/gerrit_init.log  --loggername gerrit_init",
            require => File["${lib_path}/gerrit_runsql.py"],
            onlyif  => "test \$(${gerrit_config::params::gerrit_ssh} gerrit gsql --format JSON -c \"'${sql_check}'\"|grep 'columns' | wc -l) = 0",
        }
}