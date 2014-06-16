# == compiler_tools::package_install
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
# package installation
#
define compiler_tools::package_install (
  $package          = $title,
  $ensure_option    = present,
  $package_requires = UNDEF,
  $package_provider = UNDEF,
)
{
  if $package != '' and $package != UNDEF
  {
    if $package_provider == UNDEF
    {
      if $package_requires == UNDEF
      {
        if ! defined(Package[$package])
        {
          package { $package:
            ensure => $ensure_option,
          }
        }
      }
      else
      {
        if ! defined(Package[$package])
        {
          debug("installing package ${package} with ensure, ${ensure_option} and requires ${package_requires}")
          package { $package:
            ensure   => $ensure_option,
            require  => $package_requires,
          }
        }
      }
    }
    else
    {
      if $package_requires == UNDEF
      {
        if ! defined(Package[$package])
        {
          package { $package:
            ensure   => $ensure_option,
            provider => $package_provider,
          }
        }
      }
      else
      {
        if ! defined(Package[$package])
        {
          package { $package:
            ensure   => $ensure_option,
            provider => $package_provider,
            require  => $package_requires,
          }
        }
      }
    }
  }
}
