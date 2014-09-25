# == compiler_tools::install::fortify
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
# setup fortify
#
class compiler_tools::install::fortify (
    $install_fortify = true,
)
{
  if ($install_fortify == true)
  {
    $java_package_used = 'setup oracle java 7'
    notify { 'setup oracle java 7':} ->
    package { 'openjdk-7-jre-headless':
      ensure  => purged,
      require => Exec['apt-get update cache'],
    } ->
    java_ora{7:
    }->
    fortify_cli{'my-fortify-cli':
      }

  } else
  {
    $java_package_used = 'setup openjdk 7'
    notify { 'setup openjdk 7':} ->
    package { 'openjdk-7-jre-headless':
      ensure  => present,
      require => Exec['apt-get update cache'],
    } ->
    #TODO: implement purged option for java_ora class Package["oracle-java${version}-installer"]
    package{ 'oracle-java7-installer':
      ensure => purged,
    }
  }
}
