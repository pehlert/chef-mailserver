# NOTE: amavisd recipe must have been run before we get here!

package "clamav-daemon"

# Add user clamav to amavis group to make them play together!
group "amavis" do
  members ['clamav']
  append true
end

service "clamav" do
  service_name "clamav-daemon"
  supports :status => true, :restart => true, :reload => true
  action [:enable, :restart]
end
