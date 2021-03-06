require 'sinatra'
require 'sinatra/cors'
require 'redis'
require 'json'

$redis = Redis.new(url: ENV["REDIS_URL"])

set :allow_origin, "*"
set :allow_methods, "GET,HEAD,POST,PATCH,DELETE"
set :allow_headers, "content-type,if-modified-since"
set :expose_headers, "location,link"

before do
  content_type :json
end

get '/' do
  caught_babies = ($redis.get('caught') || 0).to_i
  puts "KJ has caught #{caught_babies} babies!"
  {babies: caught_babies}.to_json
  # erb :caught_babies, locals: {caught_babies: caught_babies}
end

post '/' do
  caught_babies = ($redis.incr('caught') || 0).to_i
  puts "KJ has caught #{caught_babies} babies!"
  {babies: caught_babies}.to_json
end

delete '/' do
  caught_babies = ($redis.decr('caught') || 0).to_i
  puts "KJ has caught #{caught_babies} babies!"
  {babies: caught_babies}.to_json
end

post '/emoji' do
  from = params['From']
  body = params['Body']
  hash = {
    'from' => from,
    'body' => body,
    'time' => Time.now,
  }
  json = hash.to_json
  parents = ENV['parents'].split(',')
  list = parents.include?(from) ? 'parents' : 'fans'
  $redis.rpush(list, json)
  status 200
end

get '/emoji' do
  parents = $redis.lrange('parents', 0, -1)
    .map { |message| JSON.parse(message) }
  fans = $redis.lrange('fans', 0, -1)
    .map { |message| JSON.parse(message) }
  hash = {
    'parents' => parents,
    'fans' => fans,
  }
  hash.to_json
end
