# == sysadmin_config:http_proxy
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
# Working behind firewalls requires proxies sometimes, this facter 
# uses /etc/environment or ENV to determine if a proxy configuration exist.
# if it does, it set's up the facter.
# test : p -e "if $::http_proxy  { notice("\$::http_proxy") } else { notice('no proxy') }"

def getproxyuri(proxy)
     proxy_uri = (proxy != nil )? URI.parse(proxy) : nil
     return proxy_uri
end

def get_proxy_from_env
  proxy = (ENV['HTTP_PROXY'] == nil)? ENV['http_proxy'] : ENV['HTTP_PROXY']
  return getproxyuri(proxy)
end

def get_proxy_from_file
  proxy = nil
  if File.exist? "/etc/environment"
    #the string to look for and the path should change depending on the system to discover
    proxy_hash = {}
    open("/etc/environment").grep(/http_proxy|HTTP_PROXY/).each do | line |
      line = line.gsub(/[\s+]*export\s+/,"").chomp
      proxy_hash[line.split("=", 2)[0]] = line.split("=", 2)[1]
    end
    
    # facter only needs the first one we find, no need to show all others
    if (proxy_hash.has_key?("http_proxy") )
      proxy = proxy_hash["http_proxy"]
    end
    if (proxy_hash.has_key?("HTTP_PROXY") )
      proxy = proxy_hash["HTTP_PROXY"]
    end
  end
  return getproxyuri(proxy)
end

def set_facter(proxy)
  if proxy == nil
    Facter::Util::Resolution.exec("echo")
  else
    Facter::Util::Resolution.exec("echo #{proxy}")
  end
end

Facter.add("http_proxy") do
  confine :kernel => "Linux"
  setcode do
    # lets first check if http_proxy or HTTP_PROXY is set
    proxy = get_proxy_from_file
    proxy = get_proxy_from_env if proxy == nil
    set_facter(proxy)
  end
end
