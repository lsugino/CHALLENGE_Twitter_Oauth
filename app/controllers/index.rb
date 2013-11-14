enable :sessions

get '/' do
  @access_token = session[:access] if session[:access]
  erb :index
end

get '/sign_in' do
  # p params
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  redirect request_token.authorize_url
end

get '/sign_out' do
  session.clear
  redirect '/'
end

get '/auth' do
  if session[:access]
    @access_token = session[:access] 
  else
    # the `request_token` method is defined in `app/helpers/oauth.rb`
    @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    # our request token is only valid until we use it to get an access token, so let's delete it from our session
    session.delete(:request_token)
    session[:access] = @access_token
  end
  # at this point in the code is where you'll need to create your user account and store the access token
  @current_user = User.find_or_create_by_oauth_token_and_oauth_secret_and_username(@access_token.token, @access_token.secret, @access_token.params[:screen_name])

  session[:user] = @current_user

  erb :index



  # # the `request_token` method is defined in `app/helpers/oauth.rb`
  # @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # # our request token is only valid until we use it to get an access token, so let's delete it from our session
  # session.delete(:request_token)

  # # at this point in the code is where you'll need to create your user account and store the access token

  # erb :index
end


post '/tweet_me' do 
  tweeter = Twitter::Client.new(
    :consumer_key => "cE2RW18jqWBipqkfDiS4sg",
    :consumer_secret => "Mn6b1HCvZnXbMXAdDSeTtDMoO2njgqDfdeUg8f0OjM",
    :oauth_token => session[:user].oauth_token, 
    :oauth_token_secret => session[:user].oauth_secret
    )
  tweeter.update(params[:tweet])
end
