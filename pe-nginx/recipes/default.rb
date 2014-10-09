Chef::Log.debug("Setting up Nginx")
package "nginx"

directory node[:nginx][:dir] do
  owner 'root'
  group 'root'
  mode '0755'
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

%w{sites-available sites-enabled conf.d}.each do |dir|
  directory File.join(node[:nginx][:dir], dir) do
    owner 'root'
    group 'root'
    mode '0755'
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

include_recipe "pe-nginx::service"
service "nginx" do
  action [ :enable, :start ]
end
