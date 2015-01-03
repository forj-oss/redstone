#!/bin/bash
# (c) Copyright 2015 Hewlett-Packard Development Company, L.P.
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

# at the end there is an example of the file where you can put the categories and the filters to use,
# the location of the file is not defined yet
cd $WORKSPACE
GERRIT=${1} # this is the address of the review server where the changes are

#In this step the script gets the target version (the new tag) it can be a release or a pre-release (rc, alpha, beta)
if [ ${3} == "true" ]; then
  ACTUAL=$(git tag | sort -V | tail -1)
else
  ACTUAL=$(git tag | sort -V | sed -r '/rc|alpha|beta/d' | tail -1)
fi
touch release.txt

# Each bucle get a log of the changes that fill the requirements in FILTER_PARAM and that nor fill it for other category,
# for example if a commit can be in bugs and defects it belong to the first one (bugs) so the commits are not duplicated
# in the release notes
while read A ; do
  LINE=$A
  if [[ "$LINE" == *":"* ]]; then
    if [ -n "$CATEGORY" ]; then
      FILTER_PARAM=$FILTER
      echo $FILTER_PARAM
      FILTER=""
      if [ -n "$EXCLUDE" ]; then
         RESULT=$(git log $(git tag | sed -r '/'$ACTUAL'|rc|alpha|beta/d' | sort -V | tail -1)..$ACTUAL $FILTER_PARAM --no-merges "--format=\" - %s \<a href=\\\\\"https://$GERRIT/#/q/%h,n,z\\\\\" target=\\\\\"_blank\\\\\"\> %h \</a\>\\\\\n\"")
      else
         RESULT=$(git log $(git tag | sed -r '/'$ACTUAL'|rc|alpha|beta/d' | sort -V | tail -1)..$ACTUAL $FILTER_PARAM --no-merges "--format=\" - %s \<a href=\\\\\"https://$GERRIT/#/q/%h,n,z\\\\\" target=\\\\\"_blank\\\\\"\> %h \</a\>\\\\\n\" | sed -r '/'${EXCLUDE:1}'/d'")
      fi
      echo $RESULT
      if [ -n "$RESULT" ]; then  #in this part the result of the git log is evaluated if is null then there isn't any change in that category so is not necessary to put it in the release notes
         echo "\\\\\n\\\\\n### $CATEGORY\\\\\n" >> release.txt
         echo $RESULT >> release.txt
      fi
      EXCLUDE=$EXCLUDE_FILTER
    fi
    CATEGORY=$LINE
  else
    FILTER=$FILTER""$(echo $LINE | sed -r 's/- / --grep=/' )
    EXCLUDE_FILTER=$EXCLUDE_FILTER""$(echo $LINE | sed -r 's/- /|/' )
  fi
done < filter_config.yaml #in this file are the categories and the filters of each category, so you can decide the number of categories and the filters

#you must execute another git log to get the last category or the changes that not fill the requirements to be in any category
RESUT=$(git log $(git tag | sed -r '/'$ACTUAL'|rc|alpha|beta/d' | sort -V | tail -1)..$ACTUAL --no-merges "--format=\" - %s \<a href=\\\\\"https://$GERRIT/#/q/%h,n,z\\\\\" target=\\\\\"_blank\\\\\"\> %h \</a\>\\\\\n\" | sed -r '/'${EXCLUDE:1}'/d'")
echo $RESULT
if [ -n "$RESULT" ]; then
  echo "\\\\\n\\\\\n### $CATEGORY\\\\\n" >> release.txt
  echo $RESULT >> release.txt
fi

sed -i 's/\r//' release.txt
while read A ; do
  TEXTO=$TEXTO""$A
done < release.txt
API_JSON='{"tag_name": "'$ACTUAL'","target_commitish": "master","name": "v'$ACTUAL'","body": "'$TEXTO'","draft": false,"prerelease": '$3'}' #this is the JSON that create the release and the release notes in github
curl --data "$API_JSON" https://api.github.com/repos/$2/releases?access_token= #OAUTH ACCESs TOKEN  #the access token OAUT from github so you can acces the api
rm release.txt

# this is an example of te config for the release notes you can change the number of categories, number of filters for cateogrie.
# And if you change the location of the file you must change it in the tags.sh also 
# 
#filter_config.yaml
#features:
#  - create
#  - implement
#  - feature
#
#bugs:
#  - bug
#  - error
#  - problem
#
#defects:
#  - fix
#  - Fix
#  - Issues
#  - Defect
#
#changes:
#  - modify
#  - alter
#  - change
#
#misc: