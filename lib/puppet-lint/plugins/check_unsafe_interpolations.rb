PuppetLint.new_check(:check_unsafe_interpolations) do
  COMMANDS = Array['command', 'onlyif', 'unless']
  def check
    # Gather any exec commands' resources into an array
    exec_resources = resource_indexes.map do |resource|
      resource_parameters = resource[:param_tokens].map(&:value)
      resource if resource[:type].value == 'exec' && !(COMMANDS & resource_parameters).empty?
    end

    # Iterate over each command found in any exec
    exec_resources.each do |command_resources|
      # Iterate over each command in execs and check for unsafe interpolations
      command_resources[:tokens].each do |token|
        # Check if any tokens in command are a varibale
        if token.type == :VARIABLE
          warning_message = "unsafe interpolation of variable '#{token.value}' in exec command"
          notify_warning(token, warning_message)
        end
      end
    end
  end

  # Raises a warning given a token and message
  def notify_warning(token, message)
    notify :warning,
            message: message,
            line: token.line,
            column: token.column
  end
end
