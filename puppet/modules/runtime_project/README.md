forj/runtime_project
=====================

Bootstrap the forj-config project for a given openstack forj.
The project will keep configuration needed for the CI system.
 
 
## Usage ##
   Other modules will utilize the files/templates via file template refrences.
   These mostly will come from cdk_project or openstack_project module.
   
   Example: cdk_project::gerrit uses it to call ::gerrit module as
   
   class { '::gerrit':
      ... removed....
      robots_txt_sourc=> "puppet:///modules/$runtime_module/gerrit/robots.txt",
      }
   here $runtime_module is replaced for runtime_project, and now files are
   used by forj-config project.
   
## Install ##

   include runtime_project::install
   
   We do this when we can provision our servers, so this gets setup on our .
   puppetmaster

   The gerrit server requires a new empty project called forj-config.

## Features ##

  - setup runtime_project module
  - commit a new repository to gerrit called forj-config
  - push new files/changes done on the file system for forj-config to the 
    project so that we see those in source.
  - puppet apply -e "class{'runtime_project::update':}"  updates redstone
    and tries to update the forj-config project

## Intended Audience ##
  runtime_project is intended to work with openstack flavor for forj.  Other 
  configurations with different scm's or different puppet manifest are not 
  currently in plan.  Feel free to use classes, techniques in other 
  implementations or forks.