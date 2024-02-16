require "rack/app"
require "yaml"
require "tilt"
require "pry"
require "ostruct"
require "tilt/erb"
require "rack/app/front_end"

require_relative "hud/version"


module Hud
  def self.configuration
    @configuration ||= OpenStruct.new
  end

  def self.configure
    configuration.components_dirs = []
    configuration.base_path = Pathname.new(Rack::App::Utils.pwd) 
    yield(configuration)
  end
  module Middleware

    def self.included(base)
      base.use Middleware::Version
      #base.use Middleware::Environment
    end

    class Version
      def initialize(app)
        @app = app
        manifest_path = File.join('config', 'manifest.yml')
        @version = YAML.load_file(manifest_path)['version']
      end

      def call(env)
        status, headers, response = @app.call(env)


        if ENV['HUD_SHOW_VERSION']
          response_body = ''
          response.each { |part| response_body << part }
          version_div = "<div style='position:fixed; bottom:0; right:0; z-index:9999; background-color:rgba(255, 255, 255, 0.7); padding:5px;'>Version: #{@version}</div>"
          response_body.sub!("</body>", "#{version_div}</body>")
          headers["Content-Length"] = response_body.bytesize.to_s

          response = [response_body]
        end

        [status, headers, response]
      end
    end
    class Environment
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, response = @app.call(env)


        if ENV['HUD_SHOW_ENVIROMENT']
          color = 'green'
          color = 'orange' if ENV['HUD_ENV'] == "next" 
          color = 'red' if ENV['HUD_ENV'] == "live" 

          response_body = ''
          response.each { |part| response_body << part }
          indicator_div = "<div style='position:fixed; top:0; z-index:9999; height:30px; width:100%; background-color:#{color}; z-index:9999;'>#{ENV['HARBR_ENV']&.upcase} ENVIRONMENT</div>"
          response_body.sub!("<body>", "<body>#{indicator_div}")
          headers["Content-Length"] = response_body.bytesize.to_s
        end

        response = [response_body]


        [status, headers, response]
      end
    end

  end


  class Display
    module Helpers
      def display(name, from: nil, locals: {})
        klz = Display.build(name)
        klz.call(locals: locals).render_template(name: name, locals: @locals, from: from)
      end
      alias_method :render, :display
      alias_method :d, :display   
      alias_method :r, :display   
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

      
      def display(name, locals: {},css:nil)
        template = Tilt::ERBTemplate.new("#{Hud.configuration.base_path}/components/#{name.to_s}.html.erb")
        result = template.render(self, locals)
        return Oga.parse_html(result).css(css) if css
        result
      end

      alias_method :render, :display
      alias_method :d, :display   
      alias_method :r, :display   

      def production?
        ENV["RACK_ENV"] == "production"
      end

      def staging?
        ENV["RACK_ENV"] == "staging"
      end

      def self.call(locals: {})
        new(locals: locals)
      end

      def render_template(name: nil, from: nil, locals: {},css: nil)
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

            puts path
            if from.nil?
              result = template.render(self, locals)
              return Oga.parse_html(result).css(css) if css
              return result
            else
              from_path = base_path.join(from, "components")
              result = template.render(self, locals)
              return Oga.parse_html(result).css(css) if css
              return result if path.to_path.start_with? from_path.to_s
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

    class Screen < Rack::App
      include Hud::Middleware
      include Hud::Display::Helpers

      apply_extensions :logger
      apply_extensions :front_end

      helpers do
        include Hud::Display::Helpers
      end

    end

  end
end
