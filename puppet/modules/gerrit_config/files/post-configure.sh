#!/bin/bash

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
# Script to check if a new account has been created to start a last puppet agent -t

function GetAccounts()
{
 sudo -i mysql reviewdb -B -N -e "select count(*) from account_external_ids aei where external_id not like '%gerrit%' and external_id not like '%jenkins%'"
}

COUNT="$(GetAccounts)"

echo "Executing a last puppet agent to provide gerrit link to the console"

puppet agent -t --debug 2>&1 | tee -a /tmp/puppet-post-install-1.log

echo "Post Install: Waiting for registration in gerrit"

while [ $COUNT -le 1 ]
do
  sleep 5
  COUNT="$(GetAccounts)"
done
echo "Post install : Detected new users in gerrit. Initializing tutorials"
puppet agent --debug -t 2>&1 | tee -a /tmp/puppet-post-install-2.log
puppet agent --debug -t 2>&1 | tee -a /tmp/puppet-post-install-3.log
