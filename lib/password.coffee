
_ = require 'lodash'

words = require './wordlist.js'

# precompile the word list to regexes
wordRegexes = _.map words, (w) -> new RegExp w, 'g'

# perform naïve string replacement to remove all the words
collapseWords = (pass) ->
    for word in wordRegexes
        pass = pass.replace word, '�' # use U+FFFD as a filler character
    pass.replace /�/g, 'a'

# take a collapsed password and calculate its score
calculateScore = (pass) ->
    # these are the different classes of characters
    types = [
        pass.match /[A-Za-z]/
        pass.match /[0-9]/
        pass.match /[ \t\n\r]/
        pass.match /[^A-Za-z0-9 \t\n\r]/
    ]
    # count how many different kinds were present
    baseScore = _.filter(types).length
    # multiply by the whole length
    baseScore * pass.length

exports.scorePassword = _.flow collapseWords, calculateScore
