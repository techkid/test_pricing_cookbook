Chef::Log.info("Setting up Unicorn")

ruby_block "ensure only our unicorn version is installed by deinstalling any other version" do
  block do
    ensure_only_gem_version('unicorn', node[:unicorn][:version])
  end
end

application = node[:deploy][:target_application]
data = node[:deploy][application]

#--------
Chef::Log.info("#{data.inspect}")
#--------

opsworks_deploy_user do
  deploy_data data
end

opsworks_deploy_dir do
  user data[:user]
  group data[:group]
  path data[:deploy_to]
end

template "#{data[:deploy_to]}/shared/scripts/unicorn" do
  mode '0755'
  owner data[:user]
  group data[:group]
  source "unicorn.service.erb"
  variables(:deploy => data, :application => application)
end

service "unicorn_#{application}" do
  start_command "#{data[:deploy_to]}/shared/scripts/unicorn start"
  stop_command "#{data[:deploy_to]}/shared/scripts/unicorn stop"
  restart_command "#{data[:deploy_to]}/shared/scripts/unicorn restart"
  status_command "#{data[:deploy_to]}/shared/scripts/unicorn status"
  action :nothing
end

template "#{data[:deploy_to]}/shared/config/unicorn.conf" do
  mode '0644'
  owner data[:user]
  group data[:group]
  source "unicorn.conf.erb"
  variables(
    :deploy => data,
    :application => application,
    :environment => OpsWorks::Escape.escape_double_quotes(data[:environment_variables])
  )
end
