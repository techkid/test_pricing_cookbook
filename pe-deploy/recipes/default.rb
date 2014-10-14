Chef::Log.info("Deploying")

include_recipe "dependencies"

application = node[:deploy_target]
data = node[:deploy][application]

opsworks_deploy_dir do
  user data[:user]
  group data[:group]
  path data[:deploy_to]
end

include_recipe "pe-nginx"
include_recipe "pe-unicorn"

directory "#{data[:deploy_to]}" do
  group data[:group]
  owner data[:user]
  mode "0775"
  action :create
  recursive true
end

if data[:scm]
  ensure_scm_package_installed(data[:scm][:scm_type])
  case data[:scm][:scm_type].to_s
    when 'git'
      prepare_git_checkouts(
        :user => data[:user],
        :group => data[:group],
        :home => data[:home],
        :ssh_key => data[:scm][:ssh_key]
      )
    when 'svn'
      prepare_svn_checkouts(
        :user => data[:user],
        :group => data[:group],
        :home => data[:home],
        :deploy => data,
        :application => application
      )
    when 'archive'
      repository = prepare_archive_checkouts(data[:scm])
      node.set[:deploy][application][:scm] = {
        :scm_type => 'git',
        :repository => repository
      }
    when 's3'
      repository = prepare_s3_checkouts(data[:scm])
      node.set[:deploy][application][:scm] = {
        :scm_type => 'git',
        :repository => repository
      }
  end
end

# reload data, not sure if needed and if its the right way (amazon does it like this though)
data = node[:deploy][application]

directory "#{data[:deploy_to]}/shared/cached-copy" do
  recursive true
  action :delete
  only_if do
    data[:delete_cached_copy]
  end
end

ruby_block "change HOME to #{data[:home]} for source checkout" do
  block do
    ENV['HOME'] = "#{data[:home]}"
  end
end



#-----------------

if data[:scm] && data[:scm][:scm_type] != 'other'
  Chef::Log.debug("Checking out source code of application #{application} with type #{data[:application_type]}")
  deploy data[:deploy_to] do
    provider Chef::Provider::Deploy.const_get(data[:chef_provider])
    keep_releases data[:keep_releases]
    repository data[:scm][:repository]
    user data[:user]
    group data[:group]
    revision data[:scm][:revision]
    migrate data[:migrate]
    migration_command data[:migrate_command]
    environment data[:environment].to_hash
    purge_before_symlink(data[:purge_before_symlink]) unless data[:purge_before_symlink].nil?
    create_dirs_before_symlink(data[:create_dirs_before_symlink])
    symlink_before_migrate(data[:symlink_before_migrate])
    symlinks(data[:symlinks]) unless data[:symlinks].nil?
    action data[:action]
    restart_command '../../shared/scripts/unicorn clean-restart'

    case data[:scm][:scm_type].to_s
    when 'git'
      scm_provider :git
      enable_submodules data[:enable_submodules]
      shallow_clone data[:shallow_clone]
    when 'svn'
      scm_provider :subversion
      svn_username data[:scm][:user]
      svn_password data[:scm][:password]
      svn_arguments "--no-auth-cache --non-interactive --trust-server-cert"
      svn_info_args "--no-auth-cache --non-interactive --trust-server-cert"
    else
      raise "unsupported SCM type #{data[:scm][:scm_type].inspect}"
    end

    before_migrate do
      # FYI: Chef::Provider::Deploy method
      link_tempfiles_to_current_release

      if data[:auto_bundle_on_deploy]
        OpsWorks::RailsConfiguration.bundle(application, node[:deploy][application], release_path)
      end

      node.default[:deploy][application][:database][:adapter] = OpsWorks::RailsConfiguration.determine_database_adapter(
        application,
        node[:deploy][application],
        release_path,
        :force => node[:force_database_adapter_detection],
        :consult_gemfile => node[:deploy][application][:auto_bundle_on_deploy]
      )
      template "#{node[:deploy][application][:deploy_to]}/shared/config/database.yml" do
        cookbook "rails"
        source "database.yml.erb"
        mode "0660"
        owner node[:deploy][application][:user]
        group node[:deploy][application][:group]
        variables(
          :database => node[:deploy][application][:database],
          :environment => node[:deploy][application][:rails_env]
        )
        only_if do
          data[:database][:host].present?
        end
      end.run_action(:create)
      run_callback_from_file("#{release_path}/deploy/before_migrate.rb")
    end
  end
end

ruby_block "change HOME back to /root after source checkout" do
  block do
    ENV['HOME'] = "/root"
  end
end

nginx_site_config do
  data data
end

template "/etc/logrotate.d/opsworks_app_#{application}" do
  backup false
  source "logrotate.erb"
  cookbook 'deploy'
  owner "root"
  group "root"
  mode 0644
  variables(:log_dirs => ["#{data[:deploy_to]}/shared/log"])
end
























