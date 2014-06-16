# == Class: runtime_project::update
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
# This is an update manifest that will force
# a commit from redstone to forj-config project for small updates.
# intended to be used outside of puppet master, ie;
# export PUPPET_MODULES=/etc/puppet/modules:/opt/config/production/modules:\
#     /opt/config/production/git/redstone/puppet/modules
# puppet apply \
#        --modulepath=$PUPPET_MODULES -e "include runtime_project::update"
#
class runtime_project::update (
  $update_modules   = true,
  $update_manifests = false,
) {
  include runtime_project::params
  $config_root       = "/opt/config/${runtime_project::params::environment}"
  $root_cdkinfra     = "${config_root}/git/redstone"
  $cdkinfra_runtime  = 'puppet/modules/runtime_project'
  $cdkinfra_manifest = 'puppet/manifests'
  $repo              = $runtime_project::params::config_project
  runtime_project::clone{ $repo: }

  # updates for modules
  # only perform this work if there is a git repo
  $root_forjconfig = "${runtime_project::params::git_home}/${repo}"
  if $update_modules
  {
    $modules_dir = "${root_forjconfig}/modules"
    exec { "${repo} : update ${modules_dir}/runtime_project":
      path    => ['/bin', '/usr/bin'],
      command => "rsync -a ${root_cdkinfra}/${cdkinfra_runtime} ${modules_dir}",
      cwd     => $runtime_project::params::git_home,
      onlyif  => [
                  "test -d ${runtime_project::params::git_home}/${repo}",
                  "test -d ${runtime_project::params::git_home}/${repo}/.git",
                  ],
      user    => 'puppet',
      require => Runtime_project::Clone[$repo],
      before  => Runtime_project::Push[$repo],
    }
  }

  # updates for modules
  # only perform this work if there is a git repo
  $rsync_cmd = "rsync -a ${root_cdkinfra}/${cdkinfra_manifest} ${manifest_dir}"
  if $update_manifests
  {
    $manifest_dir = "${root_forjconfig}/manifests"
    exec { "${repo} : update ${manifest_dir}":
      path    => ['/bin', '/usr/bin'],
      command => $rsync_cmd,
      cwd     => $runtime_project::params::git_home,
      onlyif  => [
                  "test -d ${runtime_project::params::git_home}/${repo}",
                  "test -d ${runtime_project::params::git_home}/${repo}/.git",
                  ],
      user    => 'puppet',
      require => Runtime_project::Clone[$repo],
      before  => Runtime_project::Push[$repo],
    }
  }

  runtime_project::push{ $repo:
    message => 'manual update for repo using runtime_project::update',
  } ->
  runtime_project::pull{ $repo:}
}
