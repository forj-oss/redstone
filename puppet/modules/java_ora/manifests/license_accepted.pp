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
#

class java_ora::license_accepted{
  $echo    = '/bin/echo'
  $grep    = '/bin/grep'
  $debconfget = '/usr/bin/debconf-get-selections'
  $debconfset = '/usr/bin/debconf-set-selections'
  $lic_opt    = 'accepted-oracle-license-v1-1'
  notify{'Accepting license':}
  ->
  exec { 'java_ora::license_accepted1':
    command => "${echo} debconf shared/${lic_opt} select true | ${debconfset}",
    unless  => "${debconfget} | ${grep} '${lic_opt} select true'"
  }
  ->
  exec { 'java_ora::license_accepted2':
    command => "${echo} debconf shared/${lic_opt} seen true | ${debconfset}",
    unless  => "${debconfget} | ${grep} '${lic_opt} seen true'"
  }
}
