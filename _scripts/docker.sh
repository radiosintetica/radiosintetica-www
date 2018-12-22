#!/bin/bash

if [ -z "$1" ]; then
    cat <<EOF
USAGE:
    $0 COMMAND [OPTIONS]

COMMAND:
    b       build site
    s       serve site locally
    x       build site index
EOF

    exit 1
fi

cd $(dirname $0) && cd ..
export MSYS_NO_PATHCONV=1

BASE_DIR="/srv/jekyll/cesbo.com"

if [ "$1" = "x" ]; then

    if docker images -q "node" | grep -qe '[0-9a-z]*' ; then
        docker pull "node:latest"
    fi

    docker run --rm \
        -w "$BASE_DIR" -v "$PWD:$BASE_DIR" \
        "node" node ./_scripts/build-index.js

else

    if ! docker images -q "jekyll/jekyll" | grep -qe '[0-9a-z]*' ; then
        docker pull "jekyll/jekyll:latest"
    fi

    docker run --rm \
        -w "$BASE_DIR" -v "$PWD:$BASE_DIR" \
        -v "$PWD/.gems-cache:/usr/local/bundle" \
        -p "35729:35729" -p "4000:4000" \
        "jekyll/jekyll" jekyll $*
fi
