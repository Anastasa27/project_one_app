require 'sinatra/base'
require 'httparty'
require 'open-uri'
require 'twitter'
require 'json'
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
  # Routes
  ########################
TWITTER_CLIENT = Twitter::REST::Client.new do |config|
  config.consumer_key        = TWITTER_API_KEY
  config.consumer_secret     = TWITTER_SECRET_KEY
  config.access_token        = TWITTER_ACCESS_TOKEN
  config.access_token_secret = TWITTER_ACCESS_SECRET_TOKEN
end

  get('/') do
    render(:erb, :index)
  end

  get('/profile/new') do
    render(:erb, :profile_info_form)
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


  post('/profile/new') do

    new_profile = {
      :user_name  => params[:user_name],
      :email => params[:email]
    }
    @@profile.push(new_profile)
     logger.info @@profile
    redirect to('/profile/new')
  end

end
