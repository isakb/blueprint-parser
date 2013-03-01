fs     = require "fs"
path   = require "path"
parser = require "../lib/katt-blueprint-parser"
chai   = require "chai"

EXAMPLE_FILE = path.resolve(path.join(__dirname, "..", "examples", "example.apib"))

chai.use (chai, util) ->
  chai.assert.parse = (input, result) ->
    assertion = new chai.Assertion(input)

    assertion.assert(
      util.eql(parser.parse(input), result)
      "expected \#{act} to parse as \#{exp}"
      "expected \#{act} not to parse as \#{exp}"
      result
      input
    )

  chai.assert.notParse = (input) ->
    assertion = new chai.Assertion(input)

    try
      parser.parse(input)
      parsed = true
    catch e
      parsed = false

    assertion.assert(
      not parsed
      "expected \#{act} not to parse"
      "expected \#{act} to parse"
      null
      input
    )

assert = chai.assert

Blueprint            = parser.ast.Blueprint
Operation            = parser.ast.Operation
Request              = parser.ast.Request
Response             = parser.ast.Response

scenarioBlueprint = (props = {}) ->
  new Blueprint
    name:       "API"
    operations: props.operations

operationBlueprint = (props = {}) ->
  scenarioBlueprint operations: [new Operation(props)]

requestBlueprint = (props = {}) ->
  operationBlueprint request: new Request(props)

responseBlueprint = (props = {}) ->
  operationBlueprint response: new Response(props)

describe "KATT API blueprint parser", ->
  # ===== Rule Tests =====

  # There is no canonical API.
  it "parses API", ->
    # Tests here do not mimic the grammar as tests of other rules do. This is
    # because almost all such tests would use incomplete blueprints already
    # exercised in other tests, only introducing duplication.
    blueprint = new Blueprint
      name:        "API"
      description: "Test API"
      operations: [
        new Operation url: "/one"
        new Operation url: "/two"
        new Operation url: "/three"
      ]

    assert.parse """
      --- API ---
      ---
      Test API
      ---
      GET /one
      < 200

      GET /two
      < 200

      GET /three
      < 200
    """, blueprint

    assert.parse """

      --- API ---

      ---
      Test API
      ---

      GET /one
      < 200

      GET /two
      < 200

      GET /three
      < 200
    """, blueprint

    assert.parse """



      --- API ---



      ---
      Test API
      ---



      GET /one
      < 200

      GET /two
      < 200

      GET /three
      < 200



    """, blueprint


  # Canonical APIName is "--- API ---".
  it "parses APIName", ->
    assert.parse "--- abcd",       new Blueprint name: "abcd"
    assert.parse "---   abcd",     new Blueprint name: "abcd"
    assert.parse "--- abcd ---",   new Blueprint name: "abcd"
    assert.parse "--- abcd   ---", new Blueprint name: "abcd"

  # Canonical APIDescription is:
  #
  #   ---
  #   Test API
  #   ---
  #
  it "parses APIDescription", ->
    assert.parse """
      --- API ---

      ---
      ---
    """, new Blueprint name: "API", description: null

    assert.parse """
      --- API ---

      ---
      ---
    """, new Blueprint name: "API", description: null

    assert.parse """
      --- API ---

      ---
      ---
    """, new Blueprint name: "API", description: null

    assert.parse """
      --- API ---

      ---
      abcd
      ---
    """, new Blueprint name: "API", description: "abcd"

    assert.parse """
      --- API ---

      ---
      abcd
      efgh
      ijkl
      ---
    """, new Blueprint name: "API", description: "abcd\nefgh\nijkl"

    assert.parse """
      --- API ---

      ---
      ---
    """, new Blueprint name: "API", description: null

    assert.parse """
      --- API ---

      ---
      ---
    """, new Blueprint name: "API", description: null

  # Canonical APIDescriptionLine is "abcd".
  it "parses APIDescriptionLine", ->
    assert.parse """
      --- API ---

      ---
      abcd
      ---
    """, new Blueprint name: "API", description: "abcd"

    assert.notParse """
      --- API ---

      ---
      ---
      ---
    """

  # Canonical Operations is:
  #
  #   GET /one
  #
  #   GET /two
  #
  #   GET /three
  #
  it "parses Operations", ->
    blueprint0 = new Blueprint
      name: "API"

    blueprint1 = scenarioBlueprint
      operations: [new Operation url: "/one"]

    blueprint3 = scenarioBlueprint
      operations: [
        new Operation url: "/one"
        new Operation url: "/two"
        new Operation url: "/three"
      ]

    assert.parse """
      --- API ---

    """, blueprint0

    assert.parse """
      --- API ---

      GET /one
      < 200
    """, blueprint1

    assert.parse """
      --- API ---

      GET /one
      < 200

      GET /two
      < 200

      GET /three
      < 200
    """, blueprint3

    assert.parse """
      --- API ---

      GET /one
      < 200



      GET /two
      < 200



      GET /three
      < 200
    """, blueprint3

  # Canonical Operation is:
  #
  #   GET /
  #   < 200
  #
  it "parses Operation", ->
    request = new Request
      headers: { "Content-Type": "application/json" }
      body:    "{ \"status\": \"ok\" }"

    response = new Response
      headers: { "Content-Type": "application/json" }
      body:    "{ \"id\": 1 }"

    assert.parse """
      --- API ---

      GET /
      > Content-Type: application/json
      { "status": "ok" }
      < 200
      < Content-Type: application/json
      { "id": 1 }
    """, operationBlueprint request: request, response: response

    assert.parse """
      --- API ---

      Root resource
      GET /
      > Content-Type: application/json
      { "status": "ok" }
      < 200
      < Content-Type: application/json
      { "id": 1 }
    """, operationBlueprint
      description: "Root resource",
      request:     request,
      response:    response

    assert.parse """
      --- API ---

      GET url
      < 200

      GET /
      < 200

      GET /url
      < 200
    """, new Blueprint
      name:        "API"
      operations: [
        new Operation url: "url"
        new Operation url: "/"
        new Operation url: "/url"
      ]

    assert.parse """
      --- API ---

      GET url
      < 200

      GET /
      < 200

      GET /url
      < 200
    """, new Blueprint
      name:        "API"
      operations: [
        new Operation url: "url"
        new Operation url: "/"
        new Operation url: "/url"
      ]

    assert.parse """
      --- API ---

      GET url
      < 200

      GET /
      < 200

      GET /url
      < 200
    """, new Blueprint
      name:        "API"
      operations: [
        new Operation url: "url"
        new Operation url: "/"
        new Operation url: "/url"
      ]

    assert.parse """
      --- API ---

      GET url
      < 200

      GET /
      < 200

      GET /url
      < 200
    """, new Blueprint
      name:        "API"
      operations:    [
        new Operation url: "url"
        new Operation url: "/"
        new Operation url: "/url"
      ]

  # Canonical OperationDescription is "Root resource".
  it "parses OperationDescription", ->
    assert.parse """
      --- API ---

      abcd
      GET /
      < 200
    """, operationBlueprint description: "abcd"

    assert.parse """
      --- API ---

      abcd
      efgh
      ijkl
      GET /
      < 200
    """, operationBlueprint description: "abcd\nefgh\nijkl"

  # Canonical OperationDescriptionLine is "abcd".
  it "parses OperationDescriptionLine", ->
    assert.parse """
      --- API ---

      abcd
      GET /
      < 200
    """, operationBlueprint description: "abcd"

    assert.notParse """
      --- API ---

      GET
      GET /
      < 200
    """

  # Canonical HTTPMethod is "GET".
  it "parses HTTPMethod", ->
    assert.parse """
      --- API ---

      GET /
      < 200
    """, operationBlueprint method: "GET"

    assert.parse """
      --- API ---

      POST /
      < 200
    """, operationBlueprint method: "POST"

    assert.parse """
      --- API ---

      PUT /
      < 200
    """, operationBlueprint method: "PUT"

    assert.parse """
      --- API ---

      MKCOL /
      < 200
    """, operationBlueprint method: "MKCOL"

    assert.parse """
      --- API ---

      OPTIONS /
      < 200
    """, operationBlueprint method: "OPTIONS"

    assert.parse """
      --- API ---

      PATCH /
      < 200
    """, operationBlueprint method: "PATCH"

    assert.parse """
      --- API ---

      PROPPATCH /
      < 200
    """, operationBlueprint method: "PROPPATCH"
    assert.parse """
      --- API ---

      LOCK /
      < 200
    """, operationBlueprint method: "LOCK"

    assert.parse """
      --- API ---

      UNLOCK /
      < 200
    """, operationBlueprint method: "UNLOCK"

    assert.parse """
      --- API ---

      COPY /
      < 200
    """, operationBlueprint method: "COPY"

    assert.parse """
      --- API ---

      MOVE /
      < 200
    """, operationBlueprint method: "MOVE"

    assert.parse """
      --- API ---

      DELETE /
      < 200
    """, operationBlueprint method: "DELETE"

    assert.parse """
      --- API ---

      HEAD /
      < 200
    """, operationBlueprint method: "HEAD"

  # Canonical Request is:
  #
  #   > Content-Type: application/json
  #   { "status": "ok" }
  #
  it "parses Request", ->
    assert.parse """
      --- API ---

      GET /
      > Content-Type: application/json
      < 200
    """, operationBlueprint
      request: new Request
        headers: { "Content-Type": "application/json" }
        body:    null

    assert.parse """
      --- API ---

      GET /
      > Content-Type: application/json
      { "status": "ok" }
      < 200
    """, operationBlueprint
      request: new Request
        headers: { "Content-Type": "application/json" }
        body:    "{ \"status\": \"ok\" }"

  # Canonical RequestHeaders is " Content-Type: application/json".
  it "parses RequestHeaders", ->
    assert.parse """
      --- API ---

      GET /
      < 200
    """, requestBlueprint()

    assert.parse """
      --- API ---

      GET /
      > Content-Type: application/json
      < 200
    """, requestBlueprint headers: { "Content-Type": "application/json" }

    assert.parse """
      --- API ---

      GET /
      > Content-Type: application/json
      > Content-Length: 153
      > Cache-Control: no-cache
      < 200
    """, requestBlueprint
      headers:
        "Content-Type":   "application/json"
        "Content-Length": "153"
        "Cache-Control":  "no-cache"

  # Canonical RequestHeader is "< Content-Type: application/json".
  it "parses RequestHeader", ->
    assert.parse """
      --- API ---

      GET /
      > Content-Type: application/json
      < 200
    """, requestBlueprint headers: { "Content-Type": "application/json" }

  # Canonical Response is:
  #
  #   < 200
  #   < Content-Type: application/json
  #   { "id": 1 }
  #
  it "parses Response", ->
    response = new Response
      headers: { "Content-Type": "application/json" }
      body:    "{ \"id\": 1 }"

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
      { "id": 1 }
    """, operationBlueprint response: response

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
      { "id": 1 }
    """, operationBlueprint response: response

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
      { "id": 1 }
    """, operationBlueprint response: response

  # Canonical Response is:
  #
  #   < 200
  #   < Content-Type: application/json
  #   { "status": "ok" }
  #
  it "parses Response", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
    """, operationBlueprint
      response: new Response
        status:  200
        headers: { "Content-Type": "application/json" }
        body:    null

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
      { "status": "ok" }
    """, operationBlueprint
      response: new Response
        status:  200
        headers: { "Content-Type": "application/json" }
        body:    "{ \"status\": \"ok\" }"

  # Canonical ResponseStatus is "> 200".
  it "parses ResponseStatus", ->
    assert.parse """
      --- API ---

      GET /
      < 200
    """, operationBlueprint()

    assert.parse """
      --- API ---

      GET /
      < 200
    """,   operationBlueprint()

    assert.parse """
      --- API ---

      GET /
      < 200
    """, operationBlueprint()

  # Canonical ResponseHeaders is " Content-Type: application/json".
  it "parses ResponseHeaders", ->
    assert.parse """
      --- API ---

      GET /
      < 200
    """, responseBlueprint()

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
    """, responseBlueprint headers: { "Content-Type": "application/json" }

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
      < Content-Length: 153
      < Cache-Control: no-cache
    """, responseBlueprint
      headers:
        "Content-Type": "application/json"
        "Content-Length": "153"
        "Cache-Control": "no-cache"

  # Canonical ResponseHeader is "< Content-Type: application/json".
  it "parses ResponseHeader", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
    """, responseBlueprint headers: { "Content-Type": "application/json" }

  # Canonical HttpStatus is "200".
  it "parses HttpStatus", ->
    assert.parse """
      --- API ---

      GET /
      < 0
    """, responseBlueprint status: 0

    assert.parse """
      --- API ---

      GET /
      < 9
    """, responseBlueprint status: 9

    assert.parse """
      --- API ---
      GET /
      < 123
    """, responseBlueprint status: 123

  # Canonical HttpHeader is "Content-Type: application/json".
  it "parses HttpHeader", ->
    blueprint = responseBlueprint
      headers: { "Content-Type": "application/json" }

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type:application/json
    """, blueprint

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
    """, blueprint

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type:   application/json
    """, blueprint

  # Canonical HttpHeaderName is "Content-Type".
  it "parses HttpHeaderName", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      < !: application/json
    """, responseBlueprint headers: { "!": "application/json" }

    assert.parse """
      --- API ---

      GET /
      < 200
      < 9: application/json
    """, responseBlueprint headers: { "9": "application/json" }

    assert.parse """
      --- API ---

      GET /
      < 200
      < ;: application/json
    """, responseBlueprint headers: { ";": "application/json" }

    assert.parse """
      --- API ---

      GET /
      < 200
      < ~: application/json
    """, responseBlueprint headers: { "~": "application/json" }

    assert.parse """
      --- API ---

      GET /
      < 200
      < abc: application/json
    """, responseBlueprint headers: { "abc": "application/json" }

  # Canonical HttpHeaderValue is "application/json".
  it "parses HttpHeaderValue", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: abcd
    """, responseBlueprint headers: { "Content-Type": "abcd" }

  # Canonical Body is "{ \"status\": \"ok\" }".
  it "parses Body", ->
    blueprint = responseBlueprint body: "{ \"status\": \"ok\" }"

    assert.parse """
      --- API ---

      GET /
      < 200
      <<<
      { \"status\": \"ok\" }
      >>>
    """, blueprint

    assert.parse """
      --- API ---

      GET /
      < 200
      <<<EOT
      { \"status\": \"ok\" }
      EOT
    """, blueprint

    assert.parse """
      --- API ---

      GET /
      < 200
      { \"status\": \"ok\" }
    """, blueprint

  # Canonical DelimitedBodyFixed is:
  #
  #   <<<
  #   { \"status\": \"ok\" }
  #   >>>
  #
  it "parses DelimitedBodyFixed", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      <<<
      >>>
    """, responseBlueprint body: null

    assert.parse """
      --- API ---

      GET /
      < 200
      <<<
      >>>
    """, responseBlueprint body: null

    assert.parse """
      --- API ---

      GET /
      < 200
      <<<
      >>>
    """, responseBlueprint body: null

    assert.parse """
      --- API ---

      GET /
      < 200
      <<<
      abcd
      >>>
    """, responseBlueprint body: "abcd"

    assert.parse """
      --- API ---

      GET /
      < 200
      <<<
      abcd
      efgh
      ijkl
      >>>
    """, responseBlueprint body: "abcd\nefgh\nijkl"

    assert.parse """
      --- API ---

      GET /
      < 200
      <<<
      >>>
    """, responseBlueprint body: null

    assert.parse """
      --- API ---

      GET /
      < 200
      <<<
      >>>
    """, responseBlueprint body: null

  # Canonical DelimitedBodyFixedLine is "abcd".
  it "parses DelimitedBodyFixedLine", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      <<<
      abcd
      >>>
    """, responseBlueprint body: "abcd"

  # Canonical DelimitedBodyVariable is:
  #
  #   <<<EOT
  #   { \"status\": \"ok\" }
  #   EOT
  #
  it "parses DelimitedBodyVariable", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      <<<EOT
      EOT
    """, responseBlueprint body: null

    assert.parse """
      --- API ---

      GET /
      < 200
      <<<EOT
      abcd
      EOT
    """, responseBlueprint body: "abcd"

    assert.parse """
      --- API ---

      GET /
      < 200
      <<<EOT
      abcd
      efgh
      ijkl
      EOT
    """, responseBlueprint body: "abcd\nefgh\nijkl"

  # Canonical DelimitedBodyVariableLine is "abcd".
  it "parses DelimitedBodyVariableLine", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      <<<EOT
      abcd
      EOT
    """, responseBlueprint body: "abcd"

  # Canonical DelimitedBodyVariableTerminator is "EOT".
  it "parses DelimitedBodyVariableTerminator", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      <<<abcd
      abcd
    """, responseBlueprint()

  # Canonical SimpleBody is "{ \"status\": \"ok\" }".
  it "parses SimpleBody", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      abcd
      efgh
      ijkl
    """, responseBlueprint body: "abcd\nefgh\nijkl"

    assert.parse """
      --- API ---

      GET /
      < 200
      abcd
    """, responseBlueprint body: "abcd"

    assert.notParse """
      --- API ---

      GET /
      < 200
      <<<
    """

  # Canonical SimpleBodyLine is "abcd".
  it "parses SimpleBodyLine", ->
    assert.parse """
      --- API ---

      GET /
      < 200
      abcd
    """, responseBlueprint body: "abcd"

    assert.notParse "GET /\n> "
    assert.notParse "GET /\n< "
    assert.notParse "GET /\n+++++"
    assert.notParse "GET /\n"

  # Canonical In is "> ".
  it "parses In", ->
    blueprint = requestBlueprint
      headers: { "Content-Type": "application/json" }

    assert.parse """
      --- API ---

      GET /
      > Content-Type: application/json
      < 200
    """, blueprint

    assert.parse """
      --- API ---

      GET /
      >   Content-Type: application/json
      < 200
    """, blueprint

  # Canonical Out is "< ".
  it "parses Out", ->
    blueprint = responseBlueprint
      headers: { "Content-Type": "application/json" }

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
    """, blueprint

    assert.parse """
      --- API ---

      GET /
      < 200
      <   Content-Type: application/json
    """, blueprint

  # Canonical Text0 is "abcd".
  it "parses Text0", ->
    assert.parse """
      --- API ---

      ---

      ---
    """, new Blueprint
      name:       "API"
      description: null

    assert.parse """
      --- API ---

      ---
      a
      ---
    """, new Blueprint
      name:        "API"
      description: "a"

    assert.parse """
      --- API ---

      ---
      abc
      ---
    """, new Blueprint
      name:        "API"
      description: "abc"

  # Canonical Text1 is "abcd".
  it "parses Text1", ->
    assert.parse "--- a",   new Blueprint name: "a"
    assert.parse "--- abc", new Blueprint name: "abc"

  # Canonical EmptyLine is "\n".
  it "parses EmptyLine", ->
    assert.parse "\n--- abcd",    new Blueprint name: "abcd"
    assert.parse " \n--- abcd",   new Blueprint name: "abcd"
    assert.parse "   \n--- abcd", new Blueprint name: "abcd"

  # Canonical EOLF is ""  end of input.
  it "parses EOLF", ->
    assert.parse "--- abcd\n", new Blueprint name: "abcd"
    assert.parse "--- abcd",   new Blueprint name: "abcd"

  # Canonical EOL is "\n".
  it "parses EOL", ->
    assert.parse "--- abcd\n", new Blueprint name: "abcd"

  # Canonical EOF is ""  end of input.
  it "parses EOF", ->
    assert.parse "--- abcd", new Blueprint name: "abcd"

  # Canonical S is " ".
  it "parses S", ->
    assert.parse "---\tabcd",     new Blueprint name: "abcd"
    assert.parse "---\vabcd",     new Blueprint name: "abcd"
    assert.parse "---\fabcd",     new Blueprint name: "abcd"
    assert.parse "--- abcd",      new Blueprint name: "abcd"
    assert.parse "---\u00A0abcd", new Blueprint name: "abcd"
    assert.parse "---\u1680abcd", new Blueprint name: "abcd"
    assert.parse "---\u180Eabcd", new Blueprint name: "abcd"
    assert.parse "---\u2000abcd", new Blueprint name: "abcd"
    assert.parse "---\u2001abcd", new Blueprint name: "abcd"
    assert.parse "---\u2002abcd", new Blueprint name: "abcd"
    assert.parse "---\u2003abcd", new Blueprint name: "abcd"
    assert.parse "---\u2004abcd", new Blueprint name: "abcd"
    assert.parse "---\u2005abcd", new Blueprint name: "abcd"
    assert.parse "---\u2006abcd", new Blueprint name: "abcd"
    assert.parse "---\u2007abcd", new Blueprint name: "abcd"
    assert.parse "---\u2008abcd", new Blueprint name: "abcd"
    assert.parse "---\u2009abcd", new Blueprint name: "abcd"
    assert.parse "---\u200Aabcd", new Blueprint name: "abcd"
    assert.parse "---\u202Fabcd", new Blueprint name: "abcd"
    assert.parse "---\u205Fabcd", new Blueprint name: "abcd"
    assert.parse "---\u3000abcd", new Blueprint name: "abcd"
    assert.parse "---\uFEFFabcd", new Blueprint name: "abcd"

  # ===== Complex Examples =====

  it "parses example blueprint", ->
    exampleBlueprint = fs.readFileSync(EXAMPLE_FILE).toString()
    assert.parse exampleBlueprint, new Blueprint
      name:        "Sample API v2"
      description: "Welcome to the our sample API documentation. All comments can be written in (support [Markdown](http://daringfireball.net/projects/markdown/syntax) syntax)"
      operations:  [
        new Operation
          description: "List products added into your shopping-cart. (comment block again in Markdown)"
          method:      "GET"
          url:         "/shopping-cart"
          request:     new Request
          response:    new Response
            status: 200
            headers: { "Content-Type": "application/json" }
            body: """
              { "items": [
                { "url": "/shopping-cart/1", "product":"2ZY48XPZ", "quantity": 1, "name": "New socks", "price": 1.25 }
              ] }
            """
        new Operation
          description: "Save new products in your shopping cart\nbla bla bla"
          method:      "POST"
          url:         "/shopping-cart"
          request: new Request
            headers: { "Content-Type": "application/json" }
            body:    "{ \"product\":\"1AB23ORM\", \"quantity\": 2 }"
          response: new Response
            status:  201
            headers: { "Content-Type": "application/json" }
            body:    "{ \"status\": \"created\", \"url\": \"/shopping-cart/2\" }"

        new Operation
          description: "This resource allows you to submit payment information to process your *shopping cart* items"
          method:      "POST"
          url:         "/payment"
          request: new Request
            body: "{ \"cc\": \"12345678900\", \"cvc\": \"123\", \"expiry\": \"0112\" }"
          response: new Response
              status: 200
              body:   "{ \"receipt\": \"/payment/receipt/1\" }"
      ]

  it "returns a parsed blueprint #toBlueprint() as the original blueprint", ->
    exampleBlueprint = fs.readFileSync(EXAMPLE_FILE).toString()
    assert.deepEqual parser.parse(exampleBlueprint).toBlueprint() + '\n', exampleBlueprint
