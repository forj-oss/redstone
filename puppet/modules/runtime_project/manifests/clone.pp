# == runtime_project::clone
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
# Copyright 2012 Hewlett-Packard Development Company, L.P
# Check to see if the forj-config project in gerrit is missing.
# If it is, use this information to trigger the installation of the contents
# of the forj-config project within gerrit.
# Testing it:
#
define runtime_project::clone(
  $repo = $title,
)
{
  include runtime_project::params
  $config_dir  = $runtime_project::params::gerrit_config_dir
  $config_spec = "${config_dir}/${runtime_project::params::gerrit_user}.config"
  $git_repo    = "${runtime_project::params::git_home}/${repo}/.git"
  $sshcmd      = "${runtime_project::params::ssh_cmd} -oStrictHostKeyChecking=no -i ${runtime_project::params::gerrit_pem} -p ${runtime_project::params::gerrit_port} ${runtime_project::params::gerrit_user}@${::runtime_gerrit_ip}"

  if ($::runtime_gerrit_ip != UNDEF and $::runtime_gerrit_ip != '')
  {
    include runtime_project::account_config
    notice("gerrit url is available, check if ${repo} exist" )

    if ! defined(File[$runtime_project::params::git_home])
    {
      file { $runtime_project::params::git_home:
        ensure => directory,
        owner  => 'puppet',
        group  => 'puppet',
        mode   => '2775',
      }
    }

    # verify that we can connect to the gerrit server
    # check if gerrit project exist
    # verify the git repo is not already checked out
    exec { "clone ${repo} : clone project ${repo} if exists":
      path        => ['/bin', '/usr/bin'],
      command     => "git clone ssh://${runtime_project::params::gerrit_user}@${::runtime_gerrit_ip}/${repo}",
      cwd         => $runtime_project::params::git_home,
      environment => [ "GIT_SSH=${config_spec}" ],
      onlyif      => [ "test $(${sshcmd} -T > /dev/null 2<&1; echo $?) -eq 127",
                        "${sshcmd} gerrit ls-projects|grep ${repo}",
                        "test ! -d  ${git_repo}" ],
      user        => 'puppet',
      require     => [ Class['runtime_project::account_config'],
                        File[$runtime_project::params::git_home] ],
    }

  } else {
    notice("skipping runtime_project::clone
             due to no gerrit_ip (${::runtime_gerrit_ip})")
  }
}
