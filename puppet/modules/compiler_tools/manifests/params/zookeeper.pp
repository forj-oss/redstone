# == compiler_tools::params::zookeeper
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
class compiler_tools::params::zookeeper {
  case $::osfamily {
    'RedHat': {
      # For Tooz unit tests
      # FIXME: No zookeeper packages on RHEL
      $cgroups_package       = UNDEF
      if ($::operatingsystem == 'Fedora') {
        $zookeeper_package     = 'zookeeper'
        $cgroups_tools_package = 'libcgroup-tools'
        $cgconfig_require = [
          Package['cgroups'],
          Package['cgroups-tools'],
        ]
        $cgred_require = [
          Package['cgroups'],
          Package['cgroups-tools'],
        ]
      } else {
        $cgroups_tools_package = ''
        $cgconfig_require = Package['cgroups']
        $cgred_require = Package['cgroups']
      }
    }
    'Debian': {
      # For Tooz unit tests
      $zookeeper_package = 'zookeeper'
      $cgroups_package = 'cgroup-bin'
      $cgroups_tools_package = UNDEF
      $cgconfig_require = [
        Package['cgroups'],
        File['/etc/init/cgconfig.conf'],
      ]
      $cgred_require = [
        Package['cgroups'],
        File['/etc/init/cgred.conf'],
      ]
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'compiler_tools::params::zookeeper' module only supports osfamily Debian or RedHat.")
    }
  }
  # Packages
  $packages = [
    $zookeeper_package,
    $cgroups_package,
    $cgroups_tools_package,
  ]
  $requires = [$cgconfig_require,$cgred_require]
}
