module Bcome::Exception
  class MissingArgumentForRegistryCommand < ::Bcome::Exception::Base
    def message_prefix
      'Cannot find argument for registry command in either your defaults or your supplied arguments'
    end
  end
end
