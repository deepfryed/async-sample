require 'yajl'
require 'em-http'
require 'em-synchrony/em-http'
require 'sinatra/symphony'

# so logger prints out the request path
module Rack
  class MapLogger < AsyncRack::CommonLogger
    def log env, status, header, began_at
      path_info, env['PATH_INFO'] = env['PATH_INFO'], env['REQUEST_PATH']
      super
    ensure
      env['PATH_INFO'] = path_info
    end
  end
end

class Sample < Sinatra::Symphony

  use Rack::MapLogger

  get '/' do
    'hello world!'
  end

  get '/google' do
    content_type :json
    http = EM::HttpRequest.new('http://www.google.com/').get
    Yajl.dump(http.response_header)
  end
end
