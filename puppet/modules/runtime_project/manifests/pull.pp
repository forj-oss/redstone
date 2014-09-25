# == runtime_project::pull
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
# Perform a git pull on the provided gerrit project.
# reset if true.
# Testing it:
#
define runtime_project::pull(
  $repo    = $title,
  $doreset = true,
)
{
  include runtime_project::params
  $config_dir  = $runtime_project::params::gerrit_config_dir
  $config_spec ="${config_dir}/${runtime_project::params::gerrit_user}.config"
  $git_repo    = "${runtime_project::params::git_home}/${repo}/.git"
  $sshcmd      = "${runtime_project::params::ssh_cmd} -oStrictHostKeyChecking=no -i ${runtime_project::params::gerrit_pem} -p ${runtime_project::params::gerrit_port} ${runtime_project::params::gerrit_user}@${::runtime_gerrit_ip}"


  if ($::runtime_gerrit_ip != UNDEF and $::runtime_gerrit_ip != '')
  {
    include runtime_project::account_config
    notice("gerrit url is available, check if file changes need to be made for
            ${repo}"
    )
    $git_projectlist_cmd = "${sshcmd} gerrit ls-projects"

    if ( $doreset == true)
    {
        # pull latest changes to make sure everything is up to date
        exec { "pull ${repo} : reset hard project ${repo} if exists":
            path        => ['/bin', '/usr/bin'],
            command     => 'git reset --hard origin/master',
            cwd         => "${runtime_project::params::git_home}/${repo}",
            environment => [ "GIT_SSH=${config_spec}" ],
            onlyif      => ["test $(${sshcmd} -T > /dev/null 2<&1; echo $?) -eq 127",
                            "${git_projectlist_cmd}|grep ${repo}",
                            "test -d ${git_repo}"],
            user        => 'puppet',
            require     => Class['runtime_project::account_config'],
        } ->
        # checkout master
        exec { "pull ${repo} : checkout master for ${repo}":
          path        => ['/bin', '/usr/bin'],
          command     => 'git checkout master',
          cwd         => "${runtime_project::params::git_home}/${repo}",
          environment => [ "GIT_SSH=${config_spec}" ],
          onlyif      => ["test $(${sshcmd} -T > /dev/null 2<&1; echo $?) -eq 127",
                          "${git_projectlist_cmd}|grep ${repo}",
                          "test -d ${git_repo}"],
          user        => 'puppet',
          require     => Class['runtime_project::account_config'],
        } ->
        # pull latest changes to make sure everything is up to date
        exec { "pull ${repo} : pull project ${repo} after reset if exists":
          path        => ['/bin', '/usr/bin'],
          command     => 'git pull origin master',
          cwd         => "${runtime_project::params::git_home}/${repo}",
          environment => [ "GIT_SSH=${config_spec}" ],
          onlyif      => ["test $(${sshcmd} -T > /dev/null 2<&1; echo $?) -eq 127",
                          "${git_projectlist_cmd}|grep ${repo}",
                          "test -d ${git_repo}"],
          user        => 'puppet',
          require     => Class['runtime_project::account_config'],
        }
    } else
    {
        # checkout master
        exec { "pull ${repo} : checkout master for ${repo}":
          path        => ['/bin', '/usr/bin'],
          command     => 'git checkout master',
          cwd         => "${runtime_project::params::git_home}/${repo}",
          environment => [ "GIT_SSH=${config_spec}" ],
          onlyif      => ["test $(${sshcmd} -T > /dev/null 2<&1; echo $?) -eq 127",
                          "${git_projectlist_cmd}|grep ${repo}",
                          "test -d ${git_repo}"],
          user        => 'puppet',
          require     => Class['runtime_project::account_config'],
        } ->
        # pull latest changes to make sure everything is up to date
        exec { "pull ${repo} : pull project ${repo} if exists":
          path        => ['/bin', '/usr/bin'],
          command     => 'git pull origin master',
          cwd         => "${runtime_project::params::git_home}/${repo}",
          environment => [ "GIT_SSH=${config_spec}" ],
          onlyif      => ["test $(${sshcmd} -T > /dev/null 2<&1; echo $?) -eq 127",
                          "${git_projectlist_cmd}|grep ${repo}",
                          "test -d ${git_repo}"],
          user        => 'puppet',
          require     => Class['runtime_project::account_config'],
        }
    }
  } else {
    notice("skipping runtime_project::pull
                due to no gerrit_ip (${::runtime_gerrit_ip})")
  }
}
