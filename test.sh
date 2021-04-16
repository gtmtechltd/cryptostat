#!/bin/bash

usage() {
  echo "$0 <exchange>" >&2
  exit 1
}

if [ -z "$1" ];then
  usage
fi

set -x
bundle exec lib/test.rb $1
