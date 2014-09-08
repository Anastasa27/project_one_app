require 'json'
require 'pry'
require 'redis'
require 'uri'

uri = URI.parse(ENV["REDISTOGO_URL"])
$redis = Redis.new({:host => uri.host,
                    :port => uri.port,
                    :password => uri.password})

$redis = Redis.new
$redis.flushdb

file_contents = File.read('cheese_data.json')
ruby_object = JSON.parse(file_contents)


ruby_object["cheese_data"].each_with_index do |cheese, index|
  $redis.set("cheeses:#{index}", cheese.to_json)
end

