# == compiler_tools::install::gittools
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
class compiler_tools::install::gittools (
  $install_opt = false,  # do pip3 install??
)
{
  include pip::python2
  include compiler_tools::params::gittools
  if ($install_opt == false)
  {
    package_install{$::compiler_tools::params::gittools::packages:
      ensure_option    => $::compiler_tools::params::gittools::ensure_option,
      package_requires => [Class[pip::python2]],
      package_provider => pip2,
    }
  }
  else
  {
    if ($::lsbdistcodename == 'precise') {
      include apt
      if ! defined(Apt::Ppa['ppa:zulcss/py3k']) {
        apt::ppa { 'ppa:zulcss/py3k':
          before => Class[pip::python3],
        }
      }
    }
    include pip::python3
    package_install{$::compiler_tools::params::gittools::packages:
      ensure_option    => $::compiler_tools::params::gittools::ensure_option,
      package_requires => [Class[pip::python3]],
      package_provider => pip3,
    }
  }

  package { 'python-subunit':
    ensure   => absent,
    provider => pip2,
    require  => Class[pip::python2],
  }

  package { 'git-review':
    ensure   => '1.17',
    provider => pip2,
    require  => Class[pip::python2],
  }
}
