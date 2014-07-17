# == gerrit_config::allprojects_acls_setup
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
# Setup the default acl's for all projects.
#
#
class gerrit_config::allprojects_acls_setup (
  $environment        = $settings::environment,
  $debug_flag         = false,
  $allprojects_config = hiera('gerrit_config::allprojects_config', 'puppet:///modules/runtime_project/gerrit/acls/production/allprojects_default.project.config'),
)
{
  include gerrit_config::params
  include gerrit_config::pyscripts

  if($debug_flag)
  {
    $debug_opts = '--loglevel debug'
  }
  else
  {
    $debug_opts = ''
  }

# create folder if missing

  file { ['/home/gerrit2/workspace' , '/home/gerrit2/workspace/All-Projects']:
        ensure  => directory,
        owner   => 'gerrit2',
        group   => 'gerrit2',
        mode    => '0755',
        recurse => true,
    } ->
# checkout project if missing
  exec { 'All-Projects .git init':
        path    => ['/bin', '/usr/bin'],
        command => 'git init',
        cwd     => '/home/gerrit2/workspace/All-Projects',
        onlyif  => 'test ! -d /home/gerrit2/workspace/All-Projects/.git',
    } ->
  exec { 'Add gerrit remote for All-Projects':
        path    => ['/bin', '/usr/bin'],
        command => 'git remote add gerrit file:///home/gerrit2/review_site/git/All-Projects.git',
        cwd     => '/home/gerrit2/workspace/All-Projects',
        onlyif  => 'test $(git remote -v|grep gerrit|wc -l) -le 0',
    } ->
  exec { 'fetch All-Project head':
        path    => ['/bin', '/usr/bin'],
        command => 'git fetch gerrit +refs/meta/*:refs/remotes/gerrit-meta/*',
        cwd     => '/home/gerrit2/workspace/All-Projects',
  } ->
  exec { 'checkout All-Project head':
        path    => ['/bin', '/usr/bin'],
        command => 'git checkout -b config remotes/gerrit-meta/config',
        cwd     => '/home/gerrit2/workspace/All-Projects',
        onlyif  => 'test $(git branch | wc -l) -le 0'
  } ->
# add remote if missing

# setup default project config

  file { '/home/gerrit2/workspace/All-Projects/project.config':
      ensure  => present,
      owner   => 'gerrit2',
      group   => 'gerrit2',
      mode    => '0444',
      source  => $allprojects_config,
      replace => true,
    } ->

#setup default groups
  notify{$gerrit_config::params::gerrit_local_gsql:} ->
  exec { 'get groups json':
        path    => ['/bin', '/usr/bin'],
        command => "${gerrit_config::params::gerrit_local_gsql} --format JSON -c 'select group_uuid, name from account_groups where not name like \"%-core\" order by group_uuid;' > /tmp/groups.json",
  } ->
  file { '/home/gerrit2/workspace/All-Projects/groups':
      ensure  => present,
      owner   => 'gerrit2',
      group   => 'gerrit2',
      mode    => '0444',
      source  => 'puppet:///modules/gerrit_config/default.groups',
      replace => true,
    } ->
  exec { 'groups json to tab format':
        path    => ['/bin', '/usr/bin'],
        command => "cat /tmp/groups.json | sed 's/\",\"/\":\"/g'|grep '\"row\"'|awk -F '\":\"' '{print \$4\"\t\"\$6}'|sed 's/\"}}\$//g'>> groups",
        cwd     => '/home/gerrit2/workspace/All-Projects',
  }

  exec { 'add All-Project project.config':
        path        => ['/bin', '/usr/bin'],
        command     => 'git add project.config',
        cwd         => '/home/gerrit2/workspace/All-Projects',
        onlyif      => 'test $(git diff project.config | wc -l) -gt 0',
        require     => File['/home/gerrit2/workspace/All-Projects/project.config'],
        refreshonly => true,
        subscribe   => File['/home/gerrit2/workspace/All-Projects/project.config']
  }

  exec { 'add All-Project groups':
        path        => ['/bin', '/usr/bin'],
        command     => 'git add groups',
        cwd         => '/home/gerrit2/workspace/All-Projects',
        onlyif      => 'test $(git diff groups | wc -l) -gt 0',
        require     => Exec['groups json to tab format'],
        refreshonly => true,
        subscribe   => Exec['groups json to tab format']
  }

  exec { 'commit All-Project':
        path        => ['/bin', '/usr/bin'],
        command     => 'git commit -am "puppet run commit to apply default acls on all-projects"',
        cwd         => '/home/gerrit2/workspace/All-Projects',
        refreshonly => true,
        onlyif      => 'test $(git status -s|grep "^M" | wc -l) -gt 0',
        require     => [
                        Exec['add All-Project project.config'],
                        Exec['add All-Project groups'],
                      ],
        subscribe   => [
                        Exec['add All-Project project.config'],
                        Exec['add All-Project groups'],
                      ]
  }

  exec { 'push All-Project':
        path        => ['/bin', '/usr/bin'],
        command     => 'git push gerrit HEAD:refs/meta/config',
        cwd         => '/home/gerrit2/workspace/All-Projects',
        onlyif      => 'test $(git branch -r --contains $(git rev-parse HEAD) | wc -l) -le 0',
        require     => Exec['commit All-Project'],
  }

}