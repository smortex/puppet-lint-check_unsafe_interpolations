PuppetLint.new_check(:check_unsafe_interpolations) do
  COMMANDS = Set['command', 'onlyif', 'unless']
  def check
    exec = false

    # Look for exec blocks
    tokens.select { |token| check_exec?(token) }.each do |token|
      exec = true
    end

    # Look for commands in exec blocks
    tokens.select { |token| exec && check_command?(token) }.each do |token|
      
      # Loop over exec command to find command statement
      while token.type != :NEWLINE

        # Check if command contains an input variable
        if token.type == :VARIABLE

          # Raise warning since input variable is unsanitised
          warning_message = "unsafe interpolation of variable '#{token.value}' in exec command"
          notify_warning(token, warning_message)
          break
        end

        token = token.next_token
      end
    end
  end

  def check_exec?(token)
    return true if token.value == 'exec'
    return false
  end

  def check_command?(token)
    return true if COMMANDS.include?(token.value)
    return false
  end

  def notify_warning(token, message)
    notify :warning, message: message,
                     line: token.line,
                     column: token.column
  end
end
