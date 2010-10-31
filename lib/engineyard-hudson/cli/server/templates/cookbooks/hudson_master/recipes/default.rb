#
# Cookbook Name:: hudson
# Recipe:: default
#

# Using manual hudson for now not hudson gem. No ebuild seems to exist.
# Based on http://bit.ly/9Y852l

# You can use this in combination with http://github.com/bjeanes/ey_hudson_proxy
# to serve hudson publicly on a Hudson-only EY instance. This is so you don't have to
# find a simple app to run on the instance in lieu of an actual staging/production site.
# Alternatively, set up nginx asa reverse proxy manually.

# We'll assume running hudson under the default username
hudson_user = node[:users].first[:username]
hudson_port = 8082 # change this in your proxy if modified
hudson_home = "/data/hudson-ci"
hudson_pid  = "#{hudson_home}/tmp/pid"
plugins     = node[:hudson_master][:plugins]

if ['solo'].include?(node[:instance_role])
  gem_package "bundler" do
    source "http://gemcutter.org"
    action :install
  end

  execute "setup-git-config-for-tagging" do
    command %Q{ sudo su #{hudson_user} -c "git config --global user.email 'you@example.com' && git config --global user.name 'You are Special'" }
    not_if  %Q{ sudo su #{hudson_user} -c "git config user.email" }
  end

  %w[logs tmp war plugins .].each do |dir|
    directory "#{hudson_home}/#{dir}" do
      owner hudson_user
      group hudson_user
      mode  0755 unless dir == "war"
      action :create
      recursive true
    end
  end

  remote_file "#{hudson_home}/hudson.war" do
    source "http://hudson-ci.org/latest/hudson.war"
    owner hudson_user
    group hudson_user
    not_if { FileTest.exists?("#{hudson_home}/hudson.war") }
  end

  template "/etc/init.d/hudson" do
    source "init.sh.erb"
    owner "root"
    group "root"
    mode 0755
    variables(
      :user => hudson_user,
      :port => hudson_port,
      :home => hudson_home,
      :pid  => hudson_pid
    )
    not_if { FileTest.exists?("/etc/init.d/hudson") }
  end

  plugins.each do |plugin|
    remote_file "#{hudson_home}/plugins/#{plugin}.hpi" do
      source "http://hudson-ci.org/latest/#{plugin}.hpi"
      owner hudson_user
      group hudson_user
      not_if { FileTest.exists?("#{hudson_home}/plugins/#{plugin}.hpi") }
    end

  end

  template "/data/nginx/servers/hudson_reverse_proxy.conf" do
    source "proxy.conf.erb"
    owner hudson_user
    group hudson_user
    mode 0644
    variables(
      :port => hudson_port
    )
    not_if { FileTest.exists?("/data/nginx/servers/hudson_reverse_proxy.conf") }
  end

  execute "ensure-hudson-is-running" do
    command "/etc/init.d/hudson restart"
  end

  execute "Restart nginx" do
    command "/etc/init.d/nginx restart"
  end

  execute "Generate key pair for slaves" do
    key_path = "/home/#{node[:users].first[:username]}/.ssh/id_rsa"
    command "ssh-keygen -f #{key_path} -N ''"
    not_if { FileTest.exists?(key_path) }
  end
end