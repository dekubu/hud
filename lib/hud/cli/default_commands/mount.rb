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
    `mv base/ #{name}`

    find_replace_in_directory("./#{name}", "base", name)

    Dir.chdir("./#{name}") do
      rename_filename("base.rb", "#{name}.rb")
      replace_in_file("#{name}.rb", "Base", name.capitalize)
      replace_in_file("./#{name}/index.html.erb", "Base", name.capitalize)
      replace_in_file("./#{name}/index.html.erb", "base", name)

      replace_in_file("./#{name}/layout.html.erb", "Base", name.capitalize)
      replace_in_file("./#{name}/layout.html.erb", "base", name)

      STDOUT.puts(`tree .`)
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

  def find_replace_in_directory(directory, criteria, replacement)
    # Recursively list all files and directories in the given directory
    Dir.glob(File.join(directory, "**", "*")).each do |entry_path|
      if File.file?(entry_path)
        # For files, open the file for reading and writing
        content = File.read(entry_path)

        # Create a regular expression to match the criteria as a whole word
        regex = /\b#{Regexp.escape(criteria)}\b/i

        # Check if the criteria appears in the content, case-insensitively
        if content.match?(regex)
          # Perform replacements based on the criteria while preserving case
          modified_content = content.gsub(regex) do |match|
            (match == criteria) ? replacement : match
          end

          # Write the modified content back to the file
          File.open(entry_path, "w") { |file| file.puts modified_content }
        end

        # Check if the file name matches the criteria
        if File.basename(entry_path).casecmp(criteria).zero?
          new_file_name = File.join(File.dirname(entry_path), replacement)
          File.rename(entry_path, new_file_name)
        end
      elsif File.directory?(entry_path)
        # For directories, check if the directory name matches the criteria
        if File.basename(entry_path).casecmp(criteria).zero?
          new_directory_name = File.join(File.dirname(entry_path), replacement)
          File.rename(entry_path, new_directory_name)
        end
      end
    end
  end

  def rename_filename(from, to)
    `mv #{from} #{to}`
  end
end
