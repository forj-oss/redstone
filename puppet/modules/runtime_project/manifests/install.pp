# == Class: runtime_project::install
#
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
#
class runtime_project::install {
  include runtime_project::params
  runtime_project::clone{ $runtime_project::params::config_project:}
  ->
  runtime_project::config_files{ $runtime_project::params::config_project:}
  ->
  runtime_project::push{ $runtime_project::params::config_project:}
  ->
  runtime_project::pull{ $runtime_project::params::config_project:}

  # Setup the script for the new project creation from the UI.
  if ! defined(File['/var/lib/forj'])
  {
    file { '/var/lib/forj':
        ensure  => directory,
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0755',
        recurse => true,
    }
  }
  file { '/var/lib/forj/newproject.sh':
    ensure  => present,
    content => template('runtime_project/gerrit/newproject.sh.erb'),
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0755',
    require => File['/var/lib/forj'],
  }
}
