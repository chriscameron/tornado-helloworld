# Tornado Web Test

## Summmary

This repo builds and deploys a simple Tornado web app and server both locally using test kitchen and remotely using chef provisioning.

### Prerequisite Software For All Methods

Install the following software packages (these instructions assume you are using a recent version of Mac OS X):

[Chef Development Kit](https://downloads.chef.io/chef-dk/)

To run the local development environment install the following:

[Virtual Box](https://www.virtualbox.org/wiki/Downloads)

[Vagrant](https://www.vagrantup.com/downloads.html)

### Install packages to spin up infrastructure

      chef gem install chef-provisioning-aws chef-provisioning

### Build with Test Kitchen locally

This will build a local environment and run infrastructure tests on the built server / VM.

      kitchen verify

### Destroy local Test Kitchen

      kitchen destroy


### How to Create Infrastructure on Amazon AWS

Configure your local AWS environment according to this guide: [Credential Setup](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-config-files) or use the following steps if you already have your access key and secret:

Create the .aws directory:

      mkdir ~/.aws

Then edit both config files as below:

      vi ~/.aws/credentials

      [default]
      aws_access_key_id=keyhere
      aws_secret_access_key=secretkeyhere

      vi ~/.aws/config

      [default]
      region=us-east-1
      output=json

Generate a key for Chef Provisioning

      ssh-keygen -t rsa -N "" -f .chef/keys/ref-key-pair-eni

Run the following command using chef provisioning:

      chef-client -z amazon_ec2.rb

### Destroy Amazon Infrastructure

      chef-client -z amazon_ec2_destroy.rb
