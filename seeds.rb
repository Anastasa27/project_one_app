require 'json'
require 'redis'
require 'uri'

uri = URI.parse(ENV["REDISTOGO_URL"])
$redis = Redis.new({:host => uri.host,
                    :port => uri.port,
                    :password => uri.password})

$redis.flushdb

# file_contents = File.read('user_data.json')
# ruby_object = JSON.parse(file_contents)


    user1 = [
      {
      "user_name" => "Anastasia Konecky",
      "email" => "anastasiakonecky@gmail.com",
      "ny_times" => "on",
      "twitter_books" => "on",
      "idream_books" => "on",
      "book_browse_news" => "on" }
      ]



ruby_object[user1].each_with_index do |user1, index|
  $redis.set("user1:#{index}", user1.to_json)
end

