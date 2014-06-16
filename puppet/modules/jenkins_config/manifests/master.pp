# == Class: jenkins::master
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
#
class jenkins_config::master(
  $logo = hiera('jenkins_config::master::logo', 'puppet:///modules/jenkins_config/openstack.png'),
  $vhost_name = $::fqdn,
  $serveradmin = "webmaster@${::domain}",
  $ssl_cert_file = '',
  $ssl_key_file = '',
  $ssl_chain_file = '',
  $ssl_cert_file_contents = '', # If left empty puppet will not create file.
  $ssl_key_file_contents = '', # If left empty puppet will not create file.
  $ssl_chain_file_contents = '', # If left empty puppet will not create file.
  $jenkins_ssh_private_key = '',
  $jenkins_ssh_public_key = '',
  $jenkins_version = hiera('jenkins_config::master::jenkins_version',present),
  $jenkins_dpkg_repo = hiera('jenkins_config::master::jenkins_dpkg_repo','stable'), # should be a url, latest, or stable.
) {
  include pip::python2
  include apt
  include apache
  include jenkins_config::params

  exec { 'apt-get clean':
      path     => '/bin:/usr/bin',
      command  => 'apt-get clean',
  }

  exec { 'apt-get update cache':
    path        => '/bin:/usr/bin',
    command     => 'apt-get update',
  }

  package { 'openjdk-7-jre-headless':
    ensure => present,
  }

  package { 'openjdk-6-jre-headless':
    ensure  => purged,
    require => Package['openjdk-7-jre-headless'],
  }

  case $jenkins_dpkg_repo {
    /^(stable|STABLE|Stable)$/: { $jenkins_repo = 'http://pkg.jenkins-ci.org/debian-stable'  }
    /^(latest|LATEST|Latest|master)$/:{ $jenkins_repo = 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key'  }
    '': { $jenkins_repo = 'http://pkg.jenkins-ci.org/debian-stable'  }
    undef: { $jenkins_repo = 'http://pkg.jenkins-ci.org/debian-stable'  }
    default:            { $jenkins_repo = $jenkins_dpkg_repo } # it's not empty, stable, latest, so it must be a url...
  }
  #This key is at http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key
  apt::key { 'jenkins':
    key        => 'D50582E6',
    key_source => "${jenkins_repo}/jenkins-ci.org.key",
    require    => Package['wget'],
  }

  apt::source { 'jenkins':
    location    => $jenkins_repo,
    release     => 'binary/',
    repos       => '',
    require     => [
      Apt::Key['jenkins'],
      Package['openjdk-7-jre-headless'],
    ],
    include_src => false,
  }

  apache::vhost { "jenkins-${vhost_name}":
    port     => 443,
    docroot  => 'MEANINGLESS ARGUMENT',
    priority => '50',
    template => 'jenkins_config/jenkins.vhost.erb',
    ssl      => true,
  }
#  a2mod { 'rewrite':
#    ensure => present,
#  }
#  a2mod { 'proxy':
#    ensure => present,
#  }
#  a2mod { 'proxy_http':
#    ensure => present,
#  }

  if $ssl_cert_file_contents != '' {
    file { $ssl_cert_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $ssl_cert_file_contents,
      before  => Apache::Vhost[$vhost_name],
    }
  }

  if $ssl_key_file_contents != '' {
    file { $ssl_key_file:
      owner   => 'root',
      group   => 'ssl-cert',
      mode    => '0640',
      content => $ssl_key_file_contents,
      require => Package['ssl-cert'],
      before  => Apache::Vhost[$vhost_name],
    }
  }

  if $ssl_chain_file_contents != '' {
    file { $ssl_chain_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $ssl_chain_file_contents,
      before  => Apache::Vhost[$vhost_name],
    }
  }

  $packages = [
    'python-babel',
    'python-sqlalchemy',  # devstack-gate
    'ssl-cert',
    'sqlite3', # interact with devstack-gate DB
    $::jenkins_config::params::maven_package,
  ]

  package { $packages:
    ensure => present,
  }

  file { '/var/run/jenkins':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'nogroup',
    mode    => '0700',
    require => Apt::Source['jenkins'],
  }

  package { 'jenkins':
    ensure  => $jenkins_version,
    require => Apt::Source['jenkins'],
  }

  exec { 'update apt cache':
    subscribe   => File['/etc/apt/sources.list.d/jenkins.list'],
    refreshonly => true,
    path        => '/bin:/usr/bin',
    command     => 'apt-get update',
  }

  file { '/var/lib/jenkins':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'adm',
    require => Package['jenkins'],
  }

  file { '/var/lib/jenkins/.ssh/':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'nogroup',
    mode    => '0700',
    require => File['/var/lib/jenkins'],
  }

  # file { '/var/lib/jenkins/.ssh/id_rsa':
    # owner   => 'jenkins',
    # group   => 'nogroup',
    # mode    => '0600',
    # content => $jenkins_ssh_private_key,
    # replace => true,
    # require => File['/var/lib/jenkins/.ssh/'],
  # }
  file { '/home/jenkins/.ssh/id_rsa':
    owner   => 'jenkins',
    group   => 'nogroup',
    mode    => '0600',
    content => $jenkins_ssh_private_key,
    replace => true,
    require => File['/home/jenkins/.ssh/'],
  }

  # file { '/var/lib/jenkins/.ssh/id_rsa.pub':
    # owner   => 'jenkins',
    # group   => 'nogroup',
    # mode    => '0644',
    # content => $jenkins_ssh_public_key,
    # replace => true,
    # require => File['/var/lib/jenkins/.ssh/'],
  # }
  file { '/home/jenkins/.ssh/id_rsa.pub':
    owner   => 'jenkins',
    group   => 'nogroup',
    mode    => '0644',
    content => $jenkins_ssh_public_key,
    replace => true,
    require => File['/home/jenkins/.ssh/'],
  }


  file { '/var/lib/jenkins/plugins':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'nogroup',
    mode    => '0750',
    require => File['/var/lib/jenkins'],
  }

  file { '/var/lib/jenkins/plugins/simple-theme-plugin':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'nogroup',
    require => File['/var/lib/jenkins/plugins'],
  }

  file { '/var/lib/jenkins/plugins/simple-theme-plugin/openstack.css':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'nogroup',
    source  => 'puppet:///modules/jenkins/openstack.css',
    require => File['/var/lib/jenkins/plugins/simple-theme-plugin'],
  }

  file { '/var/lib/jenkins/plugins/simple-theme-plugin/openstack.js':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'nogroup',
    content => template('jenkins/openstack.js.erb'),
    require => File['/var/lib/jenkins/plugins/simple-theme-plugin'],
  }

  file { '/var/lib/jenkins/plugins/simple-theme-plugin/openstack-page-bkg.jpg':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'nogroup',
    source  => 'puppet:///modules/jenkins/openstack-page-bkg.jpg',
    require => File['/var/lib/jenkins/plugins/simple-theme-plugin'],
  }

  file { '/var/lib/jenkins/logger.conf':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'nogroup',
    source  => 'puppet:///modules/jenkins/logger.conf',
    require => File['/var/lib/jenkins'],
  }

  file { '/var/lib/jenkins/plugins/simple-theme-plugin/title.png':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'nogroup',
    source  => $logo,
    require => File['/var/lib/jenkins/plugins/simple-theme-plugin'],
  }

  $simpletheme = 'org.codefirst.SimpleThemeDecorator.xml'
  file { "/var/lib/jenkins/${simpletheme}":
    ensure  => present,
    owner   => 'jenkins',
    group   => 'nogroup',
    content => template("jenkins_config/${simpletheme}.erb"),
    require => File['/var/lib/jenkins/plugins/simple-theme-plugin'],
  }

  file { '/usr/local/jenkins':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/usr/local/jenkins/slave_scripts':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    require => File['/usr/local/jenkins'],
    source  => 'puppet:///modules/jenkins/slave_scripts',
  }
}