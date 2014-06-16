# == Class: sysadmin_config::swap
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
# A module that deals with seeting up swap
# params:
#   size_mb is size of swap file in MB
#   swap_file name of the swapfile
#
define sysadmin_config::swap (
  $size_mb    = $title ,
  $swap_file  = hiera('sysadmin_config::swap::swap_file', '/swapfile'),
  $block_size = hiera('sysadmin_config::swap::block_size', '1M'),
){
  if ! is_integer($size_mb)
  {
    fail("sysadmin_config::swap must be an integer, got ${size_mb}")
  }
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/'] }
  notify{"creating swap on ${::fqdn}, size ${size_mb} MB on ${swap_file}":} ->
  exec { "creating swap, size ${size_mb} MB on ${swap_file}":
        command => "dd if=/dev/zero of=${swap_file} bs=${block_size} count=${size_mb}",
        onlyif  => "test $(swapon -s |grep -v Filename -c) -le 0" ,
  } ~>
  exec {"preparing swap, size ${size_mb} MB on ${swap_file}":
        command     => "mkswap ${swap_file}",
        refreshonly => true,
  } ~>
  # a world-readable swap file is a huge local vulnerability
  exec {"secure swap, size ${size_mb} MB on ${swap_file}":
        command     => "chown root:root ${swap_file} ; chmod 0600 ${swap_file}",
        refreshonly => true,
  } ~>
  exec { "activating swap, size ${size_mb} MB on ${swap_file}":
        command     => "swapon ${swap_file}",
        refreshonly => true,
  }
}
