require 'irb'
require 'irb/completion'
class Hud::CLI::DefaultCommands::Init < Hud::CLI::Command

  description 'Initialize a new hud application'

  action do |*args|
    ARGV.clear
    ARGV.push(*args)

    gem_root = Gem::Specification.find_by_name('hud').gem_dir
    file_path = File.join(gem_root, 'lib/hud/templates', 'base.zip')
    `unzip #{file_path} -d .`

    STDOUT.puts("Initialize application")
  end

end