require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'engineyard-hudson/appcloud_env'

describe Engineyard::Hudson::AppcloudEnv do
  def appcloud_env
    @appcloud_env ||= Engineyard::Hudson::AppcloudEnv.new
  end
  
  def find_environments(options = {})
    appcloud_env.find_environments(options)
  end
  
  before do
    @tmp_root   = File.dirname(__FILE__) + "/../tmp"
    @home_path  = File.expand_path(File.join(@tmp_root, "home"))
    FileUtils.mkdir_p(@home_path)
    ENV['EYRC'] = File.join(@home_path, ".eyrc")
  end
  describe ".select_environment_account" do
    it "return [nil, nil] unless it has reason to return something else" do
      appcloud_env.stub(:fetch_environment).and_raise(EY::NoEnvironmentError)
      find_environments.should == []
    end
    it "returns [env_name, account_name] if finds one env 'hudson' in any account" do
      appcloud_env.should_receive(:fetch_environment_or_nil).with("hudson", nil).and_return(EY::Model::App.new(123, EY::Model::Account.new(789, 'mine')))
      appcloud_env.should_receive(:fetch_environment_or_nil).with("hudson_server", nil).and_return(nil)
      appcloud_env.should_receive(:fetch_environment_or_nil).with("hudson_production", nil).and_return(nil)
      appcloud_env.should_receive(:fetch_environment_or_nil).with("hudson_server_production", nil).and_return(nil)
      find_environments.should == [['hudson', 'mine']]
    end
      
  end
end
