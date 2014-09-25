# == compiler_tools::params::rubydev
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
class compiler_tools::params::rubydev {
  case $::osfamily {
    'RedHat': {
      # For Ceilometer unit tests
      $pkgconfig_package      = 'pkgconfig'
      $python_libvirt_package = 'libvirt-python'
      $python_lxml_package    = 'python-lxml'
      $python_zmq_package     = 'python-zmq'
      $rubygems_package       = 'rubygems'
      $ruby1_9_1_package      = UNDEF
      $ruby1_9_1_dev_package  = UNDEF
      $ruby_bundler_package   = UNDEF
    }
    'Debian': {
      # For Ceilometer unit tests
      $pkgconfig_package      = 'pkg-config'
      $python_libvirt_package = 'python-libvirt'
      $python_lxml_package    = 'python-lxml'
      $python_zmq_package     = 'python-zmq'
      $rubygems_package       = 'rubygems'
      $ruby1_9_1_package      = 'ruby1.9.1'
      $ruby1_9_1_dev_package  = 'ruby1.9.1-dev'
      $ruby_bundler_package   = 'ruby-bundler'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'compiler_tools::params::rubydev' module only supports osfamily Debian or RedHat.")
    }
  }

  # Packages
  $packages = [
    $pkgconfig_package,      # for spidermonkey, used by ceilometer
    $python_libvirt_package,
    $python_lxml_package,    # for validating openstack manuals
    $python_zmq_package,     # zeromq unittests (not pip installable)
    $rubygems_package,
    $ruby1_9_1_package,
    $ruby1_9_1_dev_package,
    $ruby_bundler_package,
  ]
}
