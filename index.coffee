prefix = './lib'
prefix = './src'  if /.coffee$/.test module.filename

exports = module.exports = require "#{prefix}/katt-blueprint-parser"
exports.ast = require "#{prefix}/ast"
