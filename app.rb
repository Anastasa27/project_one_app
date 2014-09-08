require 'securerandom'
require 'sinatra/base'
require 'httparty'
require 'open-uri'
require 'twitter'
require 'redis'
require 'json'
require 'uri'
require 'pry'
require 'rss'



class App < Sinatra::Base

  ########################
  # Configuration
  ########################

  configure do
    enable :logging
    enable :method_override
    enable :sessions
    set :session_secret, 'super secret'
    uri = URI.parse(ENV["REDISTOGO"])
    $redis = Redis.new({:host => uri.host,
                        :port => uri.port,
                        :password => uri.password})


  end

  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end

 #########################
 #API KEYS
 #########################
WUNDERGROUND_API_KEY = ENV['8df98bbf67d1296c']
TWITTER_API_KEY = 'KAHgTJJDsE8EmiQTMvTWc6mUQ'
TWITTER_SECRET_KEY = 'TMbxpVO5NisM0E0QN6ese8i2QieFsaMEUgZlTJPuT8klVXPVOF'
TWITTER_ACCESS_TOKEN = '2790859370-RiHbePsaHNIjdmSV4vWfUMUvCro1mJA4xhbDxyy'
TWITTER_ACCESS_SECRET_TOKEN = 'vMNh7eTX5Qy99DWXDMs5Vc2HpXPcX64EkpqLex8RdX5Xe'
NY_TIMES_API_KEY = 'a334d90853f03ea079bda17f9f0fc548:17:69767462'
IDREAMBOOKS_API_KEY = '31b59ece20986033f5307f7907f7d94e87b4a45f'
  ########################
  # Twitter
  ########################
TWITTER_CLIENT = Twitter::REST::Client.new do |config|
  config.consumer_key        = TWITTER_API_KEY
  config.consumer_secret     = TWITTER_SECRET_KEY
  config.access_token        = TWITTER_ACCESS_TOKEN
  config.access_token_secret = TWITTER_ACCESS_SECRET_TOKEN
end
  #######################
  #Routes
  #######################

#     }]
 # get('/') do
 #    @cheeses = []
 #    $redis.keys('*cheese*').each do |key|
 #      @cheeses << get_model_from_redis(key)
 #    end
 #    render(:erb, :"cheeses/index")
 #  end



  get('/') do
    render(:erb, :index)
  end

  get('/profile/new') do
    render(:erb, :profile_info_form)
  end

  get("/profile/:id") do
    @user_profile = @@user_profile
    @id = params[:id].to_i
    index = @id - 1
    @selected_profile = @name[index]
    render(:erb, :profile)
  end

  get('/profile') do
    render(:erb, :profile)
  end


  post('/profile/new') do

    # new_user = {
    #   :"user_name" =>  params["name"],
    #   :"email"     =>  params["email"],
    # }
    # add_user_profile_info(new_user)
    redirect to('/dashboard')
  end

  get('/dashboard') do
    #weather
      @city = "new_york"
      @state = "ny"
      @weather = HTTParty.get("http://api.wunderground.com/api/8df98bbf67d1296c/conditions/q/#{@state}/#{@city}.json")
      @temp_in_farh = @weather["current_observation"]["temp_f"]
      #new york times bestsellers
      @ny_times_response = HTTParty.get("http://api.nytimes.com/svc/books/v2/lists.json?list=hardcover-fiction&api-key=a334d90853f03ea079bda17f9f0fc548:17:69767462").to_json
      @parsed_version = JSON.parse(@ny_times_response)
      #twitter
      @tweets = []
      TWITTER_CLIENT.search("twitterbooks", :result_type => "recent").take(20).each_with_index do |tweet|
       @tweets.push(tweet.text)
      end
      #idreambooks
      @book_reviews = HTTParty.get("http://idreambooks.com/api/publications/recent_recos.json?key=31b59ece20986033f5307f7907f7d94e87b4a45f&slug=fiction").to_json
      @parsed_reviews = JSON.parse(@book_reviews)
      #bookbrowse news rss
      url = 'https://www.bookbrowse.com/rss/book_news.rss'
      open(url) do |rss|
      @feed = RSS::Parser.parse(rss)
      end
    render(:erb, :dashboard)
  end



  get('/feeds') do
    # @selection_of_feeds = ["ny_times", "twitter_books", "idream_books_yes", "book_browse_news"]
     @user_feeds = []
     if @user_feeds.include?("")
     @user_feeds.each do |feed|
    end
    render(:erb, :profile_info_form)
  end

  post('/profile/new')
  number = $redis.keys.size
  number += 1
  $redis.set("feed#{number}", params["ny_times", "twitter_books", "idream_books_yes", "book_browse_news"].to_json)
  binding.pry
  redirect('/dashboard')
  end

  # def add_user_profile_info(new_user)
  #   new_user = $redis.keys("*new_user*")
  #   key = new_user + 1
  #   $redis.set(key, new_user.to_json)
  #   redirect to("/profile/new")
  # end


  # delete('/profile/:id') do
  #  @@user_profile.delete_at(params[:id].to_i)
  #  redirect to('/profile/new')
  # end

end
