# ActiveStorage::Openstack
This rails plugin wraps the OpenStack Swift provider as an Active Storage service.

[![Gem Version](https://badge.fury.io/rb/activestorage-openstack.svg)](https://badge.fury.io/rb/activestorage-openstack)
[![Build Status](https://travis-ci.com/ShamoX/activestorage-openstack.svg?branch=master)](https://travis-ci.com/ShamoX/activestorage-openstack)
[![Maintainability](https://api.codeclimate.com/v1/badges/567a1c8e09288db91781/maintainability)](https://codeclimate.com/github/ShamoX/activestorage-openstack/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/567a1c8e09288db91781/test_coverage)](https://codeclimate.com/github/ShamoX/activestorage-openstack/test_coverage)


# PLEASE FORGIVE ME
Few monthes ago, I tried to contact `chaadow` - which seems to be the new maintainer
of this project - and got no answer. Since I needed updates on this gem and no ones
seemed to take it back, I decided to create and setup this new version.

For now I call it `activestorage-openstack-shamox`, just because I can't take over
`activestorage-openstack` from rubygem without a consent of its owner.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'activestorage-openstack-shamox'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install activestorage-openstack-shamox
```

## Usage
in `config/storage.yml`, in your Rails app, create an entry with the following keys:
```yaml
dev_openstack:
  service: OpenStack
  container: <container name> # Container name for your OpenStack provider
  credentials:
    openstack_auth_url: <auth url>
    openstack_username: <username>
    openstack_api_key: <password>
    openstack_project_id: <region>
    openstack_region: <region>
    openstack_temp_url_key: <temp url key> # Mandatory, instructions below
  connection_options: # optional
    chunk_size: 2097152 # 2MBs - 1MB is the default
```

You can create as many entries as you would like for your different environments. For instance: `dev_openstack` for development, `test_openstack` for test environment, and `prod_openstack` for production. This way you can choose the appropriate container for each scenario.

Then register the provider in your `config/{environment}.rb` (`config/development.rb`/`config/test.rb`/`config/production.rb`)

For example, for the `dev_openstack` entry above, change the `config` variable in `config/development.rb` like the following:
```ruby
# Store uploaded files on the local file system (see config/storage.yml for options)
config.active_storage.service = :dev_openstack
```

## Migrating from fog-openstack `0.1.x` to `0.2.x`

1- From your configuration file (`config/storage.yml`) change the `openstack_auth_uri` from :
```yaml
openstack_auth_url: https://auth.example.com/v2.0/tokens
```
to :
```yaml
openstack_auth_url: https://auth.example.com
```
==> **specifying the version in the `openstack_auth_url` key would break things**

2- Second, specify the Keystone version (default is `v3.0`, however it is retro-compatible with v2.0 (So for now, adding this key won't affect the normal functioning of this gem, but is highly recommended)
- *Additionally v2.0 is deprecated.*
```yaml
openstack_identity_api_version: v2.0
```

For further informations, please refer to [fog-openstack's README](https://github.com/fog/fog-openstack/)

## Setting up a container

From your OpenStack provider website, create or sign in to your account.
Then from your dashboard, create a container, and save the configuration generated.

It is a good practice to create a separate container for each of your environments.
Once safely saved, you can add them to your storage configuration in your Rails application.
## `temp_url_key` configuration

the `openstack_temp_url_key` in your configuration is mandatory for generating URLs (expiring ones) as well as for Direct Upload. You can set it up with `Swift` or with the `Fog/OpenStack` gem. More instructions on how to set it up with Swift are found [HERE](https://docs.openstack.org/swift/latest/api/temporary_url_middleware.html#secret-keys).

To create it and post it you can use `bin/create_and_post_tempurl_key.sh` after having set your environment.
To set your environment set :
```shell
export OS_AUTH_URL "https://auth.cloud.ovh.net"
export OS_IDENTITY_API_VERSION "3"

export OS_PROJECT_ID="your project id"

# In addition to the owning entity (tenant), openstack stores the entity
# performing the action as the **user**.
export OS_USERNAME="your username"

# With Keystone you pass the keystone password.
export OS_PASSWORD="your secret passwor"

# If your configuration has multiple regions, we set that information here.
# OS_REGION_NAME is optional and only valid in certain environments.
export OS_REGION_NAME="BHS1"
```

To setup travis tests, you need to set `OPENSTACK_TEMP_URL_KEY`.

## `ActiveStorage::Openstack`'s Content-Type handling

OpenStack Swift handles the Content-Type of an object differently from other object storage services. You cannot overwrite the Content-Type via a temp URL. This gem will try very hard to set the right Content-Type for an object at object creation (either via server upload or direct upload) but this is wrong in some edge cases (e.g. you use direct upload and the browser provides a wrong mime type).

For these edge cases `ActiveStorage::Blob::Identifiable` downloads the first 4K of a file, identifies the content type and saves the result in the database. For `ActiveStorage::Openstack` we also need to update the Content-Type of the object. This is done automatically with a little monkey patch.

## Testing
First, run `bundle` to install the gem dependencies (both development and production)
```shell
$ bundle
```
Then, from the root of the plugin, copy the following file and fill in the appropriate credentials.
**Preferably, set up a container for your testing, separate from production.**
```shell
$ cp test/configurations.example.yml test/configurations.yml
$ source ./bin/openrc.sh
```
And then run the tests:
```shell
$ bin/test
```

## Contributions
Contributions are welcome. Feel free to open any issues if you encounter any bug, or if you want to suggest a feature by clicking here: https://github.com/ShamoX/activestorage-openstack/issues

I use the git flow scheme then, when wanting to merge, please target the `develop`
branch and not the `master`. I would recommand you to use `git flow` also, and
use the following configuration (which is the default):
```
$ git flow init
Which branch should be used for bringing forth production releases?
   - master
Branch name for production releases: [master]
Branch name for "next release" development: [develop]

How to name your supporting branch prefixes?
Feature branches? [feature/]
Bugfix branches? [bugfix/]
Release branches? [release/]
Hotfix branches? [hotfix/]
Support branches? [support/]
Version tag prefix? []
Hooks and filters directory? [/home/rlaures/dev/activestorage-openstack/.git/hooks]
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
