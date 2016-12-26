#!/bin/bash
set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

export PATH=/opt/node/bin:/usr/src/app/frontend/node_modules/.bin:$PATH

if [ ! -d frontend/node_modules ] ; then
  echo "Initializing node dependencies"
  pushd frontend
  npm install
  popd
fi

if [ ! -d frontend/bower_components ] ; then
  echo "Initializing bower dependencies"
  pushd frontend
  bower --allow-root install
  popd
fi

if [ ! -d vendor/.bundle ] ; then
  echo "Initializing ruby dependencies"
  bundle install
fi

exec $@
