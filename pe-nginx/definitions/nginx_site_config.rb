define :nginx_site_config, template: "unicorn_site.erb", enable: true do
  include_recipe "pe-nginx::service"

  data = params[:data]

  template "#{node[:nginx][:dir]}/sites-available/#{data[:application]}" do
    Chef::Log.info("Generating Nginx site template for #{data[:application].inspect}")
    source params[:template]
    cookbook "pe-nginx"
    owner "root"
    group "root"
    mode 0644
    variables(:data => data)
    if File.exists?("#{node[:nginx][:dir]}/sites-enabled/#{data[:application]}")
      notifies :reload, "service[nginx]", :delayed
    end
  end

  file "#{node[:nginx][:dir]}/sites-enabled/default" do
    action :delete
    only_if do
      File.exists?("#{node[:nginx][:dir]}/sites-enabled/default")
    end
  end

  if params[:enabled]
    execute "symlink to enabed sites" do
      command "ln -sf #{node[:nginx][:dir]}/sites-available/#{data[:application]} #{node[:nginx][:dir]}/sites-enabled/#{data[:application]}"
      notifies :reload, "service[nginx]"
      not_if do File.symlink?("#{node[:nginx][:dir]}/sites-available/#{data[:application]}") end
    end
  else
    # remove the symlink
  end
end
