require 'sinatra'
require 'redis'

$redis = Redis.new(url: ENV["REDIS_URL"])

 get '/' do
   caught_babies = $redis.get('caught')
   "Caught Babies: #{caught_babies}"
 end
