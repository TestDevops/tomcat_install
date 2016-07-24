#Creating varibles For the tomcat
user = node['nexus']['user']
uid = node['nexus']['uid'] 
gid = node['nexus']['gid'] 
group = node['nexus']['group'] 

# Creating a group
group group do 
	gid gid
	action :create
end

# Creating a user
user user do 
	gid gid
	uid uid
	action :create
end

# adding user to a group

group group do
	gid gid 
	members user
	append true
	action :create
end

# Creating Directory for the installation 
directory node['nexus']['tomcat_location'] do
	owner user
	group group
	mode 0755
	recursive true
	action :create
end






