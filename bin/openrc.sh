#!/bin/bash

# exit badly on problems
set -e

export_unless_already_set() {
  export_name="$1"
  default="$2"
  if [ "$(eval "echo -n \$$export_name")" = "" ]; then
    export "$export_name"="$default"
  fi
}

# To use an Openstack cloud you need to authenticate against keystone, which
# returns a **Token** and **Service Catalog**. The catalog contains the
# endpoint for all services the user/tenant has access to - including nova,
# glance, keystone, swift.
#
export_unless_already_set OS_AUTH_URL "https://auth.cloud.ovh.net"
export_unless_already_set OS_IDENTITY_API_VERSION "3"


# The project id on which to connect
export_unless_already_set OS_PROJECT_ID 62f2e9d4f7fe4c989a3056a0f46a5605

# In addition to the owning entity (tenant), openstack stores the entity
# performing the action as the **user**.
export_unless_already_set OS_USERNAME "Gh2UmCF2k9rG"

# With Keystone you pass the keystone password.
if [ "$OS_PASSWORD" = "" ]; then
  echo "Please enter your OpenStack Password: "
  read -sr OS_PASSWORD_INPUT
  export OS_PASSWORD=$OS_PASSWORD_INPUT
fi

# If your configuration has multiple regions, we set that information here.
# OS_REGION_NAME is optional and only valid in certain environments.
export_unless_already_set OS_REGION_NAME "BHS1"
# Don't leave a blank variable, unset it if it was empty
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi

# activestorage-openstack test setup
export_unless_already_set OPENSTACK_CONTAINER activestorage-openstack-test
export OPENSTACK_USERNAME="$OS_USERNAME"
export OPENSTACK_API_KEY="$OS_PASSWORD"
export OPENSTACK_AUTH_URL="$OS_AUTH_URL"
export OPENSTACK_REGION="$OS_REGION_NAME"
export OPENSTACK_PROJECT_ID="$OS_PROJECT_ID"

if [ "$OPENSTACK_TEMP_URL_KEY" = "" ]; then
  echo "Please enter your OpenStack TEMPURL key (leave empty to generate and register a new one): "
  read -sr TEMPURL_KEY_INPUT
  if [ "$TEMPURL_KEY_INPUT" = "" ]; then
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
      swift --info post -m "Temp-URL-Key: $TEMPURL_KEY_GENERATED"
      export OPENSTACK_TEMP_URL_KEY="$TEMPURL_KEY_GENERATED"
    else
      echo "No TEMPURL_KEY set."
      # remove exit on problems to prevent shell quitting (since this file may be sourced and not executed)
      set +e
      exit 1
    fi
  else
    export OPENSTACK_TEMP_URL_KEY="$TEMPURL_KEY_INPUT"
  fi
fi

# remove exit on problems to prevent shell quitting (since this file may be sourced and not executed)
set +e
