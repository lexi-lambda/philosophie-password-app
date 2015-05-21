
expect = require 'expect.js'
seed = require 'seed-random'

pass = require '../lib/password.js'

describe 'password module', ->
    it 'should calculate the password score', ->
        expect(pass.score 'password1').to.be 4
        expect(pass.score 'goat m4n').to.be 15
        expect(pass.score 's0_0per 5nak3').to.be 44

    it 'should perform simple strengthening on passwords with missing classes', ->
        seed 'test-seed', global: true
        expect(pass.strengthen 'password1').to.be 'pas word1'
        expect(pass.strengthen 'pas word1').to.be 'pas w@rd1'

    it 'should perform bisection strengthening if classes are present', ->
        seed 'test-seed', global: true
        expect(pass.strengthen 'password 0!').to.be 'pass!ord 0!'
        expect(pass.strengthen 'pass!ord 0!').to.be 'pa5s!ord 0!'

    it 'should perform simple append when all else fails', ->
        seed 'test-seed', global: true
        expect(pass.strengthen 'a0 !').to.be 'a0 !3'
        expect(pass.strengthen 'a0 !3').to.be 'a0 !37'
