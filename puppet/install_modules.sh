#!/bin/bash

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


function getFullPath
{
   _CWD=$(pwd)
   cd $1 > /dev/null 2<&1
   [ ! $? -eq 0 ] && echo "getFullPath: cd ${1}" && exit 1

   pwd
   [ ! $? -eq 0 ] && echo "getFullPath: pwd failed" && exit 1

   cd "${_CWD}" > /dev/null 2<&1
}
SCRIPT_NAME=$(basename $0)
SCRIPT_DIR=$(getFullPath "$(dirname $0)")
MODULE_PATH=/etc/puppet/modules

function remove_module {
  local SHORT_MODULE_NAME=$1
  if [ -n "$SHORT_MODULE_NAME" ]; then
    rm -Rf "$MODULE_PATH/$SHORT_MODULE_NAME"
  else
    echo "ERROR: remove_module requires a SHORT_MODULE_NAME."
  fi
}
# TODO: need an option for force
function puppet_force_module_install
{
	_LOG=/dev/null
    _module_name=$1
    _module_version=$2
    sudo puppet module list|grep $_module_name|grep v$_module_version > $_LOG 2<&1
    if [[ ! $? -eq 0 ]] ; then
         puppet module upgrade --force "$_module_name"  --version "$_module_version"  > $_LOG 2>&1
      if [[ ! $? -eq 0 ]] ; then
            puppet module install --force "$_module_name"  --version "$_module_version" > $_LOG
      fi
    fi
}

if [ -f "${SCRIPT_DIR}/modules.env" ] ; then
  . "${SCRIPT_DIR}/modules.env"
fi
echo $MODULES
if [ -z "${!MODULES[*]}" ] ; then
  echo "nothing to do , unable to find MODULES env"
  exit 0
fi

MODULE_LIST=`puppet module list`

# Transition away from old things
if [ -d /etc/puppet/modules/vcsrepo/.git ]
then
    rm -rf /etc/puppet/modules/vcsrepo
fi
echo "installing modules ${!MODULES[*]}"
for MOD in ${!MODULES[*]} ; do
  # If the module at the current version does not exist upgrade or install it.
  if ! echo $MODULE_LIST | grep "$MOD ([^v]*v${MODULES[$MOD]}" >/dev/null 2>&1
  then
    # Attempt module upgrade. If that fails try installing the module.
    if ! puppet module upgrade $MOD --version ${MODULES[$MOD]} >/dev/null 2>&1
    then
      # This will get run in cron, so silence non-error output
      puppet module install $MOD --version ${MODULES[$MOD]} >/dev/null
      echo "installed $MOD ${MODULES[$MOD]}"
    fi
  fi
done
