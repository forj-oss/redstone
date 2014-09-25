# == Class: gerrit_config::cron
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
class gerrit_config::cron(
  $script_user = 'update',
  $script_key_file = '/home/gerrit2/.ssh/id_rsa'
) {

  cron { 'expireoldreviews':
    user    => 'gerrit2',
    hour    => '6',
    minute  => '3',
    command => "python /usr/local/bin/expire-old-reviews ${script_user} ${script_key_file}",
    require => Class['jeepyb_config'],
  }

  cron { 'gerrit_repack':
    user        => 'gerrit2',
    weekday     => '0',
    hour        => '4',
    minute      => '7',
    command     => 'find /home/gerrit2/review_site/git/ -type d -name "*.git" -print -exec git --git-dir="{}" repack -afd \;',
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
  }

  cron { 'removedbdumps':
    user        => 'gerrit2',
    hour        => '5',
    minute      => '1',
    command     => 'find /home/gerrit2/dbupdates/ -name "*.sql.gz" -mtime +30 -exec rm -f {} \;',
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
  }
}
