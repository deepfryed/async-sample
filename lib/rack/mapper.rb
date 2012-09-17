require 'rack'

module Rack
  class Mapper
    def initialize map
      @map = remap(map)
    end

    def remap map
      map.map     {|path, app| [path, app.respond_to?(:new) ? app.new(:path => path) : app]}
         .sort_by {|path, app| path.size}.reverse
         .map     {|path, app| [Regexp.new("^#{path.chomp('/')}(?:/(.*)|$)"), path, app]}
    end

    def call env
      rest, path, app = find_mapping(env['PATH_INFO'])
      app ? dispatch(app, env, rest, path) : not_found(env)
    end

    def dispatch app, env, rest, path
      app.call(env.merge('PATH_INFO' => rest, 'SCRIPT_NAME' => ::File.join(env['SCRIPT_NAME'], path)))
    end

    def not_found env
      [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["no application mounted at #{env['REQUEST_PATH']}"]]
    end

    def find_mapping path
      @map.each do |re, location, app|
        if re.match(path)
          return ["/#{$1}", location, app]
        end
      end
      nil
    end
  end # Mapper
end # Rack
