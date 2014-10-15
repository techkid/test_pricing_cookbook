include_recipe "pe-nginx::service"
service "nginx" do
  action :stop
end
