Chef::Log.info("Setting up global stuff")

Chef::Log.info("Node users: #{node[:ssh_users]}")
Chef::Log.info("Node suders: #{node[:sudoers]}")

