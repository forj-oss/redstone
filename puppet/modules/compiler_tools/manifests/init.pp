# == compiler_tools::init
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
# setup compiler tools as required for slave servers
# example call:
# class { 'compiler_tools':
#          install_fortify      => false,
#          install_common       => true,
#          install_dblibs       => false,
#          install_docs         => false,
#          install_lispdev      => false,
#          install_maven        => false,
#          install_rubydev      => false,
#          install_zookeeper    => false,
#          install_puppetlint   => true,
#          install_gittools     => true,
#          install_jenkinstools => true,
#          install_pypy         => true,
#          install_python3      => false,
#        }
#
class compiler_tools (
  $install_stackato     = true,
  $install_cf           = true,
  $install_hdp          = true,
  $install_flake8       = true,
  $install_fortify      = false,
  $install_common       = true,
  $install_dblibs       = true,
  $install_docs         = false,  # docs tools is large, requires disk space.
  $install_lispdev      = true,
  $install_maven        = true,
  $install_rubydev      = false,
  $install_zookeeper    = false,
  $install_puppetlint   = true,
  $install_gittools     = true,
  $install_jenkinstools = true,
  $install_pypy         = true,
  $install_python3      = false,
)
{
  file { '/etc/apt/sources.list.d/cloudarchive.list':
    ensure => absent,
  }

  $installer_package = [  'stackato'      ,
                          'cf'      ,
                          'hdp'      ,
                          'flake8'      ,
                          'fortify'     ,
                          'common'      ,
                          'dblibs'      ,
                          'docs'        ,
                          'lispdev'     ,
                          'maven'       ,
                          'rubydev'     ,
                          'zookeeper'   ,
                          'puppetlint'  ,
                          'gittools'    ,
                          'jenkinstools',
                          'pypy'        ,
                    ]

  $installer_hash = "{
                    \"stackato\" : {
                                  \"class\"        :\"compiler_tools::install::stackato\",
                                  \"install_flag\" :\"${install_stackato}\"
                                 },
                    \"cf\" : {
                                  \"class\"        :\"compiler_tools::install::cf\",
                                  \"install_flag\" :\"${install_cf}\"
                                 },
                    \"hdp\" : {
                                  \"class\"        :\"compiler_tools::install::hdp\",
                                  \"install_flag\" :\"${install_hdp}\"
                                 },
                    \"flake8\" : {
                                  \"class\"        :\"compiler_tools::install::flake8\",
                                  \"install_flag\" :\"${install_flake8}\"
                                 },
                    \"fortify\" : {
                                  \"class\"        :\"compiler_tools::install::fortify\",
                                  \"install_flag\" :\"${install_fortify}\"
                                 },
                    \"common\" : {
                                  \"class\"        :\"compiler_tools::install::common\",
                                  \"install_flag\" :\"${install_common}\"
                                 },
                    \"dblibs\" : {
                                  \"class\"        :\"compiler_tools::install::dblibs\",
                                  \"install_flag\" :\"${install_dblibs}\"
                                 },
                    \"docs\" : {
                                  \"class\"        :\"compiler_tools::install::docs\",
                                  \"install_flag\" :\"${install_docs}\"
                                 },
                    \"lispdev\" : {
                                  \"class\"        :\"compiler_tools::install::lispdev\",
                                  \"install_flag\" :\"${install_lispdev}\"
                                 },
                    \"maven\" : {
                                  \"class\"        :\"compiler_tools::install::maven\",
                                  \"install_flag\" :\"${install_maven}\"
                                 },
                    \"rubydev\" : {
                                  \"class\"        :\"compiler_tools::install::rubydev\",
                                  \"install_flag\" :\"${install_rubydev}\"
                                 },
                    \"zookeeper\" : {
                                  \"class\"        :\"compiler_tools::install::zookeeper\",
                                  \"install_flag\" :\"${install_zookeeper}\"
                                 },
                    \"puppetlint\" : {
                                  \"class\"        :\"compiler_tools::install::puppetlint\",
                                  \"install_flag\" :\"${install_puppetlint}\"
                                 },
                    \"gittools\" : {
                                  \"class\"        :\"compiler_tools::install::gittools\",
                                  \"install_flag\" :\"${install_gittools}\",
                                  \"install_option\":\"${install_python3}\"
                                 },
                    \"jenkinstools\" : {
                                  \"class\"        :\"compiler_tools::install::jenkinstools\",
                                  \"install_flag\" :\"${install_jenkinstools}\"
                                 },
                    \"pypy\" : {
                                  \"class\"        :\"compiler_tools::install::pypy\",
                                  \"install_flag\" :\"${install_pypy}\"
                                 }
                 }"
  $data = parsejson($installer_hash)
  compiler_tools::installer { $installer_package:
    installer_data  => $data,
  }

}