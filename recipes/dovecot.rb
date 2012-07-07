#
# Cookbook Name:: mailserver
# Recipe:: dovecot
#
# Copyright 2012, Pascal Ehlert
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

%w(dovecot-common dovecot-imapd dovecot-sieve dovecot-pgsql dovecot-managesieved).each do |pkg|
  package pkg
end

group "dovenull" do
  members ['dovenull']
end

# Users and groups have changed here and our templates rely on ohai's attributes.
# Reload them!
ohai "reload" do
  action :reload
end

directory "/var/mail" do
  owner "dovenull"
  group "dovenull"
  mode 0700
end

service "dovecot" do
  supports :status => true, :restart => true, :reload => true
  action :enable
end

template "/etc/dovecot/dovecot.conf" do
  source "dovecot/dovecot.conf.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "dovecot")
end
  
template "/etc/dovecot/dovecot-sql.conf.ext" do
  source "dovecot/dovecot-sql.conf.ext.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, resources(:service => "dovecot")
end

# Setup the conf.d files
%w(10-auth 10-director 10-logging 10-mail 10-master 10-ssl 15-lda 20-imap 20-managesieve 90-acl 90-plugin 90-quota 90-sieve).each do |file|
  template "/etc/dovecot/conf.d/#{file}.conf" do
    source "dovecot/#{file}.conf.erb"
    mode 0644
    owner "root"
    group "root"
    notifies :restart, resources(:service => "dovecot")
  end
end

%w(master sql).each do |file|
  template "/etc/dovecot/conf.d/auth-#{file}.conf.ext" do
    source "dovecot/auth-#{file}.conf.ext.erb"
    mode 0644
    owner "root"
    group "root"
    notifies :restart, resources(:service => "dovecot")
  end
end

