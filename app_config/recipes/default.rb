node[:deploy].each do |application, deploy|

  template "#{deploy[:deploy_to]}/shared/config/mws.yml" do
    source "mws.yml.erb"
    mode "0660"
    owner deploy[:user]
    group deploy[:group]
    variables(:data => (deploy[:mws] || {}), :environment => deploy[:rails_env])
  end.run_action(:create)

end 
