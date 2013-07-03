# KATT API Blueprint Parser [![Build Status][2]][1]

A JavaScript parser of KATT API blueprints (which are derived from [Apiary API
blueprints](http://apiary.io/blueprint)).

## Usage

See the `src/ast.coffee` file to get an idea about returned objects and their
capabilities.

The exception thrown in case of error will contain `offset`, `line`, `column`,
`expected`, `found` and `message` properties with more details about the error.

## License

[MIT](LICENSE)


  [1]: https://travis-ci.org/isakb/blueprint-parser
  [2]: https://travis-ci.org/isakb/blueprint-parser.png
