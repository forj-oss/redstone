# == compiler_tools::params::dblibs
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
class compiler_tools::params::dblibs {
  case $::osfamily {
    'RedHat': {
      # for keystone ldap auth integration
      $ldap_dev_package    = 'openldap-devel'
      $libsasl_dev         = 'cyrus-sasl-devel'
      $mongodb_package     = 'mongodb-server'
      $mysql_dev_package   = 'mysql-devel'
      $nspr_dev_package    = 'nspr-devel'
      $sqlite_dev_package  = 'sqlite-devel'
      $libvirt_dev_package = 'libvirt-devel'
      $libxml2_package     = 'libxml2'
      $libxml2_dev_package = 'libxml2-devel'
      $libxslt_dev_package = 'libxslt-devel'
      $libffi_dev_package  = 'libffi-devel'
    }
    'Debian': {
      # for keystone ldap auth integration
      $ldap_dev_package    = 'libldap2-dev'
      $libsasl_dev         = 'libsasl2-dev'
      $mongodb_package     = 'mongodb'
      $mysql_dev_package   = 'libmysqlclient-dev'
      $nspr_dev_package    = 'libnspr4-dev'
      $sqlite_dev_package  = 'libsqlite3-dev'
      $libvirt_dev_package = 'libvirt-dev'
      $libxml2_package     = 'libxml2-utils'
      $libxml2_dev_package = 'libxml2-dev'
      $libxslt_dev_package = 'libxslt1-dev'
      $libffi_dev_package  = 'libffi-dev'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'compiler_tools::params::dblibs' module only supports osfamily Debian or RedHat.")
    }
  }

  # Packages
  $packages = [
    $ldap_dev_package,
    $libsasl_dev,            # for keystone ldap auth integration
    $mongodb_package,        # for ceilometer unit tests
    $mysql_dev_package,
    $nspr_dev_package,       # for spidermonkey, used by ceilometer
    $sqlite_dev_package,
    $libvirt_dev_package,
    $libxml2_package,
    $libxml2_dev_package,    # for xmllint, need for wadl
    $libxslt_dev_package,
    $libffi_dev_package,     # xattr's cffi dependency
  ]
}
