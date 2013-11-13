# TWITTER OAUTH

1. [Learning Objectives](#learning-objectives)
1. [Summary](#summary)
1. [Releases](#releases)
1. [Helpful Resources](#helpful-resources)

## Learning Objectives
1. Understanding the Oauth protocol. 
1. Using the Oauth protocol to interact with an API (twitter)

## Summary

Building on [Tweet Now! 1: Single User](/challenges/313), let's add support for logging in with Twitter.  This will be our first application that uses OAuth for authentication.

Create an application that allows a user to sign in via Oauth from Twitter and then send a tweet. 

##Releases
### Release 1: Getting Setup.

Fork this repository to get started. The skeleton here has already implemented OAuth. Unless you're feeling incredibly ambitious, you should use it as a starting point for your multi-user Tweet Now! app.  

 **BEFORE** you start, spend time reading the 
 [Twitter OAuth Documentation](https://dev.twitter.com/docs/auth/oauth ) and familiarize yourself with the basics of OAuth version 1.  See if you can relate what you learn to the image below.

### Configuring Your Environment

Your Twitter "consumer key" and "consumer secret" answer the question, "What application is doing the acting?"

The application skeleton we've provided expects you to have `TWITTER_KEY` and `TWITTER_SECRET` environment variables defined for your running server. This is so that we can deploy things securely to Heroku later.

You can set these keys in your 'yaml' file that will not be uploaded to Heroku or Github.  See [this post](https://gist.github.com/dbc-challenges/c513a933644ed9ba2bc8) for more details

Or, for a quick start you can simply `export` these environment variables before we run `shotgun` (these will only be available for the current session):

```bash
$ export TWITTER_KEY=<your_twitter_consumer_key>
$ export TWITTER_SECRET=<your_twitter_consumer_secret>
$ shotgun
```

Since you are using OAuth, you will also need to set a `callback function` which is the route the application will be directed to after the user is authenticated.  When you are using localhost, this callback function is actually set in the request token (see the helper method in your skeleton), BUT you still need to set something in the callback field when registering your application with Twitter.  As you can read in [this post]( https://dev.twitter.com/discussions/5749) you can actually set this to any valid url and it will be overwritten by the attribute of your request token. 

### Release 2:  Getting It Running Without Code Changes

Unlike your previous Twitter applications, the "access token" and "access token secret" will have to change *depending on what user is currently authenticated*.  This key pair answers the question, "On whose behalf is this application acting?"

Twitter needs to answer both of these questions to make sure that the application is valid and that the application can only do what it has permission to do on behalf of an authenticated user.  



The core OAuth flow goes like this:

1. Application generates URL to "Sign In with Twitter".
2. Application renders page with "Sign In with Twitter" link
3. User clicks "Sign In with Twitter"
4. User is redirected to Twitter and authorizes the application
5. User is redirected back to the application's callback URL
6. Application verifies the redirection from Twitter is valid
7. If valid, Application takes appropriate action

Assuming you've configured things properly, the skeleton app should just run out of the box. However, the skeleton app doesn't do anything related to creating the user, logging her in, etc. You'll need to implement that part on your own later. For now, though, just make sure the application skeleton works (which will prove that your environment and Twitter application are configured correctly).


### Release 3: Create Users with Access Tokens in Database

Now you'll need to implement that last step of the OAuth flow. Specifically, you'll need to create the new user, set her as "logged in", store her access token and secret along with her user record, etc. This should happen inside of the `/auth` route in your `controllers/index.rb` file:

```ruby
get '/auth' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # our request token is only valid until we use it to get an access token, so let's delete it from our session
  session.delete(:request_token)

  # at this point in the code is where you'll need to create your user account and store the access token

  erb :index
end
```

We'll want a `User` model, however the user won't have a password.  Instead, the user will be authenticated via OAuth.  With OAuth there's not necessarily a distinction between signing up and logging in &mdash; the first time a user authenticates via Twitter we can create the `User` object. Instead of a password, you'll want to have columns to store her "access token" and "access token secret".

### Release 4: Tweet on behalf of your user
Now that you have an authenticated user who has authorized you to use Twitter on their behalf, revisit your "Tweet Now!" app and send some tweets for this user. 


### Release 5: Deploying Securely to Heroku

**STOP** - Go find your laptop and use it to deploy to Heroku - please (no really please) do not reset the SSH keys on DBC machines. 

We don't want our confidential information (like application keys and secrets) to be stored in git, especially if we're going to push this to a public repository. If we *were* to store them in a public repository, anyone would be able to pretend to be our application. **NOT good.**

Configuring the `TWITTER_KEY` and `TWITTER_SECRET` environment variables on our local machine was easy. [On Heroku, it's slighly more complicated](https://devcenter.heroku.com/articles/config-vars):

```bash
$ heroku config:add TWITTER_KEY=<your_twitter_consumer_key> TWITTER_SECRET=<your_twitter_consumer_secret>
```

After that, you should be able to deploy! :)

Get to it.  Create a new Heroku application.  Add Heroku as a git remote.  Run `heroku config:add` to set up the Twitter key and secret.  Push to Heroku.

##Helpful Resources

* [OAuth version 1](http://oauth.net/core/1.0a/)

* How the OAuth (v1) Conversation Works

<img src="https://docs.google.com/drawings/d/1E0SMvb5_vL6aqLD3sngHzC1Kn_K_N_P11ooauSf2FKQ/pub?w=960&h=720">
