#!/bin/sh

cd $(dirname $0) && cd ..
CREF=$(git rev-parse --short HEAD)
git pull
NREF=$(git rev-parse --short HEAD)
if [ "$CREF" != "$NREF" ] ; then
    ./_scripts/docker.sh b && ./_scripts/docker.sh x
fi
