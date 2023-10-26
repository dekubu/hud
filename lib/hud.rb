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
  def self.configuration
    @configuration ||= OpenStruct.new
  end
  
  def self.configure
    configuration.components_dir = "base"
    yield(configuration)
  end
  class Display
    module Helpers
      def display(name, locals: {})
        klz = Display.build(name)
        klz.call(locals: locals).render_template(name: name, locals: @locals)
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
      alias_method :args, :locals

      def folder_name
        Hud.configuration.components_dir
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

        base_path = Pathname.new(Rack::App::Utils.pwd)

        root_component_path = base_path.join("components", "#{name}.html.erb")
        folder_component_path = base_path.join(folder_name, "components", "#{name}.html.erb")

        paths_to_check = [folder_component_path, root_component_path.to_s]

        template_path = paths_to_check.find { |path|
          File.exist?(path)
        }

        if template_path
          template = Tilt::ERBTemplate.new(template_path)
          template.render(self, locals)
        else
          raise "Template #{name} not found in either location"
        end
      end

      private

      def initialize(locals: {})
        @locals = OpenStruct.new(locals)
      end
    end
  end
end
