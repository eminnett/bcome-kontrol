module ::Bcome::Ssh
  class Command
    attr_reader :raw, :stdout, :stderr, :exit_code, :node, :bootstrap

    def initialize(params)
      @raw = params[:raw]
      @node = params[:node]
      @exit_code = nil
      @exit_signal = nil
      @stdin = ''; @stdout = ''; @stderr = ''
    end

    def unset_node
      @node = nil
    end

    def pretty_result
      is_success? ? 'success'.success : 'failure'.error
    end

    attr_writer :bootstrap

    def output
      command_output = is_success? ? @stdout : "Exit code: #{@exit_code}\n\nSTDERR: #{@stderr}"
      "\n#{command_output}"
    end

    def is_success?
      exit_code.to_i == 0
    end

    def success_codes
      ['0']
    end

    attr_writer :stdout

    attr_writer :stderr

    attr_writer :exit_code

    def exit_signal(data)
      @exit_signal = data
    end
  end
end
