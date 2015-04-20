# (c) Copyright 2015 Hewlett-Packard Development Company, L.P.
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

function eyaml_bin {
  if [ -f /usr/local/bin/eyaml ] ; then
    /usr/local/bin/eyaml $@
  else
    /usr/bin/eyaml $@
  fi
}

# create location to store the public and private keys
if [ -d /etc/puppet/secure ] ; then
  cd /etc/puppet/secure
else
  mkdir -p /etc/puppet/secure
  cd /etc/puppet/secure
fi

# create the public and private keys if they don't exist
if [ ! -f /etc/puppet/secure/keys/public_key.pkcs7.pem ] ; then
  if [ -f /etc/puppet/secure/keys/public_key.pkcs7.pem.bak ] ; then
    cp /etc/puppet/secure/keys/public_key.pkcs7.pem.bak /etc/puppet/secure/keys/public_key.pkcs7.pem
  fi
fi
if [ ! -f /etc/puppet/secure/keys/private_key.pkcs7.pem ] ; then
  if [ -f /etc/puppet/secure/keys/private_key.pkcs7.pem.bak ] ; then
    cp /etc/puppet/secure/keys/private_key.pkcs7.pem.bak /etc/puppet/secure/keys/private_key.pkcs7.pem
  fi
fi
if [ ! -f /etc/puppet/secure/keys/public_key.pkcs7.pem ] && [ ! -f /etc/puppet/secure/keys/private_key.pkcs7.pem ] ; then
  # create keys
  eyaml_bin createkeys
fi

# set permissions to folders and keys
chown -R puppet:puppet /etc/puppet/secure/keys
chmod -R 0500 /etc/puppet/secure/keys
chmod 0400 /etc/puppet/secure/keys/*.pem
ls -lha /etc/puppet/secure/keys

# Create encrypted password
graphite_admin_password=$(openssl rand -hex 12)

eyaml_file="/etc/puppet/hieradata/Debian/layouts/common.eyaml"

value=$(grep -E "cdk_project::graphite::graphite_admin_password" $eyaml_file)
if [ -z $value ] ; then
    eyaml_bin encrypt -l 'cdk_project::graphite::graphite_admin_password' -s $graphite_admin_password | grep "cdk_project::graphite::graphite_admin_password: ENC" >> $eyaml_file
fi

echo "################# Graphite Password Creation Done  ###################"
