fs = require 'fs'
PEG = require 'pegjs'

module.exports = PEG.buildParser fs.readFileSync "#{__dirname}/katt-blueprint-parser.pegjs", 'utf8'
