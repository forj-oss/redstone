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
# TODO: needs to be refactored to use apt repo mangement
class java_ora::add_repo{
  $apt_repo = '/usr/bin/add-apt-repository'
  $apt_get  = '/usr/bin/apt-get'
  $touch    = '/usr/bin/touch'
  $test     = '/usr/bin/test'
  $tmp      = '/var/tmp'
  $java_update = '.java_oracle_apt-get-update'
  $webteamlst  = 'webupd8team-java-precise.list'
  notify{'Adding repo ppa:webupd8team/java':}
  ->
  exec{'java_ora::add_repo':
    command => "${apt_repo} -y ppa:webupd8team/java",
    unless  => "${test} -e /etc/apt/sources.list.d/${webteamlst}"
  }
  ->
  exec{'java_ora::apt-get-update':
    command => "${apt_get} update && ${touch} ${tmp}/${java_update}",
    unless  => "${test} -e ${tmp}/.java_oracle_apt-get-update"
  }
}
