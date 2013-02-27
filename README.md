KATT API Blueprint Parser
=======================

A JavaScript parser of KATT API blueprints (which are derived from [Apiary API
blueprints](http://apiary.io/blueprint)).

Usage
-----

See the `src/ast.coffee` file to get an idea about returned objects and their
capabilities.

The exception thrown in case of error will contain `offset`, `line`, `column`,
`expected`, `found` and `message` properties with more details about the error.

Compatibility
-------------

The parser should run well in Node.js 0.6.18+.
