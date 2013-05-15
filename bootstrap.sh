#!/usr/bin/env bash

apt-get update
apt-get -y install git-core irb rubygems libopenssl-ruby ruby1.8-dev rake build-essential

gem install json
gem install -v 1.3.6 rubygems-update && ruby `gem env gemdir`/gems/rubygems-update-1.3.6/setup.rb 
gem install infusionsoft
