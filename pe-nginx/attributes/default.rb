case node[:platform_family]
  when "debian"
    default[:nginx][:dir]        = "/etc/nginx"
    default[:nginx][:log_dir]    = "/var/log/nginx"
    default[:nginx][:user]       = "www-data"
    default[:nginx][:binary]     = "/usr/sbin/nginx"
    if node[:platform_version] == "14.04"
      default[:nginx][:pid_file] = "/run/nginx.pid"
    else
      default[:nginx][:pid_file] = "/var/run/nginx.pid"
    end
  when "rhel"
    default[:nginx][:dir]        = "/etc/nginx"
    default[:nginx][:log_dir]    = "/var/log/nginx"
    default[:nginx][:user]       = "nginx"
    default[:nginx][:binary]     = "/usr/sbin/nginx"
    default[:nginx][:pid_file]   = "/var/run/nginx.pid"
  else
    Chef::Log.error "Cannot configure nginx, platform unknown"
end

default[:nginx][:worker_processes] = 4
default[:nginx][:worker_priority] = -5
default[:nginx][:worker_connections] = 2048

log_format = <<-LFS
'$remote_addr - $remote_user [$time_local] '
  '"$request" $status $body_bytes_sent '
  '"$http_referer" "$http_user_agent" '
  '$request_time $upstream_response_time $pipe'
LFS
default[:nginx][:log_format] = {extended: log_format}

default[:nginx][:client_max_body_size] = "10m"
default[:nginx][:keepalive] = "on"
default[:nginx][:keepalive_timeout] = 70

default[:nginx][:gzip] = "on"
default[:nginx][:gzip_static] = "on"
default[:nginx][:gzip_http_version] = "1.1"
default[:nginx][:gzip_disable] = "msie6"
default[:nginx][:gzip_vary] = "on"
default[:nginx][:gzip_proxied] = "any"
default[:nginx][:gzip_comp_level] = "3"
default[:nginx][:gzip_buffers] = "64 8k"
default[:nginx][:gzip_types] = [
  "application/x-javascript",
  "application/xhtml+xml",
  "application/xml",
  "application/xml+rss",
  "application/x-font-ttf",
  "font/opentype",
  "text/css",
  "text/javascript",
  "text/plain",
  "text/xml"
]

default[:nginx][:server_names_hash_bucket_size] = 64

=begin
default[:nginx][:proxy_read_timeout] = 60
default[:nginx][:proxy_send_timeout] = 60
=end


