#!/bin/bash

usage() {
  echo "$0 <wallet>" >&2
  exit 1
}

if [ -z "$1" ];then
  usage
fi

export CRYPTOSTAT_TEST=nohistory

set -x
bundle exec lib/test-wallet.rb $1
