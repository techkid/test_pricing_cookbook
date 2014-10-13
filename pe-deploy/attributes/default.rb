application_name = "pe"
force_default[:deploy][:target_application] = application_name
force_default[:deploy][application_name][:restart_command] = "../../shared/scripts/unicorn clean-restart"
force_default[:deploy][application_name][:service] = "unicorn"
force_default[:deploy][application_name][:needs_reload] = true
force_default[:deploy][application_name][:auto_bundle_on_deploy] = true

#----------
#force_default[:deploy][application_name][:database][:adapter] = "mysql2"



