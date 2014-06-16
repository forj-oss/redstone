# = Class: java
# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
# This class installs JAva Oracle KDK and sets the JAVA HOME, tested on
# ubuntu
#
# == Parameters:
#
# $version:: An String, supports 6, 7 or 8
#
# == Requires:
#
# Nothing.
#
# == Sample Usage:
#
#
# java_ora{'8':}
# ->
# java_ora{'7':}
# ->
# java_ora{'6':}
#
# == Test: puppet apply -e 'java_ora{8:}'
# --modulepath=
# /opt/config/production/git/redstone/puppet/modules/

define java_ora ($version = $title) {
  if ! defined(Class['java_ora::dependencies']) {
    class {'java_ora::dependencies':}
  }

  if ! defined(Class['java_ora::add_repo']) {
    class {'java_ora::add_repo': require => Class['java_ora::dependencies']}
  }

  if ! defined(Class['java_ora::license_accepted']) {
    class {'java_ora::license_accepted': require => Class['java_ora::add_repo']}
  }

  if ! defined(Package["oracle-java${version}-installer"]) {
    notify {"Installing java${version}, download might take some time... ":}
    ->
    notify {"Files are stored in /var/cache/oracle-jdk${version}-installer,
            if you're bored...":}
    ->
    package { "oracle-java${version}-installer":
              require => Class['java_ora::license_accepted']
    }
  }
}