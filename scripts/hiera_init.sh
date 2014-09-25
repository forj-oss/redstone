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


_LOG=/dev/null
        
	function asRoot
	{
	    if [ -z $1 ] ; then
			if [ ! $(id -u) -eq 0 ] ; then
				echo "sudo"
			fi
		else
			echo "sudo -u $1"
		fi
	}
		
	function getFullPath
	{
	   pushd $1 > $_LOG 2<&1
	   CheckErrors $? "getFullPath: pushd failed"
	   pwd
	   CheckErrors $? "getFullPath: pwd failed"
	   popd > $_LOG 2<&1
	   CheckErrors $? "getFullPath: popd failed"
	}
        function CheckErrors
        {
          if [ ! $1 -eq 0 ] ; then
             echo "ERROR : $2 ( $1 )"
             exit $1
          fi
        }

SCRIPT_NAME=$(basename $0)
SCRIPT_DIR=$(getFullPath "$(dirname $0)")
[ ! -d /etc/puppet ] && $(asRoot) mkdir -p /etc/puppet
[ -h /etc/hiera.yaml ] && $(asRoot) rm -f /etc/hiera.yaml
[ -h /etc/puppet/hiera.yaml ] && $(asRoot) rm -f /etc/puppet/hiera.yaml
[ -h /etc/puppet/hiera ] && $(asRoot) rm -rf /etc/puppet/hiera
[ -h /etc/puppet/hiera-puppet ] && $(asRoot) rm -rf /etc/puppet/hiera-puppet


$(asRoot) ln -s "${SCRIPT_DIR}/hiera/hiera.yaml" /etc/hiera.yaml
CheckErrors $? "Failed to link file ${SCRIPT_DIR}/hiera/hiera.yaml ==> /etc/hiera.yaml"

$(asRoot) ln -s "${SCRIPT_DIR}/hiera/hiera.yaml" /etc/puppet/hiera.yaml
CheckErrors $? "Failed to link file ${SCRIPT_DIR}/hiera/hiera.yaml ==> /etc/puppet/hiera.yaml"

$(asRoot) ln -s "${SCRIPT_DIR}/hiera" /etc/puppet/hiera
CheckErrors $? "Failed to link file ${SCRIPT_DIR}/hiera ==> /etc/puppet/hiera"

#TODO: identify a way to get the exact path for hiera-puppet
#             version of gems
#             version of hiera-puppet
#             location of gem libs
#                  ??puppet master --configprint modulepath
$(asRoot) ln -s /var/lib/gems/1.8/gems/hiera-puppet-1.0.0 /etc/puppet/modules/hiera-puppet
CheckErrors $? "Failed to link file /var/lib/gems/1.8/gems/hiera-puppet-1.0.0 ==> /etc/puppet/modules/hiera-puppet"

