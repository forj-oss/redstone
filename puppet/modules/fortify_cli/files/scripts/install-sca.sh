#!/bin/bash
# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# set -x -v

# exec wrapper
do_cmd()
{
    "$@"
    ret=$?
    if [[ $ret -eq 0 ]]
    then
        echo "Successfully ran [ $@ ]"
    else
        echo "Error: Command [ $@ ] returned $ret"
        return $ret
    fi
}

do_cmd /tmp/Fortify_SCA-x64.run --mode unattended --optionfile /tmp/sca-silent.txt
