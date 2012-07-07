#
# Cookbook Name:: mailserver
# Recipe:: postfixadmin
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

include_recipe "lighttpd::php"

VERSION = "2.3.5"

# Dependencies
%w(php5-imap php5-pgsql).each do |pkg|
  package pkg
end

remote_file "#{Chef::Config[:file_cache_path]}/postfixadmin-#{VERSION}.tar.gz" do
  source "http://sourceforge.net/projects/postfixadmin/files/postfixadmin/postfixadmin-#{VERSION}/postfixadmin-#{VERSION}.tar.gz/download"
  checksum "9a72ed8d827fa2c7f641001f2aa87814"
  mode "0644"
  not_if { File.exists?("/var/www/postfixadmin-#{VERSION}") }
  notifies :run, "execute[unpack postfixadmin]", :immediately
end

execute "unpack postfixadmin" do
  command "tar xzvf #{Chef::Config[:file_cache_path]}/postfixadmin-#{VERSION}.tar.gz -C /var/www"
  action :nothing
end

template "/var/www/postfixadmin-#{VERSION}/config.local.php" do
  source "postfixadmin/config.local.php.erb"
  mode 0644
  owner "www-data"
  group "www-data"
end

lighttpd_vhost "postfixadmin" do
  host "admin.#{node[:fqdn]}"
  document_root "/var/www/postfixadmin-#{VERSION}"
  action [:create, :enable]
  notifies :restart, "service[lighttpd]"
end
