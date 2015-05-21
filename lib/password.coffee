
_ = require 'lodash'

words = require './wordlist.js'

# precompile the word list to regexes
wordRegexes = _.map words, (w) -> new RegExp w, 'g'

# character replacements for 'smart' replacement
replacementMap = {
    alphabetic: {
        '0': 'O'
        '1': 'l'
        '2': 'Z'
        '3': 'E'
        '4': 'A'
        '5': 'S'
        '6': 'G'
        '7': 'L'
        '!': 'l'
        '@': 'a'
        '$': 'S'
    }
    numeric: {
        'o': '0'
        'O': '0'
        'l': '1'
        'I': '1'
        'z': '2'
        'Z': '2'
        'e': '3'
        'E': '3'
        'a': '4'
        'A': '4'
        's': '5'
        'S': '5'
        'G': '6'
        'L': '7'
    }
    symbolic: {
        'a': '@'
        'e': '&'
        'i': '!'
        'o': '@'
        'u': '^'
    }
}

getSmartReplacement = (c, type, def) ->
    replacementMap[type][c] or def

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

# helper function for functional modification of strings
setChar = (str, index, char) ->
    if index > str.length - 1 then str
    else str.substr(0, index) + char + str.substr(index + 1)

# grabs a random index in a string of a character matching the given regular expression
randomIndexMatching = (string, regex) ->
    index = -1
    result = ''
    while !result.match regex
        index = Math.floor(Math.random() * string.length)
        result = string[index]
    index

# attempts to improve the strength of a password using three possible strategies
# - if one of the three 'character classes' is missing, it performs substitution to add it
# - if not, it bisects strings of alphabetic characters to attempt to remove long words
# - otherwise, it just fails and stupidly tacks numbers onto the end
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
        charToReplace = pass[index]
        # get a character to use in the replacing
        replacement = switch
            when !counts.alphabetic then getSmartReplacement charToReplace, 'alphabetic', 'a'
            when !counts.numeric    then getSmartReplacement charToReplace, 'numeric', '0'
            when !counts.whitespace then ' '
            else                         getSmartReplacement charToReplace, 'symbolic', '!'
        return setChar pass, index, replacement
    # otherwise, we can try to bisect words to split them up
    alphabeticSequences = pass.match /[A-Za-z]+/g
    if alphabeticSequences and _.some(alphabeticSequences, (s) -> s.length >= 2)
        longestSequence = _.last _.sortBy alphabeticSequences, (s) -> s.length
        replacementIndex = Math.floor(longestSequence.length / 2)
        charToReplace = longestSequence[replacementIndex]
        replacementChar = getSmartReplacement charToReplace, 'numeric', '!'
        replacementSequence = setChar longestSequence, replacementIndex, replacementChar
        return pass.replace longestSequence, replacementSequence
    # if all else fails, just tack stuff onto the end
    return pass + _.sample ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!']

exports.score = _.flow collapseWords, calculateScore
exports.strengthen = strengthenPassword
