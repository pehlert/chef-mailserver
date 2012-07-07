%w(postfix postfix-pgsql libsasl2-2).each do |pkg|
  package pkg
end

service "postfix" do
  supports :status => true, :restart => true, :reload => true
  action :enable
end

template "/etc/postfix/main.cf" do
  source "postfix/main.cf.erb"
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