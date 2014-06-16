# == gerrit_config::copyfile
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
# Copy a single file from source to destination
# optionally append the destination with a different ending.
#
define gerrit_config::copy_file (
  $file_elem = $title,
  $append_text = '',
  $source_path = '',
  $destin_path = '',
  $ensure = present,
  $owner = 'root',
  $group = 'root',
  $mode  = '0555',
  $replace = true
)
{
    $file_source = "${source_path}/${file_elem}"
    $file_destin = "${destin_path}/${file_elem}${append_text}"
    notify {"will copy file ${file_source} -> ${file_destin}":} ->
    file { $file_destin:
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      source  => $file_source,
      replace => $replace
    }
}
