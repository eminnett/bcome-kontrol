module Bcome::Interactive
  class Session

    class << self
      def run(node)
        session_end_message = "\ninteractive session ended".bc_green
        begin
          session = ::Bcome::Interactive::Session.new(node)
          system("clear")
          session.prompt
        rescue ::Bcome::Exception::InteractiveSessionHalt => e
          puts session_end_message
        rescue  ::Bcome::Exception::CouldNotInitiateSshConnection => e
          puts e.message.bc_red
        end
      end
    end

    attr_reader :responses, :node

    def initialize(node)
      @node = node
      @responses = {}
    end

    def prompt
      item = ::Bcome::Interactive::SessionItem::TransparentSsh.new(self)  
      print item.start_message
      process_item(item)
    end

    def process_item(item)
      item.do
    end

  end
end
