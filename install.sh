#!/bin/bash 
sudo apt-get -y install build-essential bison openssl libreadline5 libreadline-dev curl git-core zlib1g zlib1g-dev libssl-dev vim libsqlite3-0 libsqlite3-dev sqlite3 libreadline6-dev libreadline6-dev libxml2-dev git-core subversion autoconf xorg-dev libgl1-mesa-dev libglu1-mesa-dev ruby rubygems
sudo gem install snmp json
chmod +x ./ruby_carlos.rb
# sudo ln -s `readlink -e ./ruby_carlos.rb` /usr/bin/ruby_carlos
