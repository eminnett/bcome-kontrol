module ::Bcome::Exception
  class MissingSubselectionKey < ::Bcome::Exception::Base
    def message_prefix
      'You must set a subselection key when defining a subselection inventory'
    end
  end
end
