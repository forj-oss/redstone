# == runtime_project::push
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
# Check if status results in commits to be pushed and push them.
# Testing it:
#
define runtime_project::push(
  $repo = $title,
  $message = "init: commit for ${title}"
)
{
  include runtime_project::params
  $config_dir  = $runtime_project::params::gerrit_config_dir
  $config_spec ="${config_dir}/${runtime_project::params::gerrit_user}.config"
  $git_repo    = "${runtime_project::params::git_home}/${repo}/.git"
  $sshcmd      = "${runtime_project::params::ssh_cmd} -oStrictHostKeyChecking=no -i ${runtime_project::params::gerrit_pem} -p ${runtime_project::params::gerrit_port} ${runtime_project::params::gerrit_user}@${::runtime_gerrit_ip}"


  $commit_user  = $runtime_project::params::gerrit_username
  $commit_email = $runtime_project::params::gerrit_useremail
  $commit_auth  = "${commit_user} <${commit_email}>"

  if ($::runtime_gerrit_ip != UNDEF and $::runtime_gerrit_ip != '')
  {
    include runtime_project::account_config
    notice("gerrit url is available,
            check if file changes need to be made for ${repo}" )
    $git_projectlist_cmd = "${sshcmd} gerrit ls-projects"

    # setup email for commit
    exec { "push ${repo} : setup email ${commit_email}":
      path        => ['/bin', '/usr/bin'],
      command     => "git config user.email ${commit_email}",
      cwd         => "${runtime_project::params::git_home}/${repo}",
      environment => [ "GIT_SSH=${config_spec}" ],
      onlyif      => ["test -d ${git_repo}"],
      user        => 'puppet',
      require     => Class['runtime_project::account_config'],
    } ->
    # setup email for commit
    exec { "push ${repo} : setup username ${commit_user}":
      path        => ['/bin', '/usr/bin'],
      command     => "git config user.name '${commit_user}'",
      cwd         => "${runtime_project::params::git_home}/${repo}",
      environment => [ "GIT_SSH=${config_spec}" ],
      onlyif      => ["test -d ${git_repo}"],
      user        => 'puppet',
      require     => Class['runtime_project::account_config'],
    } ->

    # checkout master
    exec { "push ${repo} : checkout master for ${repo}":
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
    exec { "push ${repo} : pull project ${repo} if exists":
      path        => ['/bin', '/usr/bin'],
      command     => 'git pull origin master',
      cwd         => "${runtime_project::params::git_home}/${repo}",
      environment => [ "GIT_SSH=${config_spec}" ],
      onlyif      => ["test $(${sshcmd} -T > /dev/null 2<&1; echo $?) -eq 127",
                      "${git_projectlist_cmd}|grep ${repo}",
                      "test -d ${git_repo}"],
      user        => 'puppet',
      require     => Class['runtime_project::account_config'],
    } ->

    # execute add * for repo
    exec { "push ${repo} : add * for ${repo}":
      path        => ['/bin', '/usr/bin'],
      command     => 'git add *',
      cwd         => "${runtime_project::params::git_home}/${repo}",
      environment => [ "GIT_SSH=${config_spec}" ],
      onlyif      => ["test $(${sshcmd} -T > /dev/null 2<&1; echo $?) -eq 127",
                      "${git_projectlist_cmd}|grep ${repo}",
                      "test -d ${git_repo}"
                      ],
      user        => 'puppet',
      require     => Class['runtime_project::account_config'],
    } ->

    # commit if changes show status has commits
    # commit only if we have staged files.
    exec { "push ${repo} : commit for ${repo}":
      path        => ['/bin', '/usr/bin'],
      command     => "git commit -m \"${message}\" --author=\"${commit_auth}>\"",
      cwd         => "${runtime_project::params::git_home}/${repo}",
      environment => [ "GIT_SSH=${config_spec}" ],
      onlyif      => ["test $(${sshcmd} -T > /dev/null 2<&1; echo $?) -eq 127",
                      "${git_projectlist_cmd}|grep ${repo}",
                      "test -d ${git_repo}",
                      'test $(git diff --name-only --cached | wc -l) -gt 0'
                      ],
      user        => 'puppet',
      require     => Class['runtime_project::account_config'],
    } ->

    # push changes if commit will introduce new change
    # push only if we have commits not on the master
    # this commit will bypass gerrit review.
    exec { "push ${repo} : push project ${repo} if exists":
      path        => ['/bin', '/usr/bin'],
      command     => 'git push origin refs/heads/master',
      cwd         => "${runtime_project::params::git_home}/${repo}",
      environment => [ "GIT_SSH=${config_spec}" ],
      onlyif      => ["test $(${sshcmd} -T > /dev/null 2<&1; echo $?) -eq 127",
                      "${git_projectlist_cmd}|grep ${repo}",
                      "test -d ${git_repo}",
                      'test $(git log origin/master..master|grep \'^commit\'|wc -l) -gt 0'
                      ],
      user        => 'puppet',
      require     => Class['runtime_project::account_config'],
    }

  } else {
    notice("skipping runtime_project::push
            due to no gerrit_ip (${::runtime_gerrit_ip})")
  }
}
