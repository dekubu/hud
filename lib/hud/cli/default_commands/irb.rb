require "irb"
require "irb/completion"
class Hud::CLI::DefaultCommands::IRB < Hud::CLI::Command
  description "open an irb session with the application loaded in"

  action do |*args|
    ARGV.clear
    ARGV.push(*args)
    ::IRB.start
  end
end
