#!/bin/bash

_dirname=$1
_genname=$2

capture_group='\([0-9a-z]\+\)'
others='-.*'
version=$(uuidgen | sed "s/$capture_group$others/\1/")

# Check if we want to build a new image.
if grep -q "<VERSION>" "$_genname"; then
  docker build $SRC/$_dirname -t $DOCKER/microservices-$_dirname:$version
  sed -i "s#<DOCKER>#$DOCKER#g" $_genname
  sed -i "s/<VERSION>/$version/g" $_genname
fi
