$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'rack/mapper'
require 'sample'

run Rack::Mapper.new('/sample' => Sample)
