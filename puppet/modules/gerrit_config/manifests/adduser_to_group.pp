# == gerrit_config::adduser_to_group
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
# Add a gerrit user to list of groups
# Testing it:

define gerrit_config::adduser_to_group (
    $group                  = $title,
    $email_address          = undef,
)
{
  include gerrit_config::params
  include gerrit_config::pyscripts
  # darn this is not supported till gerrit 2.7, openstack gerrit is 2.4... this will have to wait.
  if $email_address != undef
  {
    exec { "add user ${email_address} to group ${group}":
          path    => ['/bin', '/usr/bin'],
          command => "${gerrit_config::params::gerrit_ssh} gerrit set-members -a ${email_address} ${group}",
          onlyif  => [ "test $(${gerrit_config::params::gerrit_ssh} gerrit ls-members ${group} |grep '${email_address}' | wc -l) -le 0" ],
    }
  } else
  {
    notice("skipping adduser to group ${group}, because email_address is undefined.")
  }


}