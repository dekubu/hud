class Hud::CLI::Runner
  CommandNotFound = Class.new(StandardError)

  def initialize
    @cli = Hud::CLI.new
  end

  def start(argv)
    command_name = argv.shift
    start_command_for(command_name, argv)
  end

  protected

  def show_commands
    $stdout.puts(Hud::CLI::DefaultCommands::ListCommands.get_message(commands))
  end

  def show_help_message(argv)
    command_name = argv.shift
    command = command_for(command_name)
    options_parser = configure_command(command, command_name)
    $stdout.puts(options_parser.help)
  end

  def start_command_for(command_name, argv)
    case command_name.to_s

    when "help"
      show_help_message(argv)

    when "routes"
      command = Hud::CLI::DefaultCommands::ShowRoutes.new
      run_command(argv, command, "routes")

    when "irb"
      Hud::CLI::DefaultCommands::IRB.new.start(argv)

    when "init"
      Hud::CLI::DefaultCommands::Init.new.start(argv)

    when "mount"
      Hud::CLI::DefaultCommands::Mount.new.start(argv)

    else
      command = command_for(command_name)
      run_command(argv, command, command_name)

    end
  rescue CommandNotFound
    show_commands
  end

  def run_command(argv, command, command_name)
    return if command.nil?

    option_parser = configure_command(command, command_name)
    option_parser.parse!(argv)
    command.start(argv)
  end

  def configure_command(command, command_name)
    option_parser = OptionParser.new
    Hud::CLI::Command::Configurator.configure(command, command_name, option_parser)
    option_parser
  end

  def command_for(name)
    commands[(name || raise(CommandNotFound)).to_s.to_sym] || raise(CommandNotFound)
  end

  def commands
    @cli.commands
  end
end
