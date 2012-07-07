%w(spamassassin razor pyzor).each do |pkg|
  package pkg
end

template "/etc/default/spamassassin" do
  source "spamassassin/default.erb"
  mode 0644
  owner "root"
  group "root"
end