# Copyright 2014 Hewlett-Packard Development Company, L.P.
# Copyright 2013 OpenStack Foundation.
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
# Class: exim::params
#
# This class holds parameters that need to be
# accessed by other classes.
class exim_config::params {
  case $::osfamily {
    'RedHat': {
      $package = 'exim'
      $service_name = 'exim'
      $config_file = '/etc/exim/exim.conf'
      $conf_dir = '/etc/exim/'
      $sysdefault_file = '/etc/sysconfig/exim'
    }
    'Debian': {
      $package = 'exim4-daemon-light'
      $service_name = 'exim4'
      $config_file = '/etc/exim4/exim4.conf'
      $conf_dir = '/etc/exim4'
      $sysdefault_file = '/etc/default/exim4'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'exim' module only supports osfamily Debian or RedHat (slaves only).")
    }
  }
}
