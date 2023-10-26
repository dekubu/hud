require "optparse"
class Hud::CLI
  require "hud/cli/command"
  require "hud/cli/default_commands"
  require "hud/cli/runner"

  class << self
    def start(argv)
      runner.start(argv)
    end

    def runner
      Hud::CLI::Runner.new
    end
  end

  def merge!(cli)
    commands.merge!(cli.commands)
    self
  end

  def commands
    @commands ||= {}
  end

  protected

  def command(name, &block)
    command_prototype = Class.new(Hud::CLI::Command)
    command_prototype.class_exec(&block)
    commands[name.to_s.to_sym] = command_prototype.new
  end
end
