require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'engineyard-jenkins/appcloud_env'

describe Engineyard::Jenkins::AppcloudEnv do
  def appcloud_env
    @appcloud_env ||= Engineyard::Jenkins::AppcloudEnv.new
  end
  
  def find_environments(options = {})
    appcloud_env.find_environments(options)
  end
  
  before do
    @tmp_root   = File.dirname(__FILE__) + "/../tmp"
    @home_path  = File.expand_path(File.join(@tmp_root, "home"))
    FileUtils.mkdir_p(@home_path)
    ENV['EYRC'] = File.join(@home_path, ".eyrc")
    appcloud_env.stub(:clean_host_name)
  end
  describe ".find_environments - no args" do
    it "return [nil, nil] unless it has reason to return something else" do
      appcloud_env.stub(:fetch_environment).and_raise(EY::NoEnvironmentError)
      find_environments.should == []
    end
    it "returns [env_name, account_name] if finds one env 'jenkins' in any account" do
      appcloud_env.should_receive(:fetch_environment).with("jenkins", nil).and_return(env = EY::Model::App.new(123, EY::Model::Account.new(789, 'mine')))
      appcloud_env.should_receive(:fetch_environment).with("jenkins_server", nil).and_raise(EY::NoEnvironmentError)
      appcloud_env.should_receive(:fetch_environment).with("jenkins_production", nil).and_raise(EY::NoEnvironmentError)
      appcloud_env.should_receive(:fetch_environment).with("jenkins_server_production", nil).and_raise(EY::NoEnvironmentError)
      find_environments.should == [['jenkins', 'mine', env]]
    end
    it "returns many result pairs" do
      appcloud_env.should_receive(:fetch_environment).with("jenkins", nil).and_return(env = EY::Model::App.new(123, EY::Model::Account.new(789, 'mine')))
      appcloud_env.should_receive(:fetch_environment).with("jenkins_server", nil).and_raise(EY::NoEnvironmentError)
      appcloud_env.should_receive(:fetch_environment).with("jenkins_server_production", nil).and_raise(EY::NoEnvironmentError)
      appcloud_env.should_receive(:fetch_environment).with("jenkins_production", nil) {
        raise EY::MultipleMatchesError, <<-ERROR.gsub(/^\s+/, '')
           jenkins_production # ey <command> --environment='jenkins_production' --account='mine'
           jenkins_production # ey <command> --environment='jenkins_production' --account='yours'
        ERROR
      }
      find_environments.should == [['jenkins', 'mine', env], ['jenkins_production', 'mine', nil], ['jenkins_production', 'yours', nil]]
    end
  end

  describe ".find_environments - specific account" do
    it "return [nil, nil] unless it has reason to return something else" do
      appcloud_env.stub(:fetch_environment).and_raise(EY::NoEnvironmentError)
      find_environments(:account => "mine").should == []
    end
    it "returns [env_name, account_name] if finds one env 'jenkins' in specific account" do
      appcloud_env.should_receive(:fetch_environment).with("jenkins", "mine").and_return(env = EY::Model::App.new(123, EY::Model::Account.new(789, 'mine')))
      appcloud_env.should_receive(:fetch_environment).with("jenkins_server", "mine").and_raise(EY::NoEnvironmentError)
      appcloud_env.should_receive(:fetch_environment).with("jenkins_production", "mine").and_raise(EY::NoEnvironmentError)
      appcloud_env.should_receive(:fetch_environment).with("jenkins_server_production", "mine").and_raise(EY::NoEnvironmentError)
      find_environments(:account => "mine").should == [['jenkins', 'mine', env]]
    end
  end

  describe ".find_environments - specific environment" do
    it "return [nil, nil] unless it has reason to return something else" do
      appcloud_env.stub(:fetch_environment).and_raise(EY::NoEnvironmentError)
      find_environments(:environment => "jenkins").should == []
    end
    it "returns [env_name, account_name] if finds one env 'jenkins' in any account" do
      appcloud_env.should_receive(:fetch_environment).with("jenkins", nil).and_return(env = EY::Model::App.new(123, EY::Model::Account.new(789, 'mine')))
      find_environments(:environment => "jenkins").should == [['jenkins', 'mine', env]]
    end
    it "returns [env_name, account_name] if finds one env 'jenkins' in specific account" do
      appcloud_env.should_receive(:fetch_environment).with("jenkins", "mine").and_return(env = EY::Model::App.new(123, EY::Model::Account.new(789, 'mine')))
      find_environments(:environment => "jenkins", :account => "mine").should == [['jenkins', 'mine', env]]
    end
  end
end
