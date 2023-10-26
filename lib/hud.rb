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
    def self.included(base)
      folder_name = base.name.split("::").first.downcase
      `mkdir -p components/#{folder_name}`
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
      include Env

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
        helper_module = self.class.included_modules.find { |mod| mod == Hud::Env }
        folder_name = helper_module ? helper_module.name.split("::").first.downcase : ''
        
        paths_to_check = [
          "#{Rack::App::Utils.pwd}/components/#{folder_name}/#{name}.html.erb",
          "#{Rack::App::Utils.pwd}/components/#{name}.html.erb"
        ]

        partial_path = paths_to_check.find { |path| 
          puts "looking in #{path} for #{name}"
          File.exist?(path)
        }

        if partial_path
          partial_template = Tilt::ERBTemplate.new(partial_path)
          partial_template.render(self, locals)
        else
          raise "Partial #{name} not found in either location"
        end
      end

      def to_s
        helper_module = self.class.included_modules.find { |mod| mod == Hud::Env }
        folder_name = helper_module ? helper_module.name.split("::").first.downcase : ''
        
        paths_to_check = [
          "#{Rack::App::Utils.pwd}/components/#{folder_name}/#{self.class.to_s.downcase.gsub('::', '_')}.html.erb",
          "#{Rack::App::Utils.pwd}/components/#{self.class.to_s.downcase.gsub('::', '_')}.html.erb"
        ]
        
        template_path = paths_to_check.find { |path| 
          puts "looking in #{path}"
          File.exist?(path) 
        }

        if template_path
          template = Tilt::ERBTemplate.new(template_path)
          template.render(self, locals: @locals, partial: method(:display))
        else
          raise "View for #{self.class} not found in either location"
        end
      end

      private

      def initialize(locals: {})
        @locals = OpenStruct.new(locals)
      end
    end
  end
end
