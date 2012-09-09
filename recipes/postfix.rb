#
# Cookbook Name:: mailserver
# Recipe:: postfix
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

%w(postfix postfix-pgsql libsasl2-2).each do |pkg|
  package pkg
end

service "postfix" do
  supports :status => true, :restart => true, :reload => true
  action :enable
end

# Get primary IPs of all nodes
hosts = search(:node, "*:*").map { |n| n["ipaddress"] }

template "/etc/postfix/main.cf" do
  source "postfix/main.cf.erb"
  variables(:mynetworks => hosts)
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "postfix")
end
  
template "/etc/postfix/master.cf" do
  source "postfix/master.cf.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "postfix")
end

# Setup the virtual maps
%w(pgsql_relay_domain pgsql_virtual_alias pgsql_virtual_domain pgsql_virtual_mailbox).each do |file|
  template "/etc/postfix/#{file}_maps.cf" do
    source "postfix/#{file}_maps.cf.erb"
    mode 0600
    owner "root"
    group "root"
    notifies :restart, resources(:service => "postfix")
  end
end

service "postfix" do
  action :start
end
