#
# Cookbook Name:: hudson_slave
# Recipe:: default
#

env_name = node[:environment][:name]
username = node[:users].first[:username]

if ['solo','app_master'].include?(node[:instance_role]) && env_name =~ /_(ci|hudson_slave)$/
  # gem_package "hudson" do
  #   source "http://gemcutter.org"
  #   version "0.3.0.beta.3"
  #   action :install
  # end

  execute "install_hudson_in_resin" do
    command "/usr/local/ey_resin/ruby/bin/gem install #{node[:hudson_slave][:gem][:install]}"
    not_if { FileTest.directory?("/usr/local/ey_resin/ruby/gems/1.8/gems/#{node[:hudson_slave][:gem][:version]}") }
  end
  
  ruby_block "authorize_hudson_master_key" do
    authorized_keys = "/home/#{node[:users].first[:username]}/.ssh/authorized_keys"
    block do
      File.open(authorized_keys, "a") do |f|
        f.puts node[:hudson_slave][:master][:public_key]
      end
    end
    not_if "grep '#{node[:hudson_slave][:master][:public_key]}' #{authorized_keys}"
  end
  
  execute "setup-git-config-for-tagging" do
    command %Q{ sudo su #{username} -c "git config --global user.email 'you@example.com' && git config --global user.name 'You are Special'" }
    not_if  %Q{ sudo su #{username} -c "git config user.email" }
  end
  
  ruby_block "add-slave-to-master" do
    block do
      Gem.clear_paths
      require "hudson"
      require "hudson/config"

      Hudson::Api.setup_base_url(node[:hudson_slave][:master])
      
      # Tell master about this slave
      Hudson::Api.add_node(
        :name        => env_name,
        :description => "Automatically added by Engine Yard AppCloud for environment #{env_name}",
        :slave_host  => node[:engineyard][:environment][:instances].first[:public_hostname],
        :slave_user  => username,
        :executors   => [node[:applications].size, 1].max,
        :label       => node[:applications].keys.join(" ")
      )
    end
    action :create
  end

  # ey_cloud_report "hudson-slave-setup" do
  #   message "Added instance to Hudson CI server"
  # end
  
  ruby_block "tell-master-about-job" do
    block do
      node[:hudson_slave][:applications] ||= []

      # Tell server about each application
      node[:applications].each do |app_name, data|

        job_config = Hudson::JobConfigBuilder.new(:rails) do |c|
          c.scm           = data[:repository_name]
          c.assigned_node = app_name
        end

        if Hudson::Api.create_job(app_name, job_config, :override => true)
          build_url = "#{Hudson::Api.base_uri}/job/#{app_name}/build"
          node[:hudson_slave][:applications] << { :name => app_name, :success => true, :build_url => build_url }
          Hudson::Api.build_job(app_name)
        else
          node[:hudson_slave][:applications] << { :name => app_name, :success => false }
        end
      end
    end
    action :create
  end

  # ey_cloud_report "hudson-jobs-setup" do
  #   node[:hudson_slave][:applications].each do |app|
  #     message "Setup build trigger to #{app[:build_url]}"
  #   end
  # end

end