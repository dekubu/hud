require 'irb'
require 'irb/completion'
class Hud::CLI::DefaultCommands::Init < Hud::CLI::Command

  description 'Initialize a new hud application'

  action do |*args|
    ARGV.clear
    ARGV.push(*args)

    `unzip ../../templates/base.zip -d .`

    STDOUT.puts("Initialize application")
  end

end