require 'irb'
require 'fileutils'
require 'irb/completion'
class Hud::CLI::DefaultCommands::Init < Hud::CLI::Command

  description 'Initialize a new hud application'

  action do |*args|
    ARGV.clear
    ARGV.push(*args)

    gem_root = Gem::Specification.find_by_name('hud').gem_dir
    file_path = File.join(gem_root, 'lib/hud/templates', 'base.zip')
    `unzip #{file_path} -d .`
    find_replace_in_directory("./base", 'base', ARGV[0])

    STDOUT.puts("Initialized #{ARGV[0]} - ok!")
  end

  require 'fileutils'

def find_replace_in_directory(directory, criteria, replacement)
  # Recursively list all files and directories in the given directory
  Dir.glob(File.join(directory, '**', '*')).each do |entry_path|
    if File.file?(entry_path)
      # For files, open the file for reading and writing
      content = File.read(entry_path)

      # Check if the criteria appears in the content, case-insensitively
      if content.downcase.include?(criteria.downcase)
        # Perform replacements based on the criteria while preserving case
        modified_content = content.gsub(/#{criteria}/i) do |match|
          match == criteria ? replacement : match
        end

        # Write the modified content back to the file
        File.open(entry_path, 'w') { |file| file.puts modified_content }
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

# Example usage:
# find_replace_in_directory('/path/to/your/directory', 'criteria', 'replacement')


end