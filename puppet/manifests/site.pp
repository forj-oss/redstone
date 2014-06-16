# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# This code supports to migrate maestro to use the new maestro repository.
# Simply call puppet agent -t on Maestro to migrate it to use the new repository.

node /^maestro.*/ {

  exec{ 'Maestro repository clone':
    command => 'git clone review:forj-oss/maestro',
    cwd     => '/opt/config/production/git',
    path    => '/usr/bin:/bin',
    onlyif  => 'test ! -d /opt/config/production/git/maestro/.git',
    user    => 'root',
  } ->
  exec{ 'set crlf to false':
    command => '/usr/bin/git config core.autocrlf false',
    path    => '/usr/bin:/bin',
    cwd     => '/opt/config/production/git/maestro',
    user    => 'root',
  } ->
  exec{ 'chown to puppet:puppet':
    command => 'chown -R puppet:puppet /opt/config/production/git/maestro',
    path    => '/usr/bin:/bin',
    user    => 'root',
  } ->
  file{ '/opt/config/production/puppet':
    ensure => 'link',
    target => '/opt/config/production/git/maestro/puppet/',
  }

}
