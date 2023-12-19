
# frozen_string_literal: true

require_relative "lib/hud/version"

Gem::Specification.new do |spec|
  spec.name = 'hud'
  spec.version = Hud::VERSION
  spec.authors = ['Delaney Kuldvee Burke']
  spec.email = ['delaney@vidtreon.com']

  spec.summary = 'Minimalist web framework using HTMX and Rack-app'
  spec.homepage = 'https://github.com/dekubu/hud/'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/dekubu/hud'
    spec.metadata['changelog_uri'] = 'https://github.com/dekubu/hud/blob/main/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  
  spec.require_paths = ["lib"]


  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'browser'
  spec.add_dependency 'linguistics'
  spec.add_dependency 'msgpack'
  spec.add_dependency 'rack-app'
  spec.add_dependency 'rack-app-front_end'
  spec.add_dependency 'sdbm'
end
