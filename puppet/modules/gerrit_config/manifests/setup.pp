# == gerrit_config::setup
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
# gerrit utilities designed to work with ::gerrit module
# installation from openstack
#  TODO: contribute this to the gerrit project
#        once we opensource enable our project.
#

class gerrit_config::setup(
    $demo_enabled                   = false,
    $buglinks_enabled               = true,
    $require_contact_information    = 'N',
    $first_account_classes    = ['gerrit_config::firstopenidadmin'],
) {

  include gerrit_config::params

  class {'gerrit_config::connect_bugs':
        enabled => $buglinks_enabled,
  }

  class{'gerrit_config::createfirstaccount':
        gerrit_id => $gerrit_config::params::gerrit_user,
  } ->
  # make the first openid user an adminsitrator
  class {$first_account_classes:} ->
  class {'gerrit_config::adddemoids':
        enabled => $demo_enabled,
  } ->
  service { 'gerrit':
    ensure => running,
    enable => true,
  }

  # Below steps should not require a service restart.

  gerrit_config::create_group{'Project Bootstrappers':
        owner       => 'Administrators',
        member      => $gerrit_config::params::gerrit_user,
        description => 'Project creation group',
        isvisible   => true,
        require     => Service['gerrit'],
  } ->
  gerrit_config::create_group{'CLA Accepted - ICLA':
        owner       => 'Administrators',
        description => 'Users that accepted ICLA',
        isvisible   => true,
  } ->
  gerrit_config::create_group{'External Testing Tools':
        owner       => 'Administrators',
        description => 'Verification groupfor +1 / -1 testing',
        isvisible   => true,
  } ->
  gerrit_config::create_group{'Continuous Integration Tools':
        owner       => 'Administrators',
        description => 'CI tools for +2/-2 verification',
        isvisible   => true,
  } ->
  gerrit_config::create_group{'Release Managers':
        owner       => 'Project Bootstrappers',
        description => 'Release managers',
        isvisible   => true,
  } ->
  gerrit_config::create_group{'Stable Maintainers':
        owner       => 'Project Bootstrappers',
        description => 'Users that maintain stable branches',
        isvisible   => true,
  } ->
  # create all batch accounts for gerrit
  # Note, if a key has not been stored on the puppet master first, this will fail!
  # cacerts::sshgenkeys{'jenkins':  do_cacertsdb=>true}
  class {'gerrit_config::allprojects_acls_setup':} ->
  gerrit_config::createbatchaccount{'jenkins':
        fullname      => 'Jenkins',
        email_address => 'jenkins@localhost.org',
        group         => 'Continuous Integration Tools',
  } ->
  gerrit_config::createbatchaccount{'forjio':
        fullname      => 'Forj Configuration User',
        email_address => 'forjio@localhost.org',
        group         => 'Administrators', # after gerrit 2.7 we can do groups
  } ->
  file { '/tmp/post-configure.sh':
        ensure => 'present',
        mode   => '0744',
        source => 'puppet:///modules/gerrit_config/post-configure.sh',
  }
}
