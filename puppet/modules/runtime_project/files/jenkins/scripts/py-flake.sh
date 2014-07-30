#!/bin/bash
#
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
# flake8 error codes: http://flake8.readthedocs.org/en/latest/warnings.html
# flake8 -h for options
#
# depencies:
# sudo pip install flake8
# or
# sudo apt-get install python-flake8
#
set -x -v
FLAKE8_FLAGS='--statistics --count --max-complexity 10'
PROG=`basename "$0"`
Usage () {
    echo >&2 "usage: $PROG <project>"
    exit 1
}

[ $# -lt 1 ] && Usage

DIR=$1
if [ ! -d "$DIR" ]; then
  # Control will enter here if $DIR doesn't exist.
    echo "No project folder supplied"
    exit 1
fi

if [ "$(ls -A $DIR)" ]; then
   # files that contain this line are skipped:
   # flake8: noqa
   #
   # lines that contain a # noqa comment at the end will not issue warnings
   find . -name tox.ini -type f | while read file ; do
      work_dir=$(dirname $file); cwd=$(pwd); cd $work_dir;
      flake8 $DIR $FLAKE8_FLAGS --config=$DIR/tox.ini;
      cd $cwd;
   done
else
    echo "$DIR is empty"$
    exit 0
fi
