# == jenkins_config:copy_job_templates
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
define jenkins_config::copy_job_templates(
  $template_file  = $title,
  $runtime_module = 'runtime_project',
)
{
  $template_path = "${runtime_module}/jenkins_job_builder/config"
  file { "/etc/jenkins_jobs/config/${template_file}":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("${template_path}/${template_file}.erb"),
    }
}