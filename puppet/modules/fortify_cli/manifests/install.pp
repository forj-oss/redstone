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
#
#
# depends on puppetlabs/stdlib (https://forge.puppetlabs.com/puppetlabs/stdlib)
#
class fortify_cli::install() inherits fortify_cli::base_env {

  #setup global path settings
  #Commenting this line because it is duplicated in nexus::artifact
  #class {'nexus': url=>'http://nexus.cdkdev.org:8080/nexus', }

  #check if we are using windoez
  $a = $::osfamily
  if $a == 'windows' {
    fail('windows OS is not supported')
  }

  # you can never be too careful...
  if ! defined(File['/tmp']) {
      file { '/tmp' : ensure => directory }
  }

  if ! defined(File['/etc']) {
      file { '/etc' : ensure => directory }
  }

  if ! defined(File['/etc/profile.d']) {
      file { '/etc/profile.d' : ensure => directory }
  }


  # grab some artifacts from nexus
  notify {'fetching fortify artifact...':} ->

  nexus::artifact {'fortify SCA 3.8':
      ensure     => present,
      gav        => 'org.cdkdev.fortify:Fortify_SCA-x64:3.8',
      packaging  => 'run',
      repository => 'cdk-content',
      output     => '/tmp/Fortify_SCA-x64.run',
      timeout    => 600,
      owner      => 'root',
      group      => 'root',
      mode       => 0755
  } ->

  notify {'fetching fortify license...': } ->

  nexus::artifact {'fortify SCA 3.8 license':
        ensure     => present,
        gav        => 'org.cdkdev.fortify:fortify.license:3.8',
        packaging  => 'license',
        repository => 'cdk-content',
        output     => '/tmp/fortify.license',
        timeout    => 600,
        owner      => 'root',
        group      => 'root',
        mode       => 0755
  } ->

  file { '/tmp/sca-silent.txt':
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          source  => 'puppet:///modules/fortify_cli/data/sca-silent.txt',
          require => File['/tmp']
  } ->

  file { '/tmp/install-sca.sh':
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          source  => 'puppet:///modules/fortify_cli/scripts/install-sca.sh',
          require => File['/tmp/sca-silent.txt']
  }


  exec { 'install fortify sca...':
          command => '/tmp/install-sca.sh >> /tmp/fortify.log',
          unless  => '/bin/cat /tmp/fortify.log | grep Successfully',
          require => File['/tmp/install-sca.sh']
  } ->

  #Java was throwing this error: No such file or directory
  package{'libc6-i386':
      ensure => present,
  } ->

  # setup a friendly symlink to avoid ugly paths
  file { '/opt/fortify':
          ensure => 'link',
          target => '/opt/HP_Fortify/HP_Fortify_SCA_and_Apps_3.80/',
  } ->

  file { '/etc/profile.d/setup_fortify_path.sh':
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          source  => 'puppet:///modules/fortify_cli/scripts/setup_fortify_path.sh',
  } ->

  exec { 'fortify update...':
          command => '/opt/fortify/bin/fortifyupdate >> /tmp/fortifyupdate.log',
          unless  => '/bin/cat /tmp/fortifyupdate.log | grep \'up to date\'',
          require => File['/tmp/install-sca.sh'],
  }
  #->
  #exec { '/bin/rm /tmp/Fortify_SCA-x64.run':
  #       require => Exec['install fortify sca...']
  #}

}
