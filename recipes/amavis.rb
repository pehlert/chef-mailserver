package "amavisd-new"

default_config = %w(01-debian
  05-domain_id
  05-node_id
  15-av_scanners
  15-content_filter_mode
  20-debian_defaults
  21-ubuntu_defaults
  25-amavis_helpers
  30-template_localization
  40-policy_banks 
  50-user)

default_config.each do |filename|
  file "/etc/amavis/conf.d/#{filename}" do
    action :delete
    
    notifies :restart, "service[amavis]"
  end
end

template "/etc/amavis/conf.d/01-basic" do
  source "amavis/basic.erb"
  owner "root"
  group "root"
  mode 0644

  notifies :restart, "service[amavis]"
end

service "amavis" do
  supports [:restart]
  action [:enable, :start]
end