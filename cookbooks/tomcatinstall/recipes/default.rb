#
# Cookbook Name:: tomcatinstall
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#Name= Saikrishna Mandava
# All rights reserved - Do Not Redistribute
#


group node['nexus']['group'] do
  gid node['nexus']['gid']
  action :create
  #ignore_failure :true
end

# # Create tomcat user
user node['nexus']['user'] do
  gid node['nexus']['gid']
  uid node['nexus']['uid']
  action :create
  #ignore_failure :true
end

# Creating Directory for the installation 
directory node['nexus']['tomcat_location'] do
	owner node['nexus']['user']
	group node['nexus']['group']
	mode 0755
	recursive true
	action :create
end


#Downloading Tomcat Zip file From server

remote_file  "#{Chef::Config[:file_cache_path]}/apache-tomcat-7.0.70.tar.gz" do
	source  'http://mirror.cc.columbia.edu/pub/software/apache/tomcat/tomcat-7/v7.0.70/bin/apache-tomcat-7.0.70.tar.gz'
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
		tar xvf #{Chef::Config[:file_cache_path]}/apache-tomcat-7.0.70.tar.gz
		mv #{Chef::Config[:file_cache_path]}/#{node['nexus']['tomcat_untar']} #{node['nexus']['server']}
		rm -rf #{node['nexus']['server']}/webapps/*
	EOH
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
template "/etc/init.d/tomcat-init.sh" do
	source 'tomcat-init.sh.erb'
	user node['nexus']['user']
	group node['nexus']['group'] 
	mode "0755"
	backup false
	variables(
	:home_dir => node['nexus']['tomcat_location'],
	:service_name => node['nexus']['server']
	)
	#notifies :run, 'execute[start_tomcat_service]', :immediately
end

template "/var/lib/tomcat/tomcat_server/conf/tomcat-users.xml" do
	source 'tomcat-user.erb'
	user node['nexus']['user']
	group node['nexus']['group'] 
	mode "0755"
	backup false
	notifies :run, 'execute[start_tomcat_service]', :immediately
end

template "/var/lib/tomcat/tomcat_server/conf//server.xml" do
	source 'server.erb'
	user user
	group group
	mode "0755"
	backup false
	notifies :run, 'execute[start_tomcat_service]', :immediately
end

######Starting Tomcat Service ########
execute  'start_tomcat_service' do 
	command "service tomcat-init.sh start"
	action :nothing
end
