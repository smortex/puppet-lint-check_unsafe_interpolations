PuppetLint.new_check(:check_unsafe_interpolations) do
  COMMANDS = Array['command', 'onlyif', 'unless']
  INTERPOLATED_STRINGS = Array[:DQPRE, :DQMID]
  def check
    # Gather any exec commands' resources into an array
    exec_resources = resource_indexes.map { |resource|
      resource_parameters = resource[:param_tokens].map(&:value)
      resource if resource[:type].value == 'exec' && !(COMMANDS & resource_parameters).empty?
    }.compact

    # Filter the list of titles returned by get_title_tokens for those contained in an exec
    exec_title_tokens = get_title_tokens.select { |title|
      title if title[:resource_type].value == 'exec'
    }.compact

    # Iterate over title tokens and raise a warning if any are variables
    unless exec_title_tokens.empty?
      exec_title_tokens.each do |title|
        check_unsafe_title(title)
      end
    end

    # Iterate over each command found in any exec
    exec_resources.each do |command_resources|
      check_unsafe_interpolations(command_resources)
    end
  end

  # Iterate over the tokens in a title and raise a warning if an interpolated variable is found
  def check_unsafe_title(title)
    title[:tokens].each do |token|
      notify_warning(token.next_code_token) if interpolated?(token)
    end
  end

  # Iterates over an exec resource and if a command, onlyif or unless paramter is found, it is checked for unsafe interpolations
  def check_unsafe_interpolations(command_resources)
    command_resources[:tokens].each do |token|
      # Skip iteration if token isn't a command of type :NAME
      next unless COMMANDS.include?(token.value) && token.type == :NAME
      # Don't check the command if it is parameterised
      next if parameterised?(token)

      check_command(token).each do |t|
        notify_warning(t)
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
      rule_violations.append(current_token.next_code_token) if interpolated?(current_token)
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

  # This function is a replacement for puppet_lint's title_tokens function which assumes titles have single quotes
  # This function adds a check for titles in double quotes where there could be interpolated variables
  def get_title_tokens
    result = []
    tokens.each_index do |token_idx|
      next unless tokens[token_idx].type == :COLON
      tokens_array = []
      # Check if title is an array
      if tokens[token_idx - 1].type == :RBRACK
        array_start_idx = tokens.rindex do |r|
          r.type == :LBRACK
        end
        title_array_tokens = tokens[(array_start_idx + 1)..(token_idx - 2)]
        tokens_array.concat(title_array_tokens.select do |token|
          { STRING: true, NAME: true }.include?(token.type)
        end)
        result << {
          tokens: tokens_array,
          resource_type: tokens[array_start_idx].prev_code_token.prev_code_token
        }
      # Check if title is double quotes string
      elsif tokens[token_idx - 1].type == :DQPOST
        # Find index of the start of the title
        title_start_idx = tokens.rindex do |r|
          r.type == :DQPRE
        end
        result << {
          # Title is tokens from :DQPRE to the index before :COLON
          tokens: tokens[title_start_idx..(token_idx - 1)],
          resource_type: tokens[title_start_idx].prev_code_token.prev_code_token
        }
      # Title is in single quotes
      else
        next_token = tokens[token_idx].next_code_token
        tokens_array.concat([tokens[token_idx - 1]]) unless next_token.type == :LBRACE
        result << {
          tokens: tokens_array,
          resource_type: tokens[token_idx - 1].prev_code_token.prev_code_token
        }
      end
    end
    result
  end

  def interpolated?(token)
    INTERPOLATED_STRINGS.include?(token.type)
  end
end
