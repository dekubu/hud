class Base < Rack::App
    
    Hud.configure do |config|
      config.components_dir = :base
    end

    apply_extensions :logger
    apply_extensions :front_end

    layout 'layout.html.erb'

    helpers do
        include Hud::Display::Helpers
    end

    get '/' do
       render 'index.html.erb'
    end

    get '/ok' do
        "hud - OK!"
    end

end