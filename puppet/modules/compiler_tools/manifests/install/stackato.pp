# compiler_tools::install::stackato
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
class compiler_tools::install::stackato (
$stackato_url        = hiera('compiler_tools::install::stackato::stackato_url', 'http://nexus.cdkdev.org:8080/nexus/content/repositories/cdk-content/org/cdkdev/clis/apaas/stackato/stackacto'),
$stackato_version    = hiera('compiler_tools::install::stackato::stackato_version', '3.1'),
$stackato_name       = hiera('compiler_tools::install::stackato::stackato_name', 'stackacto'),
$stackato_classifier = hiera('compiler_tools::install::stackato::stackato_classifier', 'x86_64'),
$stackato_type       = hiera('compiler_tools::install::stackato::stackato_type', 'zip'),
$stackato_md5        = hiera('compiler_tools::install::stackato::stackato_md5', 'f88ae95adaaea2f3d71d1edd2ef6b0d0'),
)
{
  $file_name = "${stackato_name}-${stackato_version}-${stackato_classifier}.${stackato_type}"
  $download_url = "${stackato_url}/${stackato_version}/${file_name}"

  if ! defined(Package['unzip']) {
    package { 'unzip':
      ensure => present,
    }
  }

  # http://nexus.cdkdev.org:8080/nexus/content/repositories/cdk-content/org/cdkdev/clis/apaas/stackato/stackacto/3.1/stackacto-3.1-x86_64.zip
  downloader {$download_url:
              ensure   => present,
              path     => "/tmp/${file_name}",
              md5      => $stackato_md5,
              owner    => 'puppet',
              group    => 'puppet',
              mode     => 755,
              replace  => false,
              provider => url,
  }
  exec {"${stackato_name}-unzip":
      command => "/usr/bin/unzip -qq -j -o /tmp/${file_name} -d /usr/local/bin",
      require => [ Package['unzip'], Downloader[$download_url] ],
      creates => '/usr/local/bin/stackato',
  }
}