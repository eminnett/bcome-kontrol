module ::Bcome::Exception
  class InvalidMatcherQuery < ::Bcome::Exception::Base
    def message_prefix
      'Invalid matcher query'
    end
  end
end
