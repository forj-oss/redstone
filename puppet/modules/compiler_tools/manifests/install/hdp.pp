# compiler_tools::install::hdp
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
class compiler_tools::install::hdp (
$hdp_url        = hiera('compiler_tools::install::hdp::hdp_url', 'http://nexus.cdkdev.org:8080/nexus/content/repositories/cdk-content/org/cdkdev/clis/apaas/hpcloud/hdp'),
$hdp_version    = hiera('compiler_tools::install::hdp::hdp_version', '1.0'),
$hdp_name       = hiera('compiler_tools::install::hdp::hdp_name', 'hdp'),
$hdp_classifier = hiera('compiler_tools::install::hdp::hdp_classifier', 'x86_64'),
$hdp_type       = hiera('compiler_tools::install::hdp::hdp_type', 'zip'),
$hdp_md5        = hiera('compiler_tools::install::hdp::hdp_md5', 'e5a87bc42ca57167acf7cdce70414fe8'),
)
{
  $file_name = "${hdp_name}-${hdp_version}-${hdp_classifier}.${hdp_type}"
  $download_url = "${hdp_url}/${hdp_version}/${file_name}"

  if ! defined(Package['unzip']) {
    package { 'unzip':
      ensure => present,
    }
  }

  # http://nexus.cdkdev.org:8080/nexus/content/repositories/cdk-content/org/cdkdev/clis/apaas/hpcloud/hdp/1.0/hdp-1.0-x86_64.zip
  downloader {$download_url:
              ensure          => present,
              path            => "/tmp/${file_name}",
              md5             => $hdp_md5,
              owner           => 'puppet',
              group           => 'puppet',
              mode            => 755,
              replace         => false,
              provider        => url,
  }
  exec {"${hdp_name}-unzip":
      command => "/usr/bin/unzip -qq -j -o /tmp/${file_name} -d /usr/local/bin",
      require => [ Package['unzip'], Downloader[$download_url] ],
      creates => '/usr/local/bin/hdp',
  }
}