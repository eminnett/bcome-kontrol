module Bcome::System
  class Local

    include Singleton

      def execute_command(raw_command)
        local_command = command(raw_command)
        if local_command.failed? && !in_console_session?
          # we fail fast if we're not in a console session
          raise ::Bcome::Exception::FailedToRunLocalCommand.new("#{raw_command}. Error: " + local_command.output.red)
        end
        local_command
      end

      def in_console_session?
        !::Bcome::Workspace.instance.console_set?
      end

      def local_user
        result = command("whoami")
        result.output =~ /(.+)\n/
        $1
      end

      def command(raw_command)
        ::Bcome::Command::Local.run(raw_command)
      end


    end
end