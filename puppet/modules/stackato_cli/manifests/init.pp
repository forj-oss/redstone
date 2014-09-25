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
#  params:
#    execshell: true executes wrapped shell script, false will call puppet
#               version of the script
#    clipath: if specified will overwrite pre-configured paths (see shell.pp)
#  test:
#    puppet apply -e "stackato_cli{'my-stackato_cli':}"
#                 --modulepath=/etc/puppet/modules


define stackato_cli($msg = $title, $execshell = true, $clipath = undef) {
  notice("running ${msg}")
  class {'stackato_cli::install' :
          execshell => $execshell,
          clipath   => $clipath,
  }
}