#
# Cookbook Name:: jenkins
# Recipe:: default
#

# Using manual jenkins for now not jenkins gem. No ebuild seems to exist.
# Based on http://bit.ly/9Y852l

# You can use this in combination with http://github.com/bjeanes/ey_jenkins_proxy
# to serve jenkins publicly on a Jenkins-only EY instance. This is so you don't have to
# find a simple app to run on the instance in lieu of an actual staging/production site.
# Alternatively, set up nginx asa reverse proxy manually.

# We'll assume running jenkins under the default username
jenkins_user = node[:users].first[:username]
jenkins_port = 8082 # change this in your proxy if modified
jenkins_home = "/data/jenkins-ci"
jenkins_pid  = "#{jenkins_home}/tmp/pid"
plugins     = node[:jenkins_master][:plugins]

if ['solo'].include?(node[:instance_role])
  gem_package "bundler" do
    version '1.0.21'
    action :install
  end

  execute "setup-git-config-for-tagging" do
    command %Q{ sudo su #{jenkins_user} -c "git config --global user.email 'you@example.com' && git config --global user.name 'You are Special'" }
    not_if  %Q{ sudo su #{jenkins_user} -c "git config user.email" }
  end

  %w[logs tmp war plugins .].each do |dir|
    directory "#{jenkins_home}/#{dir}" do
      owner jenkins_user
      group jenkins_user
      mode  0755 unless dir == "war"
      action :create
      recursive true
    end
  end

  remote_file "#{jenkins_home}/jenkins.war" do
    source "http://mirrors.jenkins-ci.org/war/latest/jenkins.war"
    owner jenkins_user
    group jenkins_user
    not_if { FileTest.exists?("#{jenkins_home}/jenkins.war") }
  end

  template "/etc/init.d/jenkins" do
    source "init.sh.erb"
    owner "root"
    group "root"
    mode 0755
    variables(
      :user => jenkins_user,
      :port => jenkins_port,
      :home => jenkins_home,
      :pid  => jenkins_pid
    )
  end

  plugins.each do |plugin_version| # 'git-1.2.3'
    plugin, version = plugin_version.split(/-/)
    if version
      remote_file "#{jenkins_home}/plugins/#{plugin}.hpi" do
        source "http://mirrors.jenkins-ci.org/plugins/#{plugin}/#{version}/#{plugin}.hpi"
        owner jenkins_user
        group jenkins_user
        not_if { FileTest.exists?("#{jenkins_home}/plugins/#{plugin}.hpi") }
      end
    end
  end

  template "/data/nginx/servers/jenkins_reverse_proxy.conf" do
    source "proxy.conf.erb"
    owner jenkins_user
    group jenkins_user
    mode 0644
    variables(
      :port => jenkins_port
    )
  end

  execute "ensure-jenkins-is-running" do
    command "/etc/init.d/jenkins restart"
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