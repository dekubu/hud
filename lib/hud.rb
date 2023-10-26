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
  module ENV ;end
  
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

      def display(name, locals = {})
        paths_to_check = [
          "#{Rack::App::Utils.pwd}/components/#{self.class.included_modules.find { |mod| mod == Hud::ENV}.name.split("::").first}/#{name}.html.erb",
          "#{Rack::App::Utils.pwd}/components/#{name}.html.erb"
        ]

        partial_path = paths_to_check.find { |path| File.exist?(path) }

        if partial_path
          partial_template = Tilt::ERBTemplate.new(partial_path)
          partial_template.render(self, locals)
        else
          raise "Partial #{name} not found in either location"
        end
      end

      def to_s
        template = if self.class.to_s.downcase.include? "::"
          Tilt::ERBTemplate.new("#{Rack::App::Utils.pwd}/components/#{self.class.to_s.downcase.gsub("::", "_")}.html.erb")
        else
          Tilt::ERBTemplate.new("#{Rack::App::Utils.pwd}/components/#{self.class.to_s.downcase}.html.erb")
        end
        template.render(self, locals: @locals, partial: method(:display))
      rescue Errno::ENOENT => e
        "Create a view for #{self.class}"
      end

      private

      def initialize(locals: {})
        helper_module = self.class.included_modules.find { |mod| mod == Hud::Display::Helpers }
        if helper_module
          folder_name = helper_module.name.split("::").first
          `mkdir -p components/#{folder_name}`
        end
        `mkdir -p components/`
        @locals = OpenStruct.new(locals)
      end
    end
  end
end
