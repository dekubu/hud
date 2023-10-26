require "irb"
require "fileutils"
require "irb/completion"

class Hud::CLI::DefaultCommands::Mount < Hud::CLI::Command
  description "Mount a new hud application"

  action do |*args|
    ARGV.clear
    ARGV.push(*args)

    name = ARGV[0]
    gem_root = Gem::Specification.find_by_name("hud").gem_dir
    file_path = File.join(gem_root, "lib/hud/templates", "mount.zip")
    `unzip #{file_path} -d .`
    `rm -rf __MACOSX`
    `mv mount/ #{name}`

    Dir.chdir("./#{name}") do
      rename_filename("base.rb", "#{name}.rb")
      replace_in_file("#{name}.rb", "Base", name.capitalize)

      replace_in_file("./index.html.erb", "Base", name.capitalize)
      replace_in_file("./index.html.erb", "base", name)

      replace_in_file("./layout.html.erb", "Base", name.capitalize)
      replace_in_file("./layout.html.erb", "base", name)

      `mv #{name}.rb ../`
      STDOUT.puts(`tree ../`)
      STDOUT.puts("Mounted #{name} - ok!")
    end
  end

  def replace_in_file(file_path, search_pattern, replacement)
    # Read the file's contents
    file_contents = File.read(file_path)

    # Perform a global substitution on the contents
    modified_contents = file_contents.gsub(search_pattern, replacement)

    # Write the modified contents back to the same file
    File.open(file_path, "w") { |file| file.puts modified_contents }
  end

  def rename_filename(from, to)
    `mv #{from} #{to}`
  end
end
