require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'engineyard-hudson/appcloud_env'

describe Engineyard::Hudson::AppcloudEnv do
  include Engineyard::Hudson::AppcloudEnv
  describe ".select_environment_account" do
    it "should return [nil, nil] unless it has reason to return something else" do
      select_environment_account.should == [nil, nil]
    end
  end
end