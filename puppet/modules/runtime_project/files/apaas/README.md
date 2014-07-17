aPaas
=========

What is it?
> Application platform as a service (aPaaS) is a cloud service that offers development and deployment
> environments for application services. Magic Quadrant for Enterprise Application Platform as a Service.

Contents are divided per language that applies to your project(more to come!). The intent here is to provide a simple wrapper of the aPaas CLIs to enable their use via project task runner tools (rake, grunt, make, gradle, maven, ant...)

  - Ruby


Overall process
----------
* If using a CLI wrapper, include it in your project otherwise use the aPaas CLIs directly in your zuul macro
* check in your project in your git repo
* setup a zuul publishing gate (involves creating a project, macro, and job)

Note: depending how you write your zuul macro to publish to your aPaas environment it can be reused in future projects

Depencies
-----------

You need an aPaas provider account (currently supported)

* [HP Helion] - Hewlettt-Packard Helion aPaas
* [Stackato] -  ActiveState Stackato
* [CloudFoundry] - Cloud Foundry

Redstone forj:
* Your CI/CD node must have the CLIs(hdp, stackato, and cf) installed
* [Redstone tools] - Redstone blueprint CI/CD tools

Integration
--------------

##### Ruby


  Copy paas.rake and paas.yaml to <your_project_root_dir>lib/tasks directory.  This includes the following tasks with pattern:

    paas:delete[app_name]   # delete app_name
    paas:deploy[app_name]   # application deployment - creates/updates application instance
    paas:info               # aPaas info
    paas:list               # list deployed applications
    paas:login              # aPaas login
    paas:restart[app_name]  # restart app_name
    paas:start[app_name]    # start app_name
    paas:stats[app_name]    # display resource usage for the application
    paas:stop[app_name]     # stop app_name
    paas:target             # Set apaas targer URL
    paas:update[app_name]   # application update


Edit the paas.yml to include your paas credentials, apaas target url, apaas flavor (supported: '
hp', 'stackato', 'cf'), and apaas cli path.

Note:
* The paas.rake file uses the paas.yml file to 'map' apaas CLI's commands to the rake tasks. Depending on the apaas provider's CLI you might have to edit this file. see the CLI's help.
* app_name  maps to the application name specified in your project's manifest.yml (this can also be the stackato.yml or apaascli.yml file - refer to your paas provider documentation)
* The apaas CLI will depend on the provider. In the CI/CD node they will be installed under /usr/local/bin or /usr/bin. All you need to do is to provide the name (i.e. hdp, stackato, cf, etc...)

Usage
-----
The below example uses parameters specified both in the rake task and paas.yaml

    rake paas:target
    rake paas:login
    rake paas:deploy

using a shell script (example in a zuul macro):
    - builder:
      name: apaas-deploy
      builders:
        - shell: |
            #!/bin/bash -xe
            if [ -f Rakefile ] ; then
                rake paas:target
                rake paas:login
                rake paas:deploy
            else
                echo "ERROR Rakefile not found"
                exit 1
            fi

* The zuul macro can be added to your for-config project by editing modules/runtime_project/files/jenkins_job_builder/config/macros.yaml
* Add a project and job entry in modules/runtime_project/files/jenkins_job_builder/config/projects.yaml (this will have all the jobs for the named project)


    - project:$
    name: myproject$
    git_project: myproject$
    branch: master$
    jobs:$
     - '{name}-maven-package'$
     - '{name}-apaas-deploy'$

* Configure zuul post gate for the project (modules/runtime_project/files/zuul/config/production/layout.yaml)


    projects:$
    - name: myproject$
    check:$
      - myproject-maven-package$
    gate:$
      - myproject-maven-package$
    post:$
      - myproject-apaas-deploy$


##### Generic project setup
The installed CLIs in the CI node can ofcourse be called directly in a custom jenkins job or zuul macro. HP Helion Development example:


    /usr/loca/bin/hdp target <apaas_url>
    /usr/local/bin/hdp login -n <user> --passwd <pwd>
    /usr/local/bin/hdp push

Note: target and login commands are idempotent, push will create a new application if it does not already exist, otherwise it will update. refer to the CLI help and/or reference docs.

License
----

 Apache License, Version 2.0


**Free Software, Hell Yeah!**

[HP Helion]:https://docs.hpcloud.com/apaas/
[Stackato]:http://www.activestate.com/stackato
[CloudFoundry]:http://docs.cloudfoundry.org/
[Redstone Tools]:http://docs.forj.io/en/latest/user/kits/redstone.html#tools-and-features
