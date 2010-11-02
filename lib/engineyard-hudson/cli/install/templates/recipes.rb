#
# Cookbook Name:: hudson_slave
# Recipe:: default
#

env_name = node[:environment][:name]
username = node[:users].first[:username]

if ['solo','app_master'].include?(node[:instance_role]) && env_name =~ /(ci|hudson_slave)$/
  gem_package "bundler" do
    action :install
  end

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

  ruby_block "tell-master-about-new-jobs" do
    block do
      begin
        job_names   = Hudson::Api.summary["jobs"].map {|job| job["name"]} # TODO Hudson::Api.job_names
        app_names   = node[:applications].keys
        apps_to_add = app_names - job_names

        # Tell server about each application
        apps_to_add.each do |app_name|
          data = node[:applications][app_name]

          job_config = Hudson::JobConfigBuilder.new("rails") do |c|
            c.scm           = data[:repository_name]
            c.assigned_node = app_name
            c.envfile       = "/data/#{app_name}/shared/config/git-env"
          end
        
          Hudson::Api.create_job(app_name, job_config)
          Hudson::Api.build_job(app_name)
        end
      rescue Errno::ECONNREFUSED, Errno::EAFNOSUPPORT
        raise Exception, "No connection available to the Hudson server (#{Hudson::Api.base_uri})."
      end
    end
    action :create
  end

end
