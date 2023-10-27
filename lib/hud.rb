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
    configuration.components_dirs = []
    yield(configuration)
  end

  class Display
    module Helpers
      def display(name, from: nil, locals: {})
        klz = Display.build(name)
        klz.call(locals: locals).render_template(name: name, locals: @locals, from: from)
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

      def folders
        Hud.configuration.components_dirs
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

      def render_template(name: nil, from: nil, locals: {})
        name ||= self.class.to_s.downcase.gsub("::", "_")

        base_path = Pathname.new(Rack::App::Utils.pwd)

        paths_to_check = []

        folders.each do |folder_name|
          paths_to_check << base_path.join(folder_name, "components", "#{name}.html.erb")
        end

        root_component_path = base_path.join("components", "#{name}.html.erb")
        paths_to_check << root_component_path

        paths_to_check.each do |path|
          if File.exist?(path)
            template = Tilt::ERBTemplate.new(path)

            if from.nil?
              return template.render(self, locals)
            else
              from_path = base_path.join(from, "components")
              return template.render(self, locals) if path.to_path.start_with? from_path.to_s
            end

          end
        end

        raise "cant find #{name} in #{paths_to_check.join(",")}"
      end

      private

      def initialize(locals: {})
        @locals = OpenStruct.new(locals)
      end
    end
  end
end
