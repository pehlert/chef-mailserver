#
# Cookbook Name:: mailserver
# Recipe:: clamav
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
