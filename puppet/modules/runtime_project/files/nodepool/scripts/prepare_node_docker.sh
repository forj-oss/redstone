#!/bin/bash -xe

# Copyright (C) 2011-2013 OpenStack Foundation
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
# Test install:
# curl https://raw.githubusercontent.com/forj-oss/redstone/master/puppet/modules/runtime_project/files/nodepool/scripts/prepare_node_docker.sh | bash -xe
# Test Slave setup
# export NODEPOOL_PREPARE_HOSTNAME=test-node.forj.io
# export NODEPOOL_GIT_HOME=/var/lib/zuul/git
# export NODEPOOL_REVIEW_SERVER=https://review.forj.io
# export NODEPOOL_SETUP_SLAVE=true
# export NODEPOOL_SSH_KEY="AAAAB3NzaC1yc2EAAAADAQABAAAAgQCcj9X9SEI0o1VhEDAINB835tdI7TraDhHME8OXysPaQO3h7y/IIti3WvEfqt7c7vrNBGLp0LCF6hBH1uW/zqoHNtBjoOX1MYyOJhEs0XTQHf4rcQwasyCj24UdNQHyVdFNthXzLCvZWYmsRvgF67GibQsW559rCg9ju2RCF8CyYw==" 
# curl https://raw.githubusercontent.com/forj-oss/redstone/master/puppet/modules/runtime_project/files/nodepool/scripts/prepare_node_docker.sh | bash -xe
#
### GLOBALS ###
#
[ ! -z $NODEPOOL_PREPARE_HOSTNAME ] && PREPARE_HOSTNAME=$NODEPOOL_PREPARE_HOSTNAME
[ ! -z $NODEPOOL_GIT_HOME ] && GIT_HOME=$NODEPOOL_GIT_HOME
[ ! -z $NODEPOOL_REVIEW_SERVER ] && REVIEW_SERVER=$NODEPOOL_REVIEW_SERVER
[ ! -z $NODEPOOL_SETUP_SLAVE ] && SETUP_SLAVE=$NODEPOOL_SETUP_SLAVE
[ ! -z $NODEPOOL_SSH_KEY ] && PUBLIC_SSH_KEY=$NODEPOOL_SSH_KEY

[ -z $PROJECTS_YAML ] && echo "INFO: using forj-config project for projects.yaml"
export PREPARE_HOSTNAME=${PREPARE_HOSTNAME:-node-test}
export PROJECT_EXCLUDE_REGX=${PROJECT_EXCLUDE_REGX:-(CDK-.*|forj/infra|forj-ui/forj.csa|forj-config)}
export GIT_HOME=${GIT_HOME:-~/prepare/git}
export REVIEW_SERVER=${REVIEW_SERVER:-https://review.forj.io}
export AS_ROOT=${AS_ROOT:-0}
export SCRIPT_TEMP=$(mktemp -d)
export PUPPET_VERSION=${PUPPET_VERSION:-'2'}
export PUBLIC_SSH_KEY=${PUBLIC_SSH_KEY:-''}
export CURRENT_GROUP=$(grep $(id -g) /etc/group|awk -F: '{print $1}')

SETUP_SLAVE=${SETUP_SLAVE:-false}
SUDO=${SUDO:-true}
THIN=${THIN:-true}
PYTHON3=${PYTHON3:-false}
PYPY=${PYPY:-false}
ALL_MYSQL_PRIVS=${ALL_MYSQL_PRIVS:-false}
JENKINS_USER=${JENKINS_USER:-jenkins}

export DEBUG=${DEBUG:-0}
[ $DEBUG -eq 1 ] && export PUPPET_DEBUG="--verbose --debug"
#
###

trap 'rm -rf $SCRIPT_TEMP' EXIT

[ $DEBUG -eq 1 ] && set -x -v

#
# function to trap an error and exit
#
function ERROR_EXIT {
  _line="$1"
  _errm="$2"
  _code="${3:-1}"
  if [ ! -z "$_errm" ] ; then
    echo "ERROR (${_line}): ${_errm}, exit code ${_code}" 1>&2
  else
    echo "ERROR (${_line}): exit code ${_code}" 1>&2
  fi
  exit "${_code}"
}
trap 'ERROR_EXIT ${LINENO}' ERR

#
# run a sudo command if the script is not run as root
# otherwise run the command, assume we're root
#
function DO_SUDO {
  if [ $AS_ROOT -eq 0 ] ; then
    sudo "$@"
  else
    eval "$@"
  fi
}

#
# clone or update a project repo based on REVIEW_SERVER and GIT_HOME
#
function GIT_CLONE {
  [ -z $1 ] && ERROR_EXIT  ${LINENO} "GIT_CLONE requires repo name" 2
  [ -z $REVIEW_SERVER ] && ERROR_EXIT  ${LINENO} "GIT_CLONE requires REVIEW_SERVER" 2
  [ -z $GIT_HOME ] && ERROR_EXIT  ${LINENO} "no GIT_HOME defined" 2
  git config --global http.sslverify false
  if [ ! -d $GIT_HOME/$1/.git ] ; then
    if ! git clone --depth=1 $REVIEW_SERVER/p/$1 $GIT_HOME/$1 ; then
      echo "Retrying clone operation on $REVIEW_SERVER/p/$1"
      git clone --depth=1 $REVIEW_SERVER/p/$1 $GIT_HOME/$1
    fi
  fi
  _CWD=$(pwd)
  cd $GIT_HOME/$1
  git branch -a > /dev/null 2<&1
  git reset --hard HEAD
  git remote update
  if ! git remote update ; then
    echo "Retrying remote update operation on $GIT_HOME/$1"
    git remote update
  fi
  cd $_CWD
  return 0
}

#
# build a docker image with specified docker file
# use DOCKER_HOME as the docker build context
# <Dockerfile Name>  <image name>
#
function DOCKER_BUILD {
  [ -z "${1}" ] && ERROR_EXIT  ${LINENO} "DOCKER_BUILD requires 1st argument, the docker file name in DOCKER_HOME." 2
  [ -z "${2}" ] && ERROR_EXIT  ${LINENO} "DOCKER_BUILD requires 2nd argument, the docker image name." 2
  [ -z "${DOCKER_HOME}" ] && ERROR_EXIT  ${LINENO} "no DOCKER_HOME defined" 2
  DOCKER_NAME=$2
  # use sg
  # workaround to error:
  # Get http:///var/run/docker.sock/v1.14/info: dial unix /var/run/docker.sock: permission denied
  _CWD=$(pwd)
  cd "${DOCKER_HOME}"
  [ -f Dockerfile ] && rm -f Dockerfile
  ln -s "$1" Dockerfile
  if ! groups | grep docker > /dev/null 2<&1 ; then
    ERROR_EXIT ${LINENO} "The current user is not a member of the docker group" 2
  fi
  sg docker -c "docker build -t '${DOCKER_NAME}' '${DOCKER_HOME}'"
  DOCKER_REPO=$(echo "${DOCKER_NAME}"|awk -F: '{print $1}')
  DOCKER_TAG=$(echo "${DOCKER_NAME}"|awk -F: '{print $2}')
  if ! sg docker -c "docker images --no-trunc | grep -e '^${DOCKER_REPO}\s*${DOCKER_TAG}.*'" ; then
    ERROR_EXIT ${LINENO} "${DOCKER_NAME} image not found." 2
  fi
  cd "${_CWD}"
}
#
# setup the nameservers configured by our provider
#
function FORWARDING {
    cat >/tmp/forwarding.conf <<EOF
forward-zone:
  name: "."
  forward-addr: 8.8.8.8
EOF
}
#
# setup hostname
#
function SETUP_HOSTNAME {
    [ "${PREPARE_HOSTNAME}" = "node-test" ] && echo "WARNING: operating in test mode with ${PREPARE_HOSTNAME}."
    DO_SUDO hostname $PREPARE_HOSTNAME
    if [ -n "$PREPARE_HOSTNAME" ] && \
            ! grep -q $PREPARE_HOSTNAME /etc/hosts; then
        echo "127.0.1.1 $PREPARE_HOSTNAME" | DO_SUDO tee -a /etc/hosts
    fi
}
#
# clone all repos
#
function CLONE_ALL_REPOS
{
    if [ -z $PROJECTS_YAML ] ; then
        GIT_CLONE forj-config
        PROJECTS_YAML=file://$GIT_HOME/forj-config/modules/runtime_project/templates/gerrit/config/production/review.projects.yaml.erb
    fi
    curl -s $PROJECTS_YAML | egrep '^-?\s+project:\s+(.*)$'   \
                           | awk -F: '{print $2}'             \
                           | sed 's/^\s//g'                   \
                           | egrep -v "$PROJECT_EXCLUDE_REGX" \
                           | while read PROJECT ; do
                               GIT_CLONE $PROJECT;
                             done
}
#
# setup slave
#
function SETUP_SLAVE {
    DO_SUDO bash -c 'if [ ! -d /root/config/.git ]; then git clone --depth=1 \
            git://git.openstack.org/openstack-infra/config.git \
            /root/config; else exit 0; fi'
# TODO: remove if testing works without this
#    DO_SUDO /bin/bash /root/config/install_modules.sh

    if [ -z "$PUBLIC_SSH_KEY" ] ; then
        DO_SUDO puppet apply $PUPPET_DEBUG \
            --modulepath=/root/config/modules:/etc/puppet/modules \
            -e "class {'openstack_project::single_use_slave':
                        sudo => $SUDO,
                        thin => $THIN,
                        python3 => $PYTHON3,
                        include_pypy => $PYPY,
                        all_mysql_privs => $ALL_MYSQL_PRIVS, }"
    else
        DO_SUDO puppet apply \
            --modulepath=/root/config/modules:/etc/puppet/modules \
            -e "class {'openstack_project::single_use_slave':
                        install_users => false,
                        sudo => $SUDO,
                        thin => $THIN,
                        python3 => $PYTHON3,
                        include_pypy => $PYPY,
                        all_mysql_privs => $ALL_MYSQL_PRIVS,
                        ssh_key => '$PUBLIC_SSH_KEY', }"
    fi

    DO_SUDO chown -R $JENKINS_USER:$CURRENT_GROUP $GIT_HOME
    DO_SUDO chmod -R 777 $GIT_HOME
}
#
# install docker
#
function SETUP_DOCKER {
    # install docker with puppet modules
    cp $GIT_HOME/forj-oss/maestro/puppet/install_modules.sh $SCRIPT_TEMP/install_modules.sh
    cat > $SCRIPT_TEMP/modules.env << MODULES
    unset DEFAULT_MODULES
    MODULES["garethr/docker"]="1.2.2"
MODULES
    DO_SUDO bash -xe $SCRIPT_TEMP/install_modules.sh
    #
    # install docker
    DO_SUDO puppet apply $PUPPET_DEBUG \
                        --modulepath=/etc/puppet/modules \
                        -e "include docker"
}
#
# pull images
#
function PULL_DOCKER_IMAGE {
    [ -z $1 ] && ERROR_EXIT  ${LINENO} "PULL_DOCKER_IMAGE requires image list in arg 1" 2
    IMAGE=$1
    DO_SUDO puppet apply $PUPPET_DEBUG \
                        --modulepath=/etc/puppet/modules \
                        -e 'docker::image { '"'${IMAGE}'"': }'
}
#
# grant current user access to docker
#
function DOCKER_GRANT_ACCESS {
    CURRENT_USER=$(facter id)
    [ -z $CURRENT_USER ] && ERROR_EXIT ${LINENO} "failed to get current user with facter id" 2
    DO_SUDO puppet apply $PUPPET_DEBUG \
                -e 'user {'"'${CURRENT_USER}'"': ensure => present, gid => "docker" }'
}
#
# setup beaker
#
function SETUP_BEAKER {
    DO_SUDO puppet apply $PUPPET_DEBUG \
               -e 'package {["build-essential","vim","git",
                             "make","dos2unix","libxslt-dev","libxml2-dev"]:
                              ensure => present } ->
                   package {"beaker":
                              provider => gem,
                              ensure   => latest, }'
}
#
# The puppet modules should install unbound.  Take the nameservers
# that we ended up with at boot and configure unbound to forward to
# them.
#
function SETUP_UNBOUND {
    DO_SUDO mv /tmp/forwarding.conf /etc/unbound/
    DO_SUDO chown root:root /etc/unbound/forwarding.conf
    DO_SUDO chmod a+r /etc/unbound/forwarding.conf
    # HPCloud has selinux enabled by default, Rackspace apparently not.
    # Regardless, apply the correct context.
    if [ -x /sbin/restorecon ] ; then
        DO_SUDO chcon system_u:object_r:named_conf_t:s0 /etc/unbound/forwarding.conf
    fi
    # Overwrite /etc/resolv.conf at boot
    DO_SUDO dd of=/etc/rc.local <<EOF
    #!/bin/bash
    set -e
    set -o xtrace

    echo 'nameserver 127.0.0.1' > /etc/resolv.conf
    exit 0
EOF

    DO_SUDO bash -c "echo 'include: /etc/unbound/forwarding.conf' \
                     >> /etc/unbound/unbound.conf"
    if [ -e /etc/init.d/unbound ] ; then
        DO_SUDO /etc/init.d/unbound restart
    elif [ -e /usr/lib/systemd/system/unbound.service ] ; then
        DO_SUDO systemctl restart unbound
    else
        echo "Can't discover a method to restart \"unbound\""
        exit 1
    fi
}

# prepare a node with docker installed
# * we need puppet commandline setup, along with expected modules
[ ! $(id -u) -eq 0 ] && [ $AS_ROOT -eq 1 ] \
   && ERROR_EXIT  ${LINENO} "SCRIPT should be run as sudo or root with export AS_ROOT=1" 2

FORWARDING
SETUP_HOSTNAME

# Make sure DNS works.
dig review.forj.io

#
# setup the basics
DO_SUDO apt-get update
DO_SUDO DEBIAN_FRONTEND=noninteractive apt-get --option 'Dpkg::Options::=--force-confold' \
        --assume-yes install -y --force-yes git vim curl wget python-all-dev

if [ ! -d "${GIT_HOME}" ] ; then
    DO_SUDO mkdir -p "${GIT_HOME}"
    DO_SUDO chown $(whoami) "${GIT_HOME}"
    DO_SUDO chgrp "${CURRENT_GROUP}" "${GIT_HOME}"
fi
export GIT_HOME=$(readlink -f "${GIT_HOME}")

CLONE_ALL_REPOS

DO_SUDO bash -xe $GIT_HOME/forj-oss/maestro/puppet/install_puppet.sh 
DO_SUDO bash -xe $GIT_HOME/forj-oss/maestro/puppet/install_modules.sh

[ "${SETUP_SLAVE}" = "true" ] && SETUP_SLAVE


SETUP_DOCKER
PULL_DOCKER_IMAGE 'ubuntu'
DOCKER_GRANT_ACCESS


# build a docker image bare_precise_puppet
# This docker image should have puppet and required modules installed.
export DOCKER_HOME=$(readlink -f $GIT_HOME)

#
# placing the docker files inline so this script can be self contained.
# ********** START DOCKER FILE PRECISE ****************************************
cat > $DOCKER_HOME/Dockerfile.precise << DOCKER_BARE_PRECISE
# DOCKER-VERSION 0.3.4
# build a puppet based image
FROM  ubuntu:12.04
WORKDIR ${GIT_HOME}
ADD . /opt/git
RUN ls -altr /opt/git
RUN df -k
# Setup Minimal running system
RUN apt-get -y update; \
    apt-get -y upgrade; \
    DEBIAN_FRONTEND=noninteractive apt-get --option 'Dpkg::Options::=--force-confold' \
        --assume-yes install -y --force-yes ntpdate git vim curl wget python-all-dev;
RUN git config --global http.sslverify false
RUN bash -xe /opt/git/forj-oss/maestro/puppet/install_puppet.sh 
RUN bash -xe /opt/git/forj-oss/maestro/puppet/install_modules.sh
RUN bash -xe /opt/git/forj-oss/maestro/hiera/hiera.sh
RUN lsb_release -a
DOCKER_BARE_PRECISE
# ********** END DOCKER FILE PRECISE *******************************************

# ********** START DOCKER FILE TRUSTY ****************************************
cat > $DOCKER_HOME/Dockerfile.trusty << DOCKER_BARE_TRUSTY
# DOCKER-VERSION 0.3.4
# build a puppet based image
FROM  ubuntu:14.04
ADD . /opt/git
RUN ls -altr /opt/git
RUN df -k
# Setup Minimal running system
RUN apt-get -y update; \
    apt-get -y upgrade; \
    DEBIAN_FRONTEND=noninteractive apt-get --option 'Dpkg::Options::=--force-confold' \
        --assume-yes install -y --force-yes ntpdate git vim curl wget python-all-dev;
RUN git config --global http.sslverify false
RUN PUPPET_VERSION=3 bash -xe /opt/git/forj-oss/maestro/puppet/install_puppet.sh 
RUN bash -xe /opt/git/forj-oss/maestro/puppet/install_modules.sh
RUN lsb_release -a
DOCKER_BARE_TRUSTY
# ********** END DOCKER FILE TRUSTY *******************************************

#
# build an image for this prepare
DOCKER_BUILD Dockerfile.precise forj/ubuntu:precise
DOCKER_BUILD Dockerfile.trusty forj/ubuntu:trusty
#TODO: create forj/centos:6.5

# setup beaker
SETUP_BEAKER

# setup unbound
SETUP_UNBOUND

# We don't always get ext4 from our clouds, mount ext3 as ext4 on the next
# boot (eg when this image is used for testing).
sudo sed -i 's/ext3/ext4/g' /etc/fstab

# Remove additional sources used to install puppet or special version of pypi.
# We do this because leaving these sources in place causes every test that
# does an apt-get update to hit those servers which may not have the uptime
# of our local mirrors.
OS_FAMILY=$(facter osfamily)
if [ "$OS_FAMILY" == "Debian" ] ; then
    DO_SUDO rm -f /etc/apt/sources.list.d/*
    DO_SUDO apt-get update
elif [ "$OS_FAMILY" == "RedHat" ] ; then
    # Can't delete * in yum.repos.d since all of the repos are listed there.
    # Be specific instead.
    if [ -f /etc/yum.repos.d/puppetlabs.repo ] ; then
        DO_SUDO rm -f /etc/yum.repos.d/puppetlabs.repo
    fi
fi

# Remove cron jobs
# We create fresh servers for these hosts, and they are used once. They don't
# need to do things like update the locatedb or the mandb or rotate logs
# or really any of those things. We only want code running here that we want
# here.
DO_SUDO rm -f /etc/cron.{monthly,weekly,daily,hourly,d}/*

sync
sleep 5
echo "*** PREPARE COMPLETED ***"
exit 0
