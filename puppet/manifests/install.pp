# == Class: install
#
# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
# Required for puppet.conf to be updated.
# TODO: To move to bp.py
class { 'puppet': } ->
# Required for publishing redstone servers layouts to layout in hiera.
# TODO: To be replaced by transformation.py
class { 'runtime_project::hiera_setup': }

