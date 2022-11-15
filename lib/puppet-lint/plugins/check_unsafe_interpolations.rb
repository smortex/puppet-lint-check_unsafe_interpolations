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
        # We are only interested in tokens from command onwards
        next unless token.type == :NAME
        # Don't check the command if it is parameterised
        next if parameterised?(token)

        check_command(token).each do |t|
          notify_warning(t)
        end
      end
    end
  end

  # Raises a warning given a token and message
  def notify_warning(token)
    notify :warning,
            message: "unsafe interpolation of variable '#{token.value}' in exec command",
            line: token.line,
            column: token.column
  end

  # Iterates over the tokens in a command and adds it to an array of violations if it is an input variable
  def check_command(token)
    # Initialise variables needed in while loop
    rule_violations = []
    current_token = token

    # Iterate through tokens in command
    while current_token.type != :NEWLINE
      # Check if token is a varibale and if it is parameterised
      if current_token.type == :VARIABLE
        rule_violations.append(current_token)
      end
      current_token = current_token.next_token
    end

    rule_violations
  end

  # A command is parameterised if its args are placed in an array
  # This function checks if the current token is a :FARROW and if so, if it is followed by an LBRACK
  def parameterised?(token)
    current_token = token
    while current_token.type != :NEWLINE
      return true if current_token.type == :FARROW && current_token.next_token.next_token.type == :LBRACK
      current_token = current_token.next_token
    end
  end
end
