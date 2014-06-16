= RedStone Modules
The blueprint is largely based on upstream work from review.openstack.org/openstack-infra/config
We rely heavily on this project for kickoff of forj configuration.

If you want to develop like the OpenStack ® project, the “Redstone” blueprint is what you are after.

== forked modules ==
These modules were forked from upstream for customization specific to forj
configuration workflow.  We will work to upstream these modules.

# cdk_project
#: manage deployment configuration, simillar to openstack_project.  Filtered down
#: version.
# compiler_tools
#: re-write for slave.pp to be more general for tool chains required for 
#: all things compiles on ci servers.
# etherpad_config
#: etherpad deployment.
# gerrit_config
#: gerrit server deployment, includes additional classes for full server setup
#: without any manual steps.  Including bootstrapping with first user.
# jeepyb_config
#: jenkins job builder release, pined to forj specific release.
# jenkins_config
#: jenkins server.
# sysadmin_config
#: manage system configuration, ports / users.  To be refactored for Forj
#: puppet modules orchestration.
# graphite_config
#: provide statistics for tools
# pastebin_config
#: provide sharable code links 
# zuul_config
#: provide change request cordination

== Complementary modules ==
These modules are additions that were made to support contributions from 
forj and to help with demonstration of usage with 3rd party tools.
 
# fortify_cli
#: Install HP fortify command line scan tools.  Includes check script.
# java_ora
#: required by fortify_cli, java oracle sdk
# stackato_cli
#: Install stackato publishing tools for HP Cloud SaaS solution.
# nexus
#: Nexus artifact management system for managing tar files and packages

= License
 Copyright 2013 OpenStack Foundation.
 Copyright 2013 Hewlett-Packard Development Company, L.P.

 Licensed under the Apache License, Version 2.0 (the "License"); you may
 not use this file except in compliance with the License. You may obtain
 a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 License for the specific language governing permissions and limitations
 under the License.
