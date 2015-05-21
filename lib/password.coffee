
_ = require 'lodash'

words = require './wordlist.js'

# precompile the word list to regexes
wordRegexes = _.map words, (w) -> new RegExp w, 'g'

# perform naïve string replacement to remove all the words
collapseWords = (pass) ->
    for word in wordRegexes
        pass = pass.replace word, '�' # use U+FFFD as a filler character
    pass.replace /�/g, 'a'

# get a numeric count of the different types of characters
countKinds = (pass) ->
    alphabetic: pass.match(/[A-Za-z]/g)?.length or 0
    numeric:    pass.match(/[0-9]/g)?.length or 0
    whitespace: pass.match(/[ \t\n\r]/g)?.length or 0
    other:      pass.match(/[^A-Za-z0-9 \t\n\r]/g)?.length or 0

# take a collapsed password and calculate its score
calculateScore = (pass) ->
    # count how many different kinds were present
    baseScore = _.values(countKinds pass).filter((k) -> k > 0).length
    # multiply by the whole length
    baseScore * pass.length

setChar = (str, index, char) ->
    if index > str.length - 1 then str
    else str.substr(0, index) + char + str.substr(index + 1)

randomIndexMatching = (string, regex) ->
    index = -1
    result = ''
    while !result.match regex
        index = Math.floor(Math.random() * string.length)
        result = string[index]
    index

strengthenPassword = (pass) ->
    counts = countKinds pass
    countsValues = _.values counts
    # if there are multiple of one class of characters, but we're missing one of the other
    # kinds, we can strengthen the password easily
    if _.some(countsValues, (c) -> c >= 2) and !_.all(countsValues, (c) -> c > 0)
        # grab a random replacement character
        kindToReplace = switch
            when counts.alphabetic >= 2 then /[A-Za-z]/
            when counts.numeric    >= 2 then /[0-9]/
            when counts.whitespace >= 2 then /[ \t\n\r]/
            else                             /[^A-Za-z0-9 \t\n\r]/
        index = randomIndexMatching pass, kindToReplace
        # get a character to use in the replacing
        replacement = switch
            when !counts.alphabetic then 'a'
            when !counts.numeric    then '0'
            when !counts.whitespace then ' '
            else                         '!'
        return setChar pass, index, replacement
    # otherwise, we can try to bisect words to split them up
    alphabeticSequences = pass.match /[A-Za-z]+/g
    if alphabeticSequences and _.some(alphabeticSequences, (s) -> s.length >= 2)
        longestSequence = _.last _.sortBy alphabeticSequences, (s) -> s.length
        replacementIndex = Math.floor(longestSequence.length / 2)
        replacementSequence = setChar longestSequence, replacementIndex, '!'
        return pass.replace longestSequence, replacementSequence
    # if all else fails, just tack stuff onto the end
    return pass + _.sample ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!']

exports.score = _.flow collapseWords, calculateScore
exports.strengthen = strengthenPassword
