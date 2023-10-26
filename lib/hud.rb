require "hud/version"
require_relative "hud/db/entity"

require "rack/app"
require "yaml"
require "tilt"
require "ostruct"
require "tilt/erb"
require "rack/app/front_end"
require "hud/cli"

module Hud
  class Error < StandardError; end

  module Env
    FOLDER_NAMES = {}

    def self.included(base)
      folder_name = base.name.split("::").first.downcase
      FOLDER_NAMES[base] = folder_name
      `mkdir -p components/#{folder_name}`
    end

    def self.folder_name_for(base)
      FOLDER_NAMES[base]
    end
  end

  class Display
    module Helpers
      def display(name, locals: {})
        klz = Hud::Display.build(name)
        klz.call(locals: locals)
      end
    end

    def self.build(name)
      symbol = name.to_sym
      class_name = symbol.to_s.capitalize

      if Object.const_defined?(class_name)
        Object.const_get(class_name)
      else
        new_class = Class.new(Hud::Display::Component)
        Object.const_set(class_name, new_class)
      end
    end

    class Component
      def folder_name
        Env.folder_name_for(self.class)
      end

      def development?
        ENV["RACK_ENV"] == "development"
      end

      def production?
        ENV["RACK_ENV"] == "production"
      end

      attr_reader :locals

      def self.call(locals: {})
        new(locals: locals)
      end

      def render_template(name: nil, locals: {})
  name = self.class.to_s.downcase.gsub('::', '_') unless name
  paths_to_check = [
    "#{Rack::App::Utils.pwd}/components/#{folder_name}/#{name}.html.erb",
    "#{Rack::App::Utils.pwd}/components/#{name}.html.erb"
  ]

  template_path = paths_to_check.find { |path|
    puts "looking in #{path} for #{name}"
    File.exist?(path)
  }

  if template_path
    template = Tilt::ERBTemplate.new(template_path)
    template.render(self, locals)
  else
    raise "Template #{name} not found in either location"
  end
end

def display(name, locals = {})
  render_template(name: name, locals: locals)
end

def to_s
  render_template(locals: @locals)
end


      private

      def initialize(locals: {})
        @locals = OpenStruct.new(locals)
      end
    end
  end
end
