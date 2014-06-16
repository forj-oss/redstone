# == gerrit_config::connect_bugs
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
# Determine the defect tracking integration in gerrit
# use facter values for configuration, we use maestro to manage those facters.
#
#

class gerrit_config::connect_bugs (
  $enabled                = true,
)
{

  # Setup bugzilla
  if ($::kitops_endpoint != '' and $::bugzilla_enabled == true)
  {
    $bugzilla_link = [
          {
            name  => 'bugzilla',
            match => '(\\b[Bb]ug\\b|\\b[Ll][Pp]\\b)[ \\t#:]*(\\d+)',
            link  => $::bugzilla_defect_url,
          }
      ]
  } else
  {
    $bugzilla_link = []
  }
  # Setup launchpad
  if ($::kitops_endpoint != '' and $::launchpad_enabled == true)
  {
    $launchpad_link = [
          {
            name  => 'launchpad',
            match => '(\\b[Bb]ug\\b|\\b[Ll][Pp]\\b)[ \\t#:]*(\\d+)',
            link  => $::launchpad_defect_url,
          }
      ]
  } else
  {
    $launchpad_link = []
  }
  # Setup AgM
  if ($::kitops_endpoint != '' and $::agm_enabled == true)
  {
    $agm_link = [
          {
            name  => 'agm',
            match => '(\\b[Dd]efect\\b)[ \\t#:]*(\\d+)',
            link  => $::agm_defect_url,
          }
      ]
  } else
  {
    $agm_link = []
  }

  if ($enabled == true)
  {
    $commentlink1 = concat($bugzilla_link, $launchpad_link)
    $commentlink  = concat($commentlink1,  $agm_link)
  } else
  {
    $commentlink = []
  }
    # some testing
    # $a1 = [1,3,4]
    # $a2 = [2,6,7]
    # $a3 = concat($commentlink , $commentlink1)
    # notice($a3[3]['name'])
}