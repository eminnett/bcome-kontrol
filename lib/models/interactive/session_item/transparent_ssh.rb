module Bcome::Interactive::SessionItem
  class TransparentSsh < ::Bcome::Interactive::SessionItem::Base
    END_SESSION_KEY = '\\q'.freeze
    HELP_KEY = '\\?'.freeze
    LIST_KEY = '\\l'.freeze

    DANGER_CMD = "rm\s+-r|rm\s+-f|rm\s+-fr|rm\s+-rf|rm".freeze

    def resources
      node.machines
    end

    def do
      show_menu
      puts ''
      open_ssh_connections!
      puts ''
      list_machines
      action
    end

    def action
      input = get_input
      return if exit?(input)
      if show_menu?(input)
        show_menu
      elsif list_machines?(input)
        list_machines
      elsif command_may_be_unwise?(input)
        handle_the_unwise(input)
      else
        execute_on_machines(input)
      end
      action
    end

    def show_menu
      system('clear'); print start_message
    end

    def handle_the_unwise(input)
      if prompt_for_confirmation('Command may be dangerous to run on all machines. Are you sure you want to proceed? [Y|N] > '.bc_red)
        execute_on_machines(input)
      end
    end

    def command_may_be_unwise?(input)
      input =~ /#{DANGER_CMD}/
    end

    def prompt_for_confirmation(message)
      answer = get_input(message)
      prompt_for_confirmation(message) unless %w[Y N].include?(answer)
      answer == 'Y' ? true : false
    end

    def start_message
      warning = "\n\sCommands entered here will be executed on ".bc_red + 'EVERY'.underline.bc_red + ' machine in your selection.'.bc_red
      second_warning = "\n\n\s" + 'Use with CAUTION.'.bc_red.underline
      info = "\n\n\s\\l list machines\n\s\\q to quit\n\s\\? this message".bc_yellow
      "#{warning}#{second_warning}#{info}\n"
    end

    def terminal_prompt
      ">\s".bold.bc_cyan.blinking
    end

    def exit?(input)
      input == END_SESSION_KEY
    end

    def show_menu?(input)
      input == HELP_KEY
    end

    def list_machines?(input)
      input == LIST_KEY
    end

    def open_ssh_connections!
      in_progress = true
      Bcome::ProgressBar.instance.indicate(progress_bar_config, in_progress)
      Bcome::ProgressBar.instance.reset!
      resources.pmap do |machine|
        begin
          machine.ssh_driver.ssh_connect!
        rescue
          puts 'Failed to connect to instance - please verify your connection settings and check that your instance is running.'
          machine.print_ping_result(false)
          raise Bcome::Exception::CouldNotInitiateSshConnection, machine.namespace
          break
        end
        Bcome::ProgressBar.instance.indicate_and_increment!(progress_bar_config, in_progress)
      end
      in_progress = false
      Bcome::ProgressBar.instance.indicate(progress_bar_config, in_progress)
      Bcome::ProgressBar.instance.reset!
    end

    def progress_bar_config
      {
        prefix: "\sOpening SSH connections\s",
        indice: '...',
        indice_descriptor: "of #{resources.size}"
      }
    end

    def list_machines
      puts "\n"
      resources.each do |machine|
        puts "\s- #{machine.namespace}".bc_cyan
      end
    end

    def get_input(message = terminal_prompt)
      ::Readline.readline("\n#{message}", true).squeeze('').to_s
    end

    def execute_on_machines(user_input)
      resources.pmap do |machine|
        machine.run(user_input)
      end
    end
  end
end