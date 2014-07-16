aPaas
=========

What is it?
> Application platform as a service (aPaaS) is a cloud service that offers development and deployment 
> environments for application services. Magic Quadrant for Enterprise Application Platform as a Service.

Contents are divided per language that applies to your project(more to come!)

  - Ruby


Depencies
-----------

You need an aPaas provider account (currently supported)

* [HP Helion] - Hewlettt-Packard Helion aPaas
* [Stackato] -  ActiveState Stackato
* [CloudFoundry] - Cloud Foundry

Redstone forj:
* Your CI/CD node must have the CLIs(hdp, stackato, and cf) installed

Installation
--------------

##### Ruby


  Copy paas.rake and paas.yml to <your_project_root_dir>lib/tasks directory.  This includes the following tasks with pattern:

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
* The apaas CLI will depend on the provider. In the CI/CD node they will be installed under /usr/local/bin or /usr/bin. All you need to do is to provide the name (i.e. apaascli, stackato, hdp, etc...)

Usage
-----
    rake paas:target
    rake paas:login
    rake paas:deploy     

using a shell script (also a zuul macro/gate):

    if [ -f Rakefile ] ; then
        rake paas:target
        rake paas:login
        rake paas:deploy
    else
        echo "ERROR Rakefile not found"
        exit 1
     fi

License
----

 Apache License, Version 2.0


**Free Software, Hell Yeah!**

[HP Helion]:https://docs.hpcloud.com/apaas/
[Stackato]:http://www.activestate.com/stackato
[CloudFoundry]:http://docs.cloudfoundry.org/

