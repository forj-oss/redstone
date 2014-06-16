# == Class: compiler_tools::installer
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
define compiler_tools::installer (
  $installer         = $title,
  $installer_data    = UNDEF,
)
{
  $tools_class  = $installer_data[$installer]['class']
  $install_flag = str2bool($installer_data[$installer]['install_flag'])
  if $installer_data[$installer]['install_option'] != '' and $installer_data[$installer]['install_option'] != UNDEF
  {
    $install_opt  = str2bool($installer_data[$installer]['install_option'])
  } else
  {
    $install_opt = UNDEF
  }
  if ($tools_class != UNDEF and $tools_class != '')
  {
    if $install_flag == true
    {
      if $install_opt != UNDEF and $install_opt != ''
      {
        class{$tools_class:
          install_opt => $install_opt,
        }
      }
      else
      {
        class{$tools_class:}
      }
    }
    else
    {
      notify{"skipping install for ${tools_class}, install flag is ${install_flag}":}
    }
  }
}
