# == sysadmin_config:http_proxy_port
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
# get the hostname part of the proxy_url
# test : p -e "if $::http_proxy_port  { notice("\$::http_proxy_port") } else { notice('no proxy') }"

def set_facter(proxy)
  if proxy == nil
    Facter::Util::Resolution.exec("echo")
  else
    Facter::Util::Resolution.exec("echo #{proxy}")
  end
end

Facter.add("http_proxy_port") do
 confine :kernel => "Linux"
 setcode do
   #the string to look for and the path should change depending on the system to discover 
   proxy_url = Facter.value('http_proxy')
   proxy_uri = (proxy_url != nil )? URI.parse(proxy_url) : nil
   port      = (proxy_uri != nil )? URI(proxy_url).port : nil
   set_facter(port)
 end
end
