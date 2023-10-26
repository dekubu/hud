class Base < Rack::App
    
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