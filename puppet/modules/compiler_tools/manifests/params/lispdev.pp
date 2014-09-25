# == compiler_tools::params::lispdev
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
class compiler_tools::params::lispdev {
  case $::osfamily {
    'RedHat': {
      # Common Lisp interpreter
      $sbcl_package   = 'sbcl'
      $sqlite_package = 'sqlite'
      $unzip_package  = 'unzip'
      $xslt_package   = 'libxslt'
      $xvfb_package   = 'xorg-x11-server-Xvfb'
    }
    'Debian': {
      # Common Lisp interpreter, used for cl-openstack-client
      $sbcl_package   = 'sbcl'
      $sqlite_package = 'sqlite3'
      $unzip_package  = 'unzip'
      $xslt_package   = 'xsltproc'
      $xvfb_package   = 'xvfb'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'compiler_tools::params::lispdev' module only supports osfamily Debian or RedHat.")
    }
  }

  # Packages
  $packages = [
    $sbcl_package,           # cl-openstack-client testing
    $sqlite_package,
    $unzip_package,
    $xslt_package,           # for building openstack docs
    $xvfb_package,           # for selenium tests
  ]
}
