# == gerrit_config::signagreements
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
# Sign the contribution agreement per account enabled by the manifest.

define gerrit_config::signagreements (
    $gerrit_id             = $title,
)
{
  $sql_account_exist = "select * from account_external_ids where external_id = \\\"'username:${gerrit_id}'\\\""
  $sql_agreement_exist =  "select * from account_group_members natural join account_external_ids where external_id = \\\"'username:${gerrit_id}'\\\" and group_id = (select group_id from account_groups where name = \"'CLA Accepted - ICLA''\" )"
  $sql_agreement_insert = "insert into account_group_member VALUES ((select account_id from account_external_ids where external_id = \\\"'username:${gerrit_id}'\\\"),(select group_id from account_groups where name = \"'CLA Accepted - ICLA''\" ))"
  # Sign the contribution agreement in case it not exists
  exec { "sign contribution agreement for ${gerrit_id} user":
      path      => ['/bin', '/usr/bin'],
      command   => "${gerrit_config::params::gerrit_ssh} gerrit gsql -c \"'${sql_agreement_insert}'\"",
      onlyif    => [
                    "test \$(${gerrit_config::params::gerrit_ssh} gerrit gsql -c \"'${sql_agreement_exist}'\"|grep ${gerrit_id}|wc -l) -le 0",
                    "test \$(${gerrit_config::params::gerrit_ssh} gerrit gsql -c \"'${sql_account_exist}'\"|grep ${gerrit_id}|wc -l) -le 1",
                    ],
      logoutput => true,
  }
}