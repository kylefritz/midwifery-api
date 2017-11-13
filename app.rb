require 'sinatra'
require 'sinatra/cors'
require 'redis'
require 'json'

$redis = Redis.new(url: ENV["REDIS_URL"])

set :allow_origin, "*"
set :allow_methods, "GET,HEAD,POST"
set :allow_headers, "content-type,if-modified-since"
set :expose_headers, "location,link"

before do
  content_type :json
end

get '/' do
  caught_babies = $redis.get('caught')
  puts "Caught Babies: #{caught_babies}"
  {babies: caught_babies}.to_json
  # erb :caught_babies, locals: {caught_babies: caught_babies}
end
