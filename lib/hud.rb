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
        klz = Display.build(name)
        klz.call(locals: locals)
      end
    end
  
    def self.build(name)
      symbol = name.to_sym
      class_name = symbol.to_s.capitalize
      Object.const_set(class_name, Class.new(Component)) unless Object.const_defined?(class_name)
      Object.const_get(class_name)
    end
  
    class Component
      attr_reader :locals
      attr_reader :content
      alias args locals
  
      def folder_name
        Env.folder_name_for(self.class)
      end
  
      def development?
        ENV["RACK_ENV"] == "development"
      end
  
      def production?
        ENV["RACK_ENV"] == "production"
      end
  
      def staging?
        ENV["RACK_ENV"] == "staging"
      end
  
      def self.call(locals: {})
        new(locals: locals)
      end
  
      def render_template(name: nil, locals: {})
        name ||= self.class.to_s.downcase.gsub("::", "_")
        paths_to_check = [
          "#{Rack::App::Utils.pwd}/#{folder_name}/components/#{name}.html.erb",
          "#{Rack::App::Utils.pwd}/components/#{name}.html.erb"
        ]
  
        template_path = paths_to_check.find { |path| File.exist?(path) }
  
        if template_path
          template = Tilt::ERBTemplate.new(template_path)
          template.render(self, locals)
        else
          raise "Template #{name} not found in either location"
        end
      end
  
      def display(name, locals = {})
        @content = render_template(name: name, locals: locals)
      end
      def to_s
        @content.nil? ? "Oppps!" : @content
      end
  
      private
  
      def initialize(locals: {})
        @locals = OpenStruct.new(locals)
      end
    end
  end
  
end
