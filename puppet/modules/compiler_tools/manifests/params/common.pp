# == compiler_tools::params::common
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
# common package list
class compiler_tools::params::common {
  case $::osfamily {
    'RedHat': {
      # common packages
      $build_essentials       = UNDEF
      $jdk_package            = 'java-1.7.0-openjdk'
      $jre6_package           = UNDEF
      $curl_package           = 'curl'
      $ccache_package         = 'ccache'
      $python_netaddr_package = 'python-netaddr'
      $libcurl_dev_package    = 'libcurl-devel'
    }
    'Debian': {
      # common packages
      $build_essentials       = 'build-essential'
      $jdk_package            = 'openjdk-7-jdk'
      $jre6_package           = 'openjdk-6-jre-headless'
      $curl_package           = 'curl'
      $ccache_package         = 'ccache'
      $python_netaddr_package = 'python-netaddr'
      $libcurl_dev_package    = 'libcurl4-gnutls-dev'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'compiler_tools::params::common' module only supports osfamily Debian or RedHat.")
    }
  }
  $packages = [
    $jdk_package,            # jdk for building java jobs
    $jre6_package,
    $curl_package,
    $ccache_package,
    $python_netaddr_package, # Needed for devstack address_in_net()
    $libcurl_dev_package,
  ]
}
