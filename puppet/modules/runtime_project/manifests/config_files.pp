# == runtime_project::config_files
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
# Setup the runtime_project configuration files into the target repo
# if they are missing
# Testing it:
#
define runtime_project::config_files(
  $repo = $title,
)
{
  include runtime_project::params
  $repo_dir = "${runtime_project::params::git_home}/${repo}"
  $git_repo = "${repo_dir}/.git"


  $config_root       = "/opt/config/${runtime_project::params::environment}"
  $root_cdkinfra     = "${config_root}/git/redstone"
  $root_maestro      = "${config_root}/git/maestro"
  $cdkinfra_runtime  = 'puppet/modules/runtime_project'
  $cdkinfra_manifest = 'puppet/manifests'

  # if modules/runtime_project folder is missing copy over
  # modules/runtime_project only perform this work if there is a git repo
  $make_modules = "mkdir -p ${repo_dir}/modules"
  $modules_dir  = "${repo_dir}/modules"
  $sync_modules = "rsync -a ${root_cdkinfra}/${cdkinfra_runtime} ${modules_dir}"

  exec { "${repo} : initialize ${repo_dir}/modules/runtime_project":
    path    => ['/bin', '/usr/bin'],
    command => "${make_modules};${sync_modules}",
    cwd     => $runtime_project::params::git_home,
    onlyif  => [
                  "test -d ${repo_dir}",
                  "test -d ${git_repo}",
                  "test ! -d ${repo_dir}/modules/runtime_project"
                ],
    user    => 'puppet',
  }

  # only perform this work if there is a git repo
  $make_repo = "mkdir -p ${repo_dir}"
  $sync_repo = "rsync -a ${root_maestro}/${cdkinfra_manifest} ${repo_dir}"
  $sync_cmd = "${make_repo};${sync_repo}"
  exec { "${repo} : initialize ${repo_dir}/manifests":
    path    => ['/bin', '/usr/bin'],
    command => $sync_cmd,
    cwd     => $runtime_project::params::git_home,
    onlyif  => [
                  "test -d ${repo_dir}",
                  "test -d ${git_repo}",
                  "test ! -d ${repo_dir}/manifests"
                ],
    user    => 'puppet',
    require => Exec["${repo} : initialize ${repo_dir}/modules/runtime_project"],
  }

  # only perform this work if there is a git repo
  $rakespec_source = "${root_cdkinfra}/${cdkinfra_runtime}/Rakefile"
  $sync_rakespec = "rsync -a ${rakespec_source} ${repo_dir}/Rakefile"
  exec { "${repo} : initialize ${repo_dir}/Rakefile":
    path    => ['/bin', '/usr/bin'],
    command => $sync_rakespec,
    cwd     => $runtime_project::params::git_home,
    onlyif  => [
                  "test -d ${repo_dir}",
                  "test -d ${git_repo}",
                  "test ! -e ${repo_dir}/Rakefile"
                ],
    user    => 'puppet',
    require => Exec["${repo} : initialize ${repo_dir}/manifests"],
  }

  # Setup link for subsequent runs
  $runtime_exists = str2bool(inline_template("<%= File.exists?('${repo_dir}/manifests/site.pp') %>"))
  if $runtime_exists {
    file { "${runtime_project::params::config_home}/puppet":
      ensure => 'link',
      target => $repo_dir,
      force  => true,
      owner  => 'puppet',
      group  => 'puppet',
    }
  } else {
      notice('skipping setting up link till site.pp
              exists in manifests folder.')
  }
}
