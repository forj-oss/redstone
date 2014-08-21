# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
#
# depends on puppetlabs/stdlib (https://forge.puppetlabs.com/puppetlabs/stdlib)
#
class stackato_cli::install(
  $execshell = true,
  $clipath   = undef,
) inherits stackato_cli::base_env {

  #setup global path settings
  include stackato_cli::shell

  if ! defined(Package['unzip']) {
    package { 'unzip':
      ensure => present,
    }
  }

  nexus::artifact {'stackato':
    ensure     => present,
    gav        => 'org.cdkdev:stackato:1.7.4',
    classifier => 'x86_64',
    packaging  => 'zip',
    repository => 'cdk-content',
    output     => '/tmp/stackato-1.7.4-linux-glibc2.3-x86_64.zip',
    timeout    => 600,
    owner      => 'root',
    group      => 'root',
    mode       => 0755,
    require    => Package['unzip'],
  }

  if $execshell != true {
    #check if we are using windoez
    $a = $::osfamily
    if $a == 'windows' {
      fail('windows OS is not supported')
    }

  } else {
    notice('executing shell!...')

    if !empty($clipath) {
      exec { 'stackato-install-shell':
        command => 'stackato-install.sh',
        path    => $clipath,
        require => File['/tmp/stackato-1.7.4-linux-glibc2.3-x86_64.zip'],
      }
    } else {
      file { '/tmp/stackato-install.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('stackato_cli/scripts/stackato-install.sh.erb'),
        require => Nexus::Artifact['stackato'],
      }

      # uses the globally specified path
      exec { 'stackato-install-shell':
        command => '/tmp/stackato-install.sh >> /tmp/stackato.log',
        require => File['/tmp/stackato-install.sh'],
        creates => '/usr/local/bin/stackato-1.7.4-linux-glibc2.3-x86_64',
      }
    }
  }
}