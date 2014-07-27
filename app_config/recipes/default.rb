node[:deploy].each do |application, deploy|

  template "#{deploy[:deploy_to]}/shared/config/mws.rb" do
    source "mws.rb.erb"
    mode "0660"
    owner deploy[:user]
    group deploy[:group]
    variables(:data => (deploy[:mws] || {}), :environment => deploy[:rails_env])
  end.run_action(:create)

end 
