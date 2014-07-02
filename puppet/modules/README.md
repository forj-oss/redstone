RedStone Modules
====

The blueprint is largely based on upstream work from review.openstack.org/openstack-infra/config, we rely heavily on this project for kickoff of forj configuration.

If you want to develop like the OpenStack ® project, the "Redstone" blueprint is what you are after

Forked modules
----

These modules were forked from upstream for customization specific to forj
configuration workflow.  We will work to upstream these modules.


CDK project
> Manage deployment configuration simillar to openstack_project filtered down version.

Compiler tools
> Re write for slave.pp to be more general for tool chains required for user content all things compiles on ci servers.

Etherpad config
> Etherpad is a highly customizable Open Source online editor providing collaborative editing in really real-time.

Gerrit config
> Gerrit server deployment, includes additional classes for full server setup without any manual steps.  Including bootstrapping with first use.

Github config
> Module to integrate github with your git projects and jeepyb

Graphite config
> It is compromised of two components – a webapp frontend and a backend storage application. It allows external application to feed monitoring data into it and then uses it’s “carbon” backend agent to process the data and store it in a specialized graphite database (eg: whisper).

Jeepyb config
> Jeepyb is a collection of tools which make managing Gerrit easier. Specifically, management of Gerrit projects and their associated upstream integration with things like Github and Launchpad.

Jenkins config
> Jenkins is an extendable open source continuous integration server, jenkins job builder release, pined to forj specific release.

Pastebin config
> Paste servers are an easy way to share long-form content such as configuration files or log data with others over short-form communication protocols such as IRC. OpenStack runs the lodgeit paste software

Runtime project
> We manage our configuration for ci with this module, so it provides an entry point for several ci based configuration that is specific to a running forj instance.

> The site.pp and other modules can then rely on this module to be superseeded by the local instance when it\'s populated from source.
> Configuration can then later be merged to match up for newer features / options.

Zuul config
> Zuul is a pipeline-oriented project gating system. It facilitates running tests and automated tasks in response to Gerrit events.


== Complementary modules ==
-------
These modules are additions that were made to support contributions from forj and to help with demonstration of usage with 3rd party tools.

Fortify cli
> This scan tool will perform a static analysis on a set of source-code input files.
The tool can analyze either a single file, or an entire application consisting of many files.

Java ora
> This module contains the java oracle sdk.

Stackato cli
> Install stackato publishing tools for HP Cloud SaaS solution.

Nexus
> Nexus is a repository manager that stores and organizes binary software components for use in development, deployment, and provisioning.
Repository managers serve four primary purposess:
 - Provides a central point for management of binary software components and their dependencies
 - Provides a solid component repository for a complete Component Lifecycle Management approach
 - Acts as highly configurable proxy between your organization and public repositories
 - Provides a deployment destination for internally developed binary components'


License
--------
Copyright 2013 OpenStack Foundation.

Copyright 2013 Hewlett-Packard Development Company, L.P.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at


          http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations
under the License.

