include_recipe "build-essential"
include_recipe "python::default"
include_recipe "nginx::default"

directory "#{node['tornado']['app_root']}" do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

cookbook_file "#{node['tornado']['app_root']}/#{node['tornado']['app_name']}.py" do
  source "#{node['tornado']['app_name']}.py"
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

%w{htop git-core tmux curl tree unzip python-setuptools python-dev build-essential}.each do |pkg|
  package pkg do
    action :install
  end
end

template '/etc/nginx/sites-available/tornado' do
  source 'nginx.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

nginx_site "default" do
  enable false
end

nginx_site "tornado"

service "nginx" do
  enabled true
  running true
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end

python_virtualenv node['tornado']['virtual_env_path'] do
    interpreter "python2.7"
    owner "ubuntu"
    group "ubuntu"
    action :create
end

execute "Install tornado" do
  command "#{node['tornado']['virtual_env_path']}/bin/pip install tornado"
  not_if { File.exists?("#{node['tornado']['virtual_env_path']}/lib/python2.7/site-packages/tornado") }
end

template '/etc/init/tornado.conf' do
  source 'tornado.conf.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables({
    app_root: node['tornado']['app_root'],
    virtual_env: node['tornado']['virtual_env_path'],
    app_name: node['tornado']['app_name'],
    user: node['tornado']['user']
  })
end

service "tornado" do
  provider Chef::Provider::Service::Upstart
  enabled true
  supports :status => true, :reload => true
  action [:start, :enable]
end
