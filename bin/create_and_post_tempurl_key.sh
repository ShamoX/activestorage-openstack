#!/bin/bash

# exit badly on problems
set -e

echo "Creating a new key..."
echo
swift info
echo
echo "Are the above information correct ?"
echo "And if yes, are you sure you want to pursue and create a new TEMPURL_KEY" \
     " that will then be installed for you with the swift command on your OpenStack."
echo "Answer with a clear 'yes' to continue"
read -r CONFIRM
if [ "$CONFIRM" = "yes" ]; then
  TEMPURL_KEY_GENERATED="$(echo "require 'securerandom'; puts SecureRandom.base64(66)" | ruby)"
  echo "Here is your new key: $TEMPURL_KEY_GENERATED"
  echo "Keep it somewhere"
  swift --info post -m "Temp-URL-Key: $TEMPURL_KEY_GENERATED"
  export OPENSTACK_TEMP_URL_KEY="$TEMPURL_KEY_GENERATED"
else
  echo "No TEMPURL_KEY set."
  # remove exit on problems to prevent shell quitting (since this file may be sourced and not executed)
  set +e
  exit 1
fi
