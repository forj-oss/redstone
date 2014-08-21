# Resource: nexus::artifact

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
# This resource downloads Maven Artifacts from Nexus
#
# Parameters:
# [*gav*] : The artifact groupid:artifactid:version (mandatory)
# [*packaging*] : The packaging type (jar by default)
# [*classifier*] : The classifier (no classifier by default)
# [*repository*] : The repository such as 'public', 'central'...(mandatory)
# [*output*] : The output file (mandatory)
# [*ensure*] : If 'present' checks the existence of the output file (and downloads it if needed), if 'absent' deletes the output file, if not set redownload the artifact
# [*timeout*] : Optional timeout for download exec. 0 disables - see exec for default.
# [*owner*] : Optional user to own the file
# [*group*] : Optional group to own the file
# [*mode*] : Optional mode for file
#
# Actions:
# If ensure is set to 'present' the resource checks the existence of the file and download the artifact if needed.
# If ensure is set to 'absent' the resource deleted the output file.
# If ensure is not set or set to 'update', the artifact is re-downloaded.
#
# Init Sample Usage:
#  class nexus {
#   url => http://edge.spree.de/nexus,
#   username => user,
#   password => password
# }
#
define nexus::artifact(
  $gav,
  $repository,
  $output,
  $classifier    = '',
  $packaging     = 'jar',
  $ensure        = update,
  $timeout       = undef,
  $owner         = undef,
  $group         = undef,
  $mode          = undef,
  $nexus_server  = hiera('nexus::artifact::nexus_server', undef),
) {

  if ( $nexus_server == undef)
  {
    fail('please provide a nexus server for us to use in agruments for nexus::artifact::nexus_server.')
  }
  if ! defined(Class['nexus']) {
    class {'nexus':url => $nexus_server}
  }

  if ($nexus::authentication) {
    $args = "-u ${nexus::user} -p '${nexus::pwd}'"
  } else {
    $args = ''
  }

  if ($classifier) {
    $includeClass = "-c ${classifier}"
  }

# root path /opt/config set in nexus class
  $cmd = "/opt/config/${::environment}/scripts/download-artifact-from-nexus.sh -a ${gav} -e ${packaging} ${includeClass} -n ${nexus::nexus_url} -r ${repository} -o ${output} ${args} -v"

  if (($ensure == update) and ($gav =~ /-SNAPSHOT/)) {
    exec { "Checking ${gav}-${classifier}":
      command => "${cmd} -z",
      timeout => $timeout,
      before  => Exec["Download ${gav}-${classifier}"],
    }
  }

  if $ensure == present {
    exec { "Download ${gav}-${classifier}":
      command => $cmd,
      creates => $output,
      timeout => $timeout,
    }
  } elsif $ensure == absent {
    file { "Remove ${gav}-${classifier}":
      ensure => absent,
      path   => $output,
    }
  } else {
    exec { "Download ${gav}-${classifier}":
      command => $cmd,
      timeout => $timeout,
    }
  }

    if $ensure != absent {
      file { $output:
        ensure  => file,
        require => Exec["Download ${gav}-${classifier}"],
        owner   => $owner,
        group   => $group,
        mode    => $mode,
      }
    }
}
