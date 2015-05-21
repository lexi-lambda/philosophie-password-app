
fs = require 'fs'

words = fs.readFileSync 'resources/wordlist.txt', encoding: 'utf-8'
    # split by lines
    .split '\n'
    # only care about words with three or more characters
    .filter (w) -> w.length >= 3
    # sort by length, descending
    .sort (a, b) -> if a.length == b.length then 0 else if a.length < b.length then 1 else -1

module.exports = words
