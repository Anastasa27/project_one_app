require 'securerandom'
require 'sinatra/base'
require 'httparty'
require 'open-uri'
require 'twitter'
require 'redis'
require 'json'
require 'uri'
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
    uri = URI.parse(ENV["REDISTOGO_URL"])
    $redis = Redis.new({:host => uri.host,
                        :port => uri.port,
                       :password => uri.password})
    $redis.setnx("user_counter", 1)
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
  #######################
  #GIT HUB OAUTH API KEYS
  #######################
  CLIENT_ID = "b8028cf37f30ca6dfb83"
  CLIENT_SECRET = "3a220ae5024aade3020ac3ec03646e342d0e73d4"
  CALLBACK_URL = ENV['PROJECT_ONE_REDIRECT_URI']
  #######################

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

  get('/') do
    base_url = "https://github.com/login/oauth/authorize"
    scope = "user"
    state = SecureRandom.urlsafe_base64
    session[:state] = state
    @url = "#{base_url}?client_id=#{CLIENT_ID}&scope=#{scope}&redirect_uri=#{CALLBACK_URL}&state=#{state}"
    render(:erb, :index)
  end

  get('/oauth_callback') do
    code = params[:code]
    if session[:state] == params[:state]
        response = HTTParty.post(
          "https://github.com/login/oauth/access_token",
            :body => {
              client_id: CLIENT_ID,
              client_secret: CLIENT_SECRET,
              code: code,
              redirect_uri: CALLBACK_URL,
              },
            :headers => {
             "Accept" => "application/json"
              })
        session[:access_token] = response["access_token"]
    end
    redirect('/')
  end


  get('/logout') do
    session[:access_token] = nil
    redirect to('/')
  end


  get('/profile/new') do
    render(:erb, :profile_info_form, :template => :layout)
  end

  get('/profile') do
    render(:erb, :profile_info_form, :template => :layout)
  end

  get('/twitter_books') do
    @user1 = get_user(session[:user_id_num])
    @tweets = []
    TWITTER_CLIENT.search("twitterbooks", :result_type => "recent").take(20).each_with_index do |tweet|
      @tweets.push(tweet.text)
    end
      render(:erb, :twitter_books, :template => :layout)
  end

  get('/idream_books') do
    @user1 = get_user(session[:user_id_num])
    @book_reviews = HTTParty.get("http://idreambooks.com/api/publications/recent_recos.json?key=31b59ece20986033f5307f7907f7d94e87b4a45f&slug=fiction").to_json
    @parsed_reviews = JSON.parse(@book_reviews)
    render(:erb, :idream_books, :template => :layout)
  end

  get('/ny_times') do
     @user1 = get_user(session[:user_id_num])
     @ny_times_response = HTTParty.get("http://api.nytimes.com/svc/books/v2/lists.json?list=hardcover-fiction&api-key=a334d90853f03ea079bda17f9f0fc548:17:69767462").to_json
    @parsed_version = JSON.parse(@ny_times_response)
    render(:erb, :ny_times, :template => :layout)
  end

  get('/book_browse_news') do
    @user1 = get_user(session[:user_id_num])
    url = 'https://www.bookbrowse.com/rss/book_news.rss'
      open(url) do |rss|
        @feed = RSS::Parser.parse(rss)
    end
      render(:erb, :book_browse_news, :template => :layout)
  end

  get('/dashboard') do
    #weather
    @city = "new_york"
    @state = "ny"
    @weather = HTTParty.get("http://api.wunderground.com/api/8df98bbf67d1296c/conditions/q/#{@state}/#{@city}.json")
    @temp_in_farh = @weather["current_observation"]["temp_f"]
    #new york times bestsellers
    @user1 = get_user(session[:user_id_num])
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
  end # ends get /dashboard

  get('/feeds') do
    render(:erb, :dashboard, :template => :layout)
  end

  post('/feeds') do
    session[:user_id_num] = nil
    user_hash = {
      :user_id => $redis.get("user_counter"),
      :user_name => params[:user_name],
      :email => params[:email],
      :ny_times => params[:ny_times],
      :twitter_books => params[:twitter_books],
      :idream_books => params[:idream_books],
      :book_browse_news => params[:book_browse_news],
    }

    session[:user_id_num] = $redis.get("user_counter")
      $redis.set("user:#{$redis.get("user_counter")}", user_hash.to_json)
        $redis.incr("user_counter")
      redirect('/dashboard')
    end

  post('/profile/edit') do
    redirect to('/profile/new')
  end


  get('/profile/:id') do
    @user_profiles = get_user(params[:id])
      render(:erb, :profile, :template => :layout)
  end

  def get_user(user_id)
    JSON.parse($redis.get("user:#{user_id}"))
  end


end

