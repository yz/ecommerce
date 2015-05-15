#!/bin/bash

TMP_FILE=./tmp/parse.tmp
if [ -e ./tmp/parse.tmp ]; then
  echo "Cleaning up from previous install failure"
  rm -f ./tmp/parse.tmp
fi
echo "Fetching latest version ..."

case `uname` in
  "Linux" )
    curl --progress-bar -Lo ./tmp/parse.tmp https://parse.com/downloads/cloud_code/cli/parse-linux/latest
    ;;
  "Darwin" )
    curl --progress-bar -Lo ./tmp/parse.tmp https://parse.com/downloads/cloud_code/cli/parse-osx/latest
    ;;
esac

if [ ! -d /usr/local/bin ]; then
  echo "Making ./parsecloud/bin"
  mkdir -p ./parsecloud/bin
fi
echo "Installing ..."
mv ./tmp/parse.tmp ./parsecloud/bin/parse
chmod 755 ./parsecloud/bin/parse
