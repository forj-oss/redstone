#!/bin/bash -e
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
# -e option: Error out on any command/pipeline error
#
# -o specify a git url to use, ssh:// file:// to be appended by project
# -g specify a gerrit server url like https://review.openstack.org
# -z specify a zuul server to use
# -p specify a list of projects to clone, quote the argument
set -x -v
# arguments: repo list
PROJ_LIST=""  

GERRIT_SITE=""
ZUUL_SITE=""


function ParseArgs
{
    args_max=$#

    args=("$@")
    unset args[${#args[@]}]
    for arg_i in $(eval echo {0..$args_max})
    do
        arg="${args[$arg_i]}"
        arg_next="${args[($arg_i + 1)]}"
        case "$arg" in
        -o)    GIT_ORIGIN=$arg_next
                ;;
        -g)    GERRIT_SITE=$arg_next
                ;;
        -z)    ZUUL_SITE=$arg_next
                ;;
        -p)    PROJ_LIST=$arg_next
                ;;
        esac
    done
    # CheckArgs

}
ParseArgs $@

if [ -z "$GERRIT_SITE" ]
then
  echo "The gerrit site name (eg 'https://review.openstack.org') -g is required."
  exit 1
fi

if [ -z "$GIT_ORIGIN" ]
then
    GIT_ORIGIN="$GERRIT_SITE/p"
    # git://git.openstack.org/
    # https://review.openstack.org/p
fi

if [ -z "$ZUUL_SITE" ]
then
    GIT_ZUUL="${GERRIT_SITE}/p"
    # git://git.openstack.org/
    # https://review.openstack.org/p
else
    GIT_ZUUL="${ZUUL_SITE}/p"
fi

if [ -z "$ZUUL_REF" ]
then
    echo "This job may only be triggered by Zuul."
    exit 1
fi

if [ ! -z "$ZUUL_CHANGE" ]
then
    echo "Triggered by: $GERRIT_SITE/$ZUUL_CHANGE"
fi

if [[ -z "$PROJ_LIST" ]]
then
    PROJ_LIST=$ZUUL_PROJECT
fi

if [[ -z "$PROJ_LIST" ]]
then
    echo "Argument required -- please provide -p option or run with zull for ZULL_PROJECT"
    exit 1
fi

export GIT_SSL_NO_VERIFY=1

workspace="$(pwd)"

# $ZUUL_PROJECT is the git repo of the change that triggered the build
# $ZUUL_REF is the git reference of compiled changes within the repo
# If there is a pipeline dependency on another repo, the same reference
# will exist there. If not we take latest on branch.

echo "Using branch: $ZUUL_BRANCH"

set -x   
for repo in $PROJ_LIST
do
    cd "$workspace"
    if [[ ! -e ./$repo ]]
    then
       mkdir -p ./$repo
    fi

    cd ./$repo

    if [[ ! -e .git ]]
    then
        rm -fr .[^.]* *
        if [ -d /opt/git/$repo/.git ]
        then
            git clone file:///opt/git/$repo .
        else
            git clone $GIT_ORIGIN/$repo .
        fi
    fi
    # Make sure we are pointing to right repo and fetch latest
    git remote set-url origin $GIT_ORIGIN/$repo
    if ! git remote update --prune
    then
        echo "The remote update failed, so garbage collecting before trying again."
        git gc
        git remote update --prune
    fi

    git reset --hard
    if ! git clean -x -f -d -q ; then
        sleep 1
        git clean -x -f -d -q
    fi

    #TODO: need to figure out if we need to deal with ZUUL_NEWREV, for now continue.
    # Try to use same branch as Zuul change project, default to master
    if ! git branch -a |grep remotes/origin/$ZUUL_BRANCH>/dev/null; then
        branch=master
        ref=$(echo $ZUUL_REF | sed -e "s,$ZUUL_BRANCH,master,")
    else
        branch=$ZUUL_BRANCH
        ref=$ZUUL_REF
    fi

    # Fetch reference. if it exists, check it out, otherwise checkout latest on branch
    # clean up all the private/modified files from prior builds
    if git fetch $GIT_ZUUL/$repo $ref
    then
      git checkout -f FETCH_HEAD
      git reset --hard FETCH_HEAD
    else
      if [[ "$repo" == "$ZUUL_PROJECT" ]]
      then
        echo "Could not find Zuul change $ZUUL_REF for $repo"
        exit 3
      fi
      git checkout -f $branch
      git reset --hard remotes/origin/$branch
    fi

    git clean -x -f -d -q

    if [ -f .gitmodules ]
    then
        git submodule init
        git submodule sync
        git submodule update --init
    fi
done

exit 0
