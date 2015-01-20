# == gerrit_config::createbatchaccount
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
# A gerrit batch account will be created if one doesn't already exist.
# The first account must already be created, a check for that will be made.
# Nothing is done if the first account does not exist.
# Testing it:
# pp -e "cacerts::sshgenkeys{'jenkins':do_cacertsdb=>true}"
# pp -e "gerrit_config::createbatchaccount{'jenkins':,fullname=>'Jenkins',email_address=>'jenkins@localhost.org',group=>'Administrators',debug_flag=>true}"

define gerrit_config::createbatchaccount (
    $gerrit_id             = $title,
    $fullname              = undef,
    $email_address         = undef,
    $group                 = undef,
    $debug_flag            = false,
    $ssh_pub_key_content   = undef,
)
{
  include gerrit_config::params
  include gerrit_config::pyscripts

# only run if the account exist, value returns  1
# otherwise we should fail
  exec { "check before createbatchaccount ${gerrit_id}":
            path    => ['/bin', '/usr/bin'],
            command => 'echo \'continue with execution of group checks\'',
            onlyif  => "test \$(python /opt/config/${gerrit_config::params::environment}/lib/createfirstaccount.py --check_exists ${debug_flag} > /dev/null 2<&1;echo $?) = 1",
  }

  if $email_address == undef
  {
    $email_opt = ''
  } else
  {
    $email_opt = "--email \"'${email_address}'\""
  }
  if $fullname == undef
  {
    $fullname_opt = ''
  } else
  {
    $fullname_opt = "--full-name \"'${fullname}'\""
  }

  if (($group == undef) or is_array($group))
  {
    $group_opt = ''
  } else
  {
    $group_opt = "--group \"'${group}'\""
  }

  if ($ssh_pub_key_content == undef) {
      $ssh_pub_key_fspec = "${cacerts::params::ssh_keys_dir}/${gerrit_id}.pub"
      $ssh_pub_key       = cacerts_getkey($ssh_pub_key_fspec)
  } else {
    $ssh_pub_key = $ssh_pub_key_content
  }

  $sql_account_exist = "select * from account_external_ids where external_id = \\\"'username:${gerrit_id}'\\\""
  $pubkey_target = "${gerrit_config::params::gerrit_ssh_home}/${gerrit_id}.pub"
  file { $pubkey_target:
    owner   => $gerrit_config::params::gerrit_user,
    group   => $gerrit_config::params::gerrit_user,
    mode    => '0600',
    content => $ssh_pub_key,
    require => Exec["check before createbatchaccount ${gerrit_id}"],
  }

  # create the batch account if it's missing'
  exec { "create batch account ${gerrit_id}":
            path    => ['/bin', '/usr/bin'],
            command => "cat ${pubkey_target} | ${gerrit_config::params::gerrit_ssh} gerrit create-account ${group_opt} ${fullname_opt} ${email_opt} --ssh-key - ${gerrit_id}",
            onlyif  => [
                        "test \$(${gerrit_config::params::gerrit_ssh} gerrit gsql -c \"'${sql_account_exist}'\"|grep ${gerrit_id}|wc -l) -le 0",
                        "test \$(${gerrit_config::params::gerrit_ssh} gerrit ls-groups |grep '${group}' > /dev/null 2<&1;echo $?) = 0",
                      ],
            require => File[$pubkey_target],
  }->
  gerrit_config::signagreements{$gerrit_id:
  }

  # If group is an array, then we add groups seperately
  # this is not available till 2.7 for now we leave it here.
  if (  ($group != undef)  and
        (is_array($group)) and
        (size($group) > 0) and
        ($email_address != undef)
  )
  {
    gerrit_config::adduser_to_group{$group:
        email_address => $email_address,
        require       => Exec["create batch account ${gerrit_id}"],
    }
  }
}
