# == Class: exim_config
# Copyright 2014 Hewlett-Packard Development Company, L.P.
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
class exim_config::aux (
) {
    $id_array = split($::domain, '\.')
    $id = $id_array[0]
    notify{">>>>>> id=${id}":}
    $maestro_ip = compute_private_ip_lookup("maestro.${id}")
    $review_ip = compute_private_ip_lookup("review.${id}")
    notify{">>>>>> maestro:${maestro_ip}, review:${review_ip}":}
}
