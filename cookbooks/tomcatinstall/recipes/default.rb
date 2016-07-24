#
# Cookbook Name:: tomcatinstall
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#include_recipe 'create-user'

user = node['nexus']['user']
group = node['nexus']['group']


#Downloading Tomcat Zip file From server

remote_file  "#{Chef::Config[:file_cache_path]}/{#node['nexus']['tomcat_version']}" do
	source  'http://192.168.35.1:8081/nexus/service/local/repositories/thirdparty/content/App/Tomcat/7.0.70/Tomcat-7.0.70.zip'
	owner  node['nexus']['user']
	group node['nexus']['group']
	mode 0755
	backup false
end


#INstalling Tomcat Seerver 
bash 'install' do 
	cwd node['nexus']['tomcat_location']
	user node['nexus']['user']
	group node['nexus']['group']
	code <<-EOH
		tar xvzf #{Chef::Config[:file_cache_path]}/{#node['nexus']['tomcat_version']}
		mv #{node['nexus']['tomcat_untar']} #{node['nexus']['server']}
		rm -rf #{node['nexus']['server']}/webapps
		EOH
	not_if { ::File.exists?(/var/lib/tomcat) } 
end




# bash 'Install_Tomcat' do
# 	cwd node['nexus']['tomcat_location'] 
# 	user node['nexus']['user']
# 	group node['nexus']['group']
# 	code <<-EOH
# 	  tar xvzf #{Chef::Config[:file_cache_path]}/{#node['nexus']['tomcat_version']}
# 	  mv node['nexus']['tomcat_untar'] #{node['nexus']['server']}
# 	  rm -rf #{node['nexus']['server']/webapps
# 	EOH
# end


##Creating Tomcat Init Script
template "/etc/init.d/tomcat_#{node['tomcat']['server']}" do
	source 'tomcat_init.sh.erb'
	user node['nexus']['user']
	group node['nexus']['group'] 
	mode "0755"
	backup false
	variables(
	:home_dir => node['nexus']['tomcat_location'],
	:service_name => node['nexus']['server']
	)
	notifies :run, 'execute[start_tomcat_service]', :immediately
end

teamplate "#{node['nexus']['tomcat_location']}/#{['nexus']['server'] }/conf/tomcat-users.xml" do
	source 'tomcat-user.erb'
	user node['nexus']['user']
	group node['nexus']['group'] 
	mode "0755"
	backup false
	notifies :run, 'execute[start_tomcat_service]', :immediately
end

template "#{node['nexus']['tomcat_location']}/#{['nexus']['server'] }/conf/server.xml" do
	source 'server.erb'
	user user
	group group
	mode "0755"
	backup false
	notifies :run, 'execute[start_tomcat_service]', :immediately
end

######Starting Tomcat Service ########
execute  'start_tomcat_service' do 
	command "service tomcat_#{node['tomcat']['server']} start"
	action :nothing
end