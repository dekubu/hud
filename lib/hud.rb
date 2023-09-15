require "hud/version"
require_relative "./hud/db/entity.rb"

require 'rack/app'
require 'tilt'
require 'ostruct'
require 'tilt/erb'
require 'rack/app/front_end'
require 'hud/cli'

module Hud
  
  class Error < StandardError; end

  class Display
    
    module Helpers 
      def display(name,locals: {})
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

      attr_reader :locals
      
      def self.call(locals:{})
        new(locals: locals)
      end

      def display(name, locals = {})
        partial_path = "#{Rack::App::Utils.pwd}/components/#{name}.html.erb"
        if File.exist?(partial_path)
          partial_template = Tilt::ERBTemplate.new(partial_path)
          partial_template.render(self, locals)
        else
          "Partial #{partial_name} not found"
        end
      end

      def to_s
        begin
          if self.class.to_s.downcase.include? '::'
            template = Tilt::ERBTemplate.new("#{Rack::App::Utils.pwd}/components/#{self.class.to_s.downcase.gsub("::","_")}.html.erb")
          else
            template = Tilt::ERBTemplate.new("#{Rack::App::Utils.pwd}/components/#{self.class.to_s.downcase}.html.erb")
          end
          template.render(self,locals: @locals,partial: method(:display))
        rescue Errno::ENOENT => e
          "Create a view for #{self.class}"
        end
      end
      
      private 

      def initialize(locals:{})
        `mkdir -p components/`
        @locals = OpenStruct.new(locals)
      end

    end
  end
end