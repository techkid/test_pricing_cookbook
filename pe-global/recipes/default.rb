Chef::Log.info("Setting up global stuff")

Chef::Log.info("Node users: #{node[:ssh_users]}")
Chef::Log.info("Node suders: #{node[:sudoers]}")


user "dude" do
  supports :manage_home => true
  comment "Random User"
  gid "sudo"
  home "/home/dude"
  shell "/bin/bash"
  password "$1$nq.2kYl7$7BjxRUFwZSHV3Gs./0VnD1"
  action :create
end

group "www-data" do
  members "dude"
end


