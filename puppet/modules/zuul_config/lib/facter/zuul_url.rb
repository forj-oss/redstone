# == jimador::zuul_url
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
Facter.add("zuul_url") do
 confine :kernel => "Linux"
 setcode do
   #the string to look for and the path should change depending on the system to discover
   if File.exist? "/etc/zuul/zuul.conf"
     Facter::Util::Resolution.exec("find /etc/zuul/ -name 'zuul.conf' -exec grep  status_url {} \\; | awk -F'status_url=' '{print $2}'")
   else  
     Facter::Util::Resolution.exec("echo")
   end
 end
end
