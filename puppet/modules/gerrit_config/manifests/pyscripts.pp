# == gerrit_config::pyscripts
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
# Install scripts on the target machine if they are missing
#
#

class gerrit_config::pyscripts (
    $environment = $settings::environment,
)
{

# if the accounts 0 id already exist, then we're done.  can't continue
  notify{'setup python scripts for gerrit_config':}
# if the accounts 0 id does not exist, then create it and take it for $gerrit_id

  # create missing folder /opt/config/$environment/lib

  if ! defined(File["/opt/config/${environment}/lib"])
  {
    file { "/opt/config/${environment}/lib":
        ensure  => directory,
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0755',
        recurse => true,
        require => File["/opt/config/${environment}"],
    }
  }

  if ! defined(File["/opt/config/${environment}"])
  {
    file { "/opt/config/${environment}":
        ensure  => directory,
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0755',
        recurse => true,
        require => File['/opt/config'],
    }
  }

  if ! defined(File['/opt/config'])
  {
    file { '/opt/config':
        ensure  => directory,
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0755',
        recurse => true,
    }
  }

  file { "/opt/config/${environment}/lib/createfirstaccount.py":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0555',
      source  => 'puppet:///modules/gerrit_config/scripts/createfirstaccount.py',
      replace => true,
      require => [
                  File["/opt/config/${environment}/lib/Colorer.py"],
                  File["/opt/config/${environment}/lib/gerrit_common.py"],
                  File["/opt/config/${environment}/lib/gen_known_hosts.py"],
      ],
  }

  file { "/opt/config/${environment}/lib/gen_known_hosts.py":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0555',
      source  => 'puppet:///modules/gerrit_config/scripts/gen_known_hosts.py',
      replace => true,
      require => File["/opt/config/${environment}/lib"],
  }

  file { "/opt/config/${environment}/lib/gerrit_common.py":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0555',
      source  => 'puppet:///modules/gerrit_config/scripts/gerrit_common.py',
      replace => true,
      require => File["/opt/config/${environment}/lib"],
  }

  file { "/opt/config/${environment}/lib/gerrit_runsql.py":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0555',
      source  => 'puppet:///modules/gerrit_config/scripts/gerrit_runsql.py',
      replace => true,
      require => File["/opt/config/${environment}/lib"],
  }

  file { "/opt/config/${environment}/lib/Colorer.py":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0555',
      source  => 'puppet:///modules/gerrit_config/scripts/Colorer.py',
      replace => true,
      require => File["/opt/config/${environment}/lib"],
  }
}