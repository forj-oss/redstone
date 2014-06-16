# Class: nexus

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
# This module downloads Maven Artifacts from Nexus
#
# Parameters:
# [*url*] : The Nexus base url (mandatory)
# [*username*] : The username used to connect to nexus
# [*password*] : The password used to connect to nexus
# [*anonymous*] : anon connection to nexus
#
# Actions:
# Checks and intialized the Nexus support.
#
# Sample Usage:
#  class nexus {
#   url => http://<host:port>/nexus,
#   username => user,
#   password => password
# }
#
class nexus(
  $url       = '',
  $username  = hiera('nexus::username', ''),
  $password  = hiera('nexus::password', ''),
  $anonymous = false
) {

    # Check arguments
    # url mandatory
    if $url == '' {
      fail('Cannot initialize the Nexus class - the url parameter is mandatory')
    }

    $nexus_url = $url

    #if(str2bool($anonymous) != true) {
    if($anonymous != true) {
        if ($username != '')  and ($password == '') {
          fail('Cannot initialize the Nexus class - both username and password must be set')
        }elsif ($username == '')  and ($password != '') {
          fail('Cannot initialize the Nexus class - both username and password must be set')
        } elsif ($username == '')  and ($password == '') {
          $authentication = false
        } else {
          $authentication = true
          $user = $username
          $pwd = $password
        }
    } else {
        # hack this
        $authentication = false
    }


    # Install script
    file { "/opt/config/${::environment}/scripts/download-artifact-from-nexus.sh":
      ensure   => file,
      owner    => 'root',
      mode     => '0755',
      source   => 'puppet:///modules/nexus/download-artifact-from-nexus.sh',
      require  => [File["/opt/config/${::environment}/scripts"]]
    }

    # Duplicated at gerrit_config/manifests/pyscripts.pp
    if ! defined(File['/opt']) {
      file { '/opt' : ensure => directory }
    }

    if ! defined(File['/opt/config']) {
      file { '/opt/config' : ensure => directory }
    }

    if ! defined(File["/opt/config/${::environment}"]) {
      file { "/opt/config/${::environment}" : ensure => directory }
    }

    if ! defined(File["/opt/config/${::environment}/scripts"]) {
      file { "/opt/config/${::environment}/scripts" : ensure => directory }
    }
}
