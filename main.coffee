
_ = require 'lodash'
Twitter = require 'twitter'

pass = require './lib/password.js'

env = (name) ->
    value = process.env[name]
    if !value
        console.error 'Missing required environment variable \'' + name + '\''
        process.exit -1
    value

clientName = env 'TWITTER_SCREEN_NAME'

client = new Twitter
    consumer_key: env 'TWITTER_CONSUMER_KEY'
    consumer_secret: env 'TWITTER_CONSUMER_SECRET'
    access_token_key: env 'TWITTER_ACCESS_TOKEN_KEY'
    access_token_secret: env 'TWITTER_ACCESS_TOKEN_SECRET'

generateResponse = (userName, userContent) ->
    score = pass.score userContent
    switch
        when score >= 50 then return '"' + userContent + '" is a strong password.'
        when score <= 10 then return '"' + userContent + '" is too weak. Try a stronger password.'
    newPass = userContent
    while pass.score(newPass) < 50
        newPass = pass.strengthen newPass
    return '"' + userContent + '" is too weak. Try "' + newPass + '" instead.'

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

    stream.on 'error', (error) -> throw error
