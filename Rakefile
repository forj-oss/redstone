# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_80chars')

# Disable check due to upstream bug: https://github.com/rodjek/puppet-lint/issues/170
PuppetLint.configuration.send('disable_class_parameter_defaults')

require 'puppetlabs_spec_helper/rake_tasks'
