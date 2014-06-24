# == Class: ::hiera::data
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
# setup hiera data from runtime_project

class runtime_project::hiera_setup (
) {

#  if (! defined(File['/etc/puppet/hiera.yaml']))
#  {
#    file { '/etc/puppet/hiera.yaml':
#      ensure  => present,
#      owner   => 'root',
#      group   => 'root',
#      mode    => '0555',
#      source  => 'puppet:///modules/hiera/hiera/hiera.yaml',
#      replace => true,
#    }
#  }

  if (! defined(File['/etc/puppet/hieradata/Debian/layouts']))
  {
    file { '/etc/puppet/hieradata/Debian/layouts':
      ensure  => 'directory',
      source  => 'puppet:///modules/runtime_project/hiera/layouts',
      recurse => true,
      owner   => 'root',
      group   =>'root',
      mode    => '0555',
      replace => true
    }
  }
}
