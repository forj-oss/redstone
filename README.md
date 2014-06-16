
This repository contains code used by FORJ (http://forj.io) to implement the Openstack development model (http://ci.openstack.org/) as RedStone blueprint.

The current version implements the following development services:

|| |
|------------------------------------------|-------------------------------------------------------|
| Source control management                | [git](http://git-scm.com/)                            |
| Code Review.                             | [gerrit](https://code.google.com/p/gerrit/)           |
| build system & Continuous integration.   | [jenkins](http://jenkins-ci.org/)                     |
| an openstack implementation of pastebin. | [lodgeit](https://bitbucket.org/dcolish/lodgeit-main) |
| build automation gating system.          | [zuul](http://launchpad.net/zuul)                     |
| Contribution statistics                  | [graphite](http://graphite.openstack.org)             |


RedStone Blueprint definition:
--------------------------------------

The description of this blueprint is detailled in 'redstone-master.yaml' located in the <repo-root>/forj/ directory.

It describes the following:

- Collection of tools
   * git/gerrit : http://ci.openstack.org/gerrit.html
   * jenkins    : http://ci.openstack.org/jenkins.html
   * zuul       : http://ci.openstack.org/zuul.html
   * lodgeit    : http://ci.openstack.org/paste.html
   * graphite   : http://graphite.openstack.org
- 'A la openstack' development flow
  
  This blueprint implements a complete development process, based on continuous integration, and code review.
  This process also manages projects in each tool (like creating a repository in git/gerrit)

- Blueprint Deployement automation

  Similar to the operation of the original openstack team, your RedStone infrastructure is going to be maintained by puppet modules and manifests. 
  Most of this code is stored under <repo-root>/puppet directory
  
  Each tool is defined as a collections of puppet modules and manifest. The blueprint definition file (openstack-master.yaml) associates those modules to each tool.

- Blueprint data and management
  
  This blueprint introduces the notion of project.
  an RedStone project is a git/gerrit repository, collection of zuul gates and jenkins jobs. Any project created/deleted are controled by forj-config git/gerrit repo and implement a review control on these updates by a core team thanks to gerrit.

- Documentation

  It contains a simple tutorial to learn on this blueprint by example, and a lot of references about tools installed.

RedStone deployement:
-----------------------------

When you want to deploy this blueprint, you will need to define where those services will be hosted. At least, you will need 2 files.

- /opt/config/production/fog/cloud.conf

  This is a fog configuration file to define Cloud or baremetal information like credential, cloud provider,...
  
  More information from http://fog.io/about/provider_documentation.html

- <repo-root>/forj/...-layout.yaml

  This file defines the list of servers (name, size, etc...) to host services (tools installed and configured)

An example of this layout in located under <repo-root>/forj/openstack-layout.yaml

In order to implement this blueprint layout, you will need the FORJ puppet orchestrator box, named **Maestro**.

You can install it from **<...>**

To deploy your own layout, create a copy of 'redstone-layout.yaml', update it as needed and ask **Maestro** to deploy it.


What 'redstone-layout.yaml' example will deploy:
=================================================

This example layout file was designed to deploy 3 boxes.
The current version of this repository configures your cloud with the following servers/services:

servers
-------

*  review (size small)
   * git        : http://ci.openstack.org/git.html
   * gerrit     : http://ci.openstack.org/gerrit.html
* ci (size small)
   * jenkins    : http://ci.openstack.org/jenkins.html
   * zuul       : http://ci.openstack.org/zuul.html
* util (size small)
   * lodgeit    : http://ci.openstack.org/paste.html
   * graphite   : http://graphite.openstack.org

This blueprint exposes services and RedStone project management to maestro in order to facilitate the development management.

Repository hierarchy:
=====================

 - forj/           : blueprint description. Contains the blueprint definition(master) and a deployement example file (layout)
 - puppet/modules  : puppet modules
 - puppet/manifest : puppet manifest
 
 
License
=====================
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
