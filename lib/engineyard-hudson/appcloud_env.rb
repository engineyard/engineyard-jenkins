module Engineyard
  module Hudson
    module AppcloudEnv
      extend self
      
      # Returns [environment, account] based on current .eyrc credentials and/or CLI options
      # Returns [nil, nil] if no unique environment can be selected
      def select_environment_account(options = {})
        [nil, nil]
      end
    end
  end
end