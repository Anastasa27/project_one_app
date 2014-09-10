require 'json'
require 'redis'
require 'uri'

uri = URI.parse(ENV["REDISTOGO_URL"])
$redis = Redis.new({:host => uri.host,
                    :port => uri.port,
                    :password => uri.password})


# file_contents = File.read('user_data.json')
# ruby_object = JSON.parse(file_contents)


    user1 = {
      "user_name" => "Anastasia Konecky",
      "email" => "anastasiakonecky@gmail.com",
      "ny_times" => "on",
      "twitter_books" => "on",
      "idream_books" => "on",
      "book_browse_news" => "on"
    }

  $redis.set("user:1", user1.to_json)




