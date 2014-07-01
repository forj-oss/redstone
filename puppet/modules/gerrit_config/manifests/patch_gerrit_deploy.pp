# == gerrit_config::patch_gerrit_deploy
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
# Provide some patches for gerrit deploy outside of openstack config project.
#
# ChL: Proxy code added for gerrit. If http_proxy has been changed,
#      /etc/default/puppet have to be configured with 'export http_proxy=...'
#      and restart agent.

class gerrit_config::patch_gerrit_deploy
{
  # this should be patched in gerrit::initi.pp line 120
  $java_home = $::lsbdistcodename ? {
    'precise' => "/usr/lib/jvm/java-7-openjdk-${::architecture}/jre",
  }
  $http_proxy=$::http_proxy
  $gerrit_config_file='/home/gerrit2/review_site/etc/gerrit.config'
  # this is alwasy and edit, so we only sed
  $java_fix_cmd = "sed -e 's%[^\s+]javaHome\s*=.*%       javaHome = ${java_home}%g' ${gerrit_config_file} --in-place"

  # javaHome is not null, it exist!
  $git_config  = "git config -f ${gerrit_config_file}"
  $javahomecfg = "git config -f ${gerrit_config_file} --get container.javaHome"
  exec { 'fix the value for java_home so that it matches our platform.':
          path    => ['/bin', '/usr/bin'],
          command => $java_fix_cmd,
          onlyif  => [
                        "test \"\$(${javahomecfg})\" != \"\"",
                        "test \"\$(${javahomecfg})\" != \"${java_home}\""
                      ],
          require => File[$gerrit_config_file],
    }

  # fix the /etc/init.d/gerrit to do a status along with check so we can use
  # the service class
  $status_str = 'check|status'
  $gerrit_home = '/home/gerrit2/review_site'
  $gerrit_sh   = "${gerrit_home}/bin/gerrit.sh"
  $add_status = "sed -e 's%\s*check)%  check|status)%'  ${gerrit_sh} --in-place"
  $sed_test    = 'sed \'s/^\\s*//\''

  $test_chk = "grep \"check)\" ${gerrit_sh}"
  $test_status = "test \"\$(${test_chk} | ${sed_test})\" != \"${status_str})\""
  exec {'fix gerrit start script so that it has a status function' :
          path    => ['/bin', '/usr/bin'],
          command => $add_status,
          onlyif  => $test_status,
          require => [
                      Exec['gerrit-initial-init'],
                      Exec['gerrit-init'],
          ]
    }

}