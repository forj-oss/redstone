# compiler_tools::install::cf
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
class compiler_tools::install::cf (
$cf_url        = hiera('compiler_tools::install::cf::cf_url', 'http://nexus.cdkdev.org:8080/nexus/content/repositories/cdk-content/org/cdkdev/clis/apaas/cf/cf-cli_amd64'),
$cf_version    = hiera('compiler_tools::install::cf::cf_version', '6.2'),
$cf_name       = hiera('compiler_tools::install::cf::cf_name', 'cf-cli_amd64'),
$cf_type       = hiera('compiler_tools::install::cf::cf_type', 'deb'),
$cf_md5        = hiera('compiler_tools::install::cf::cf_md5', 'd9338941d98840f7774bc75363ba62de'),
){
  # http://nexus.cdkdev.org:8080/nexus/content/repositories/cdk-content/org/cdkdev/clis/apaas/cf/cf-cli_amd64/6.2/cf-cli_amd64-6.2.deb
  $file_name = "${cf_name}-${cf_version}.${cf_type}"
  $download_url = "${cf_url}/${cf_version}/${file_name}"

  downloader {$download_url:
    ensure   => present,
    path     => "/tmp/${file_name}",
    md5      => $cf_md5,
    owner    => 'puppet',
    group    => 'puppet',
    mode     => 755,
    replace  => false,
    provider => url,
  }
  # install Cloud Foundry cli
  if ! defined(Package['cf-cli']) {
    package { 'cf-cli':
      ensure   => latest,
      source   => "/tmp/${file_name}",
      provider => 'dpkg',
      require  => Downloader[$download_url],
    }
  }
}
