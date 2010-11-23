module Engineyard
  module Hudson
    class AppcloudEnv
      # Returns [environment, account] based on current .eyrc credentials and/or CLI options
      # Returns [nil, nil] if no unique environment can be selected
      def self.select_environment_account(options = {})
        ["hudson", "drnic"]
      end
    end
  end
end