
_ = require 'lodash'
Twitter = require 'twitter'

pass = require './lib/password.js'

# helper function for reading from the environment and trapping errors
env = (name) ->
    value = process.env[name]
    if !value
        console.error 'Missing required environment variable \'' + name + '\''
        process.exit -1
    value

clientName = env 'TWITTER_SCREEN_NAME'

# authorize with the Twitter API
client = new Twitter
    consumer_key: env 'TWITTER_CONSUMER_KEY'
    consumer_secret: env 'TWITTER_CONSUMER_SECRET'
    access_token_key: env 'TWITTER_ACCESS_TOKEN_KEY'
    access_token_secret: env 'TWITTER_ACCESS_TOKEN_SECRET'

# creates responses for user input
# string string -> string
generateResponse = (userName, userContent) ->
    score = pass.score userContent
    switch
        when score >= 50 then return '"' + userContent + '" is a strong password.'
        when score <= 10 then return '"' + userContent + '" is too weak. Try a stronger password.'
    newPass = userContent
    while pass.score(newPass) < 50
        newPass = pass.strengthen newPass
    return '"' + userContent + '" is too weak. Try "' + newPass + '" instead.'

# the main loop -- makes use of Twitter's streaming API
# we look for all tweets containing $clientName, then filter to tweets starting with @mentions
client.stream 'statuses/filter', { track: clientName }, (stream) ->

    stream.on 'data', (tweet) ->
        if _.startsWith tweet.text, '@' + clientName + ' '
            # strip off the front
            userContent = tweet.text.substring 2 + clientName.length
            response = '@' + tweet.user.screen_name + ' ' +
                generateResponse tweet.user.screen_name, userContent
            client.post 'statuses/update',
                { status: response, in_reply_to_status_id: tweet.id },
                (error) -> if (error) then throw error

    # if a communication error happens, we just die
    stream.on 'error', (error) -> throw error
