# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#
#  params:
#  test:
#    puppet apply -e "fortify_cli{'my-fortify_cli':}" --modulepath=.:/etc/puppet/modules
#
#
define fortify_cli($msg = $title) {
  notice("running ${msg}")
  class {'fortify_cli::install' : } ->
  file { '/usr/local/bin/ff-scan.sh':
          ensure => present,
          owner  => 'jenkins',
          group  => 'jenkins',
          mode   => '0775',
          source => 'puppet:///modules/fortify_cli/scripts/ff-scan.sh',
  }
}