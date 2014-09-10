require 'json'
require 'redis'
require 'uri'

uri = URI.parse(ENV["REDISTOGO_URL"])
$redis = Redis.new({:host => uri.host,
                    :port => uri.port,
                    :password => uri.password})

$redis = Redis.new
$redis.flushdb

file_contents = File.read('user_data.json')
ruby_object = JSON.parse(file_contents)


ruby_object["user1"].each_with_index do |"user1", index|
  $redis.set("user1:#{index}", user1.to_json)
end

