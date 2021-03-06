# == compiler_tools::install::flake8
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
class compiler_tools::install::flake8 (
)
{
  include compiler_tools::params::flake8
  include pip::python2
  package_install{$::compiler_tools::params::flake8::packages:
                    package_requires => $::compiler_tools::params::flake8::requires,
                    package_provider =>  $::compiler_tools::params::flake8::package_provider,
  }

}