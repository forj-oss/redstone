#!/bin/sh
# Copyright (C) 2011-2014 OpenStack Foundation
# Copyright (c) 2014 Citrix Systems, Inc.
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
set -e

PREREQ=""

prereqs () {
    echo "${PREREQ}"
}

case "${1}" in
    prereqs)
        prereqs
        exit 0
        ;;
esac

. /usr/share/initramfs-tools/hook-functions

copy_exec /sbin/resize2fs
copy_exec /sbin/e2fsck
copy_exec /usr/bin/expr
copy_exec /sbin/tune2fs
copy_exec /bin/grep
copy_exec /usr/bin/tr
copy_exec /usr/bin/cut
copy_exec /sbin/sfdisk
copy_exec /sbin/partprobe
copy_exec /bin/sed
