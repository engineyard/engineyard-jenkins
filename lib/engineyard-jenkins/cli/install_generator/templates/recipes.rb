#
# Cookbook Name:: jenkins_slave
# Recipe:: default
#

env_name      = node[:environment][:name]
framework_env = node[:environment][:framework_env]
username      = node[:users].first[:username]

if ['solo','app_master'].include?(node[:instance_role]) && env_name =~ /(ci|jenkins_slave)$/
  gem_package "bundler" do
    action :install
  end

  execute "install_jenkins_in_resin" do
    command "/usr/local/ey_resin/ruby/bin/gem install #{node[:jenkins_slave][:gem][:install]}"
    # not_if { FileTest.directory?("/usr/local/ey_resin/ruby/gems/1.8/gems/#{node[:jenkins_slave][:gem][:version]}") }
  end
  
  ruby_block "authorize_jenkins_master_key" do
    authorized_keys = "/home/#{node[:users].first[:username]}/.ssh/authorized_keys"
    block do
      File.open(authorized_keys, "a") do |f|
        f.puts node[:jenkins_slave][:master][:public_key]
      end
    end
    not_if "grep '#{node[:jenkins_slave][:master][:public_key]}' #{authorized_keys}"
  end
  
  execute "setup-git-config-for-tagging" do
    command %Q{ sudo su #{username} -c "git config --global user.email 'you@example.com' && git config --global user.name 'You are Special'" }
    not_if  %Q{ sudo su #{username} -c "git config user.email" }
  end
  
  ruby_block "add-slave-to-master" do
    block do
      Gem.clear_paths
      require "jenkins"
      require "jenkins/config"

      Jenkins::Api.setup_base_url(node[:jenkins_slave][:master])
      
      Jenkins::Api.delete_node(env_name)
      
      # Tell master about this slave
      Jenkins::Api.add_node(
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
        job_names   = Jenkins::Api.job_names
        app_names   = node[:applications].keys
        apps_to_add = app_names - job_names

        # Tell server about each application
        apps_to_add.each do |app_name|
          data = node[:applications][app_name]

          # job_config = Jenkins::JobConfigBuilder.new("rails") do |c|
          job_config = Jenkins::JobConfigBuilder.new do |c|
            c.scm           = data[:repository_name]
            c.assigned_node = app_name
            c.envfile       = "/data/#{app_name}/shared/config/git-env"
            c.steps         = [
              [:build_shell_step, "bundle install"],
              [:build_ruby_step, <<-RUBY.gsub(/^            /, '')],
                appcloud_database = "/data/#{app_name}/shared/config/database.yml"
                FileUtils.cp appcloud_database, "config/database.yml"
                RUBY
              [:build_shell_step, "bundle exec rake db:schema:load RAILS_ENV=#{framework_env} RACK_ENV=#{framework_env}"],
              [:build_shell_step, "bundle exec rake RAILS_ENV=#{framework_env} RACK_ENV=#{framework_env}"]
            ]
          end
        
          Jenkins::Api.create_job(app_name, job_config)
          Jenkins::Api.build_job(app_name)
        end
      rescue Errno::ECONNREFUSED, Errno::EAFNOSUPPORT
        raise Exception, "No connection available to the Jenkins server (#{Jenkins::Api.base_uri})."
      end
    end
    action :create
  end

end
