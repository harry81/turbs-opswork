#
# Cookbook Name:: turbs
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#
#


package "g++"
package "git"
package "libffi-dev"
package "libncurses-dev"
package "libpq-dev"
package "libxml2-dev"
package "libxslt1.1"
package "libxslt1-dev"
package "nginx"
package "python-dev"
package "python-imaging"
package "python-virtualenv"
package "rabbitmq-server"
package "tmux"
package "uwsgi"
package "uwsgi-plugin-python"
package "zsh"

include_recipe "database::postgresql"

user node.turbs.deploy do
  comment 'turbs user'
  home node.turbs.deploy_path
  uid '1234'
  shell '/bin/zsh'
  supports :manage_home => true
  password '$1$077OG8Lh$iarEmNtv.2wybHMPNDgr81'
  action :create
end

directory node.turbs.src_path do
  owner node.turbs.deploy
  group node.turbs.deploy
  mode "0755"
  recursive true
  action :create
end

template '/home/deploy/.zshrc' do
  source 'zshrc.erb'
  owner 'deploy'
  mode '0644'
end

template '/etc/nginx/sites-available/turbs_conf.nginx' do
  source 'turbs_conf_nginx.erb'
  owner 'deploy'
  mode '0644'
end

bash "link nginx conf" do
  user "root"
  code <<-BASH
  if [ ! -f /etc/nginx/sites-enabled/turbs_conf.nginx ]; then
    ln -s /etc/nginx/sites-available/turbs_conf.nginx  /etc/nginx/sites-enabled/
  fi
  /etc/init.d/nginx restart
  BASH
  action :run
end


ENV['HOME'] = node.turbs.deploy_path

postgresql_connection_info = {
  :host     => '127.0.0.1',
  :port     => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

# Create a postgresql user but grant no privileges
postgresql_database_user 'turbs' do
  connection postgresql_connection_info
  password   'turbs81'
  action     :create
end

# create a postgresql database with additional parameters
postgresql_database 'turbs' do
  connection postgresql_connection_info
  template 'DEFAULT'
  encoding 'DEFAULT'
  tablespace 'DEFAULT'
  connection_limit '-1'
  owner 'turbs'
  action :create
end

hostsfile_entry '127.0.0.1' do
  hostname  'redis postgres rabbitmq'
  action    :create
end
