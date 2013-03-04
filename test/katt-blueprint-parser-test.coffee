parser = require "../lib/katt-blueprint-parser"
chai   = require "chai"


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
Section              = parser.ast.Section
Interaction          = parser.ast.Interaction
Request              = parser.ast.Request
Response             = parser.ast.Response

sectionBlueprint = (props = {}) ->
  new Blueprint
    name:     "API"
    sections: [new Section(props)]

interactionBlueprint = (props = {}) ->
  sectionBlueprint interactions: [new Interaction(props)]

requestBlueprint = (props = {}) ->
  interactionBlueprint request: new Request(props)

responseBlueprint = (props = {}) ->
  interactionBlueprint responses: [new Response(props)]

describe "KATT API blueprint parser", ->
  # ===== Rule Tests =====

  # There is no canonical API.
  it "parses API", ->
    # Tests here do not mimic the grammar as tests of other rules do. This is
    # because almost all such tests would use incomplete blueprints already
    # exercised in other tests, only introducing duplication.
    blueprint = new Blueprint
      location:    "http://example.com/"
      name:        "API"
      description: "Test API"
      sections:    [
        new Section interactions: [
          new Interaction url: "/one"
          new Interaction url: "/two"
          new Interaction url: "/three"
        ]
        new Section name: "Section 1"
        new Section name: "Section 2"
        new Section name: "Section 3"
      ]

    assert.parse """
      HOST: http://example.com/
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

      -- Section 1 --
      -- Section 2 --
      -- Section 3 --
    """, blueprint

    assert.parse """

      HOST: http://example.com/

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

      -- Section 1 --
      -- Section 2 --
      -- Section 3 --
    """, blueprint

    assert.parse """



      HOST: http://example.com/



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



      -- Section 1 --
      -- Section 2 --
      -- Section 3 --

    """, blueprint

  # Canonical Location is "HOST: http://example.com/".
  it "parses Location", ->
    assert.parse """
      HOST:abcd

      --- API ---
    """, new Blueprint location: "abcd", name: "API"

    assert.parse """
      HOST: abcd

      --- API ---
    """, new Blueprint location: "abcd", name: "API"

    assert.parse """
      HOST:   abcd

      --- API ---
    """, new Blueprint location: "abcd", name: "API"

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

  # Canonical Sections is:
  #
  #   -- Section 1 --
  #   -- Section 2 --
  #   -- Section 3 --
  #
  it "parses Sections", ->
    blueprint0 = new Blueprint
      name: "API"
      sections: []

    blueprint1 = new Blueprint
      name:     "API"
      sections: [new Section name: "Section 1"]

    blueprint3 = new Blueprint
      name:     "API"
      sections: [
        new Section name: "Section 1"
        new Section name: "Section 2"
        new Section name: "Section 3"
      ]

    assert.parse """
      --- API ---

    """, blueprint0

    assert.parse """
      --- API ---

      -- Section 1 --
    """, blueprint1

    assert.parse """
      --- API ---

      -- Section 1 --
      -- Section 2 --
      -- Section 3 --
    """, blueprint3

    assert.parse """
      --- API ---

      -- Section 1 --

      -- Section 2 --

      -- Section 3 --
    """, blueprint3

    assert.parse """
      --- API ---

      -- Section 1 --



      -- Section 2 --



      -- Section 3 --
    """, blueprint3

  # Canonical Section is "-- Section --".
  it "parses Section", ->
    blueprint = sectionBlueprint
      name:      "Section"
      interactions: [
        new Interaction url: "/one"
        new Interaction url: "/two"
        new Interaction url: "/three"
      ]

    assert.parse """
      --- API ---

      -- Section --
      GET /one
      < 200

      GET /two
      < 200

      GET /three
      < 200
    """, blueprint

    assert.parse """
      --- API ---

      -- Section --

      GET /one
      < 200

      GET /two
      < 200

      GET /three
      < 200
    """, blueprint

    assert.parse """
      --- API ---

      -- Section --



      GET /one
      < 200

      GET /two
      < 200

      GET /three
      < 200
    """, blueprint

  # Canonical SectionHeader is "-- Section --".
  it "parses SectionHeader", ->
    assert.parse """
      --- API ---

      -- Section --
    """, sectionBlueprint name: "Section"

    assert.parse """
      --- API ---

      --\nSection\n--
    """, sectionBlueprint name: "Section"

  # Canonical SectionHeaderShort is "-- Section --".
  it "parses SectionHeaderShort", ->
    assert.parse """
      --- API ---

      -- abcd
    """, sectionBlueprint name: "abcd"

    assert.parse """
      --- API ---

      --   abcd
    """, sectionBlueprint name: "abcd"

    assert.parse """
      --- API ---

      -- abcd --
    """, sectionBlueprint name: "abcd"

    assert.parse """
      --- API ---

      -- abcd   --
    """, sectionBlueprint name: "abcd"

  # Canonical SectionHeaderLong is:
  #
  #   ---
  #   Test API
  #   ---
  #
  it "parses SectionHeaderLong", ->
    assert.parse """
      --- API ---

      --
      --
    """, sectionBlueprint name: null, description: null

    assert.parse """
      --- API ---

      --
      --
    """, sectionBlueprint name: null, description: null

    assert.parse """
      --- API ---

      --
      --
    """, sectionBlueprint name: null, description: null

    assert.parse """
      --- API ---

      --
      abcd
      --
    """, sectionBlueprint name: "abcd", description: null

    assert.parse """

      --- API ---

      --
      abcd
      efgh
      ijkl
      --
    """, sectionBlueprint name: "abcd", description: "efgh\nijkl"

    assert.parse """
      --- API ---

      --
      --
    """, sectionBlueprint name: null, description: null

    assert.parse """
      --- API ---

      --
      --
    """, sectionBlueprint name: null, description: null

  # Canonical SectionHeaderLongLine is "abcd".
  it "parses SectionHeaderLongLine", ->
    assert.parse """
      --- API ---

      --
      abcd
      --
    """, sectionBlueprint name: "abcd"

    assert.notParse """
      --- API ---

      --
      --
      --
    """

  # Canonical Interactions is:
  #
  #   GET /one
  #
  #   GET /two
  #
  #   GET /three
  #
  it "parses Interactions", ->
    blueprint0 = new Blueprint
      name: "API"

    blueprint1 = sectionBlueprint
      interactions: [new Interaction url: "/one"]

    blueprint3 = sectionBlueprint
      interactions: [
        new Interaction url: "/one"
        new Interaction url: "/two"
        new Interaction url: "/three"
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

  # Canonical Interaction is:
  #
  #   GET /
  #   < 200
  #
  it "parses Interaction", ->
    request = new Request
      headers: { "Content-Type": "application/json" }
      body:    "{ \"status\": \"ok\" }"

    responses = [
      new Response
        headers: { "Content-Type": "application/json" }
        body:    "{ \"id\": 1 }"
      new Response
        headers: { "Content-Type": "application/json" }
        body:    "{ \"id\": 2 }"
      new Response
        headers: { "Content-Type": "application/json" }
        body:    "{ \"id\": 3 }"
    ]

    assert.parse """
      --- API ---

      GET /
      > Content-Type: application/json
      { "status": "ok" }
      < 200
      < Content-Type: application/json
      { "id": 1 }
      +++++
      < 200
      < Content-Type: application/json
      { "id": 2 }
      +++++
      < 200
      < Content-Type: application/json
      { "id": 3 }
    """, interactionBlueprint request: request, responses: responses

    assert.parse """
      --- API ---

      Root resource
      GET /
      > Content-Type: application/json
      { "status": "ok" }
      < 200
      < Content-Type: application/json
      { "id": 1 }
      +++++
      < 200
      < Content-Type: application/json
      { "id": 2 }
      +++++
      < 200
      < Content-Type: application/json
      { "id": 3 }
    """, interactionBlueprint
      description: "Root resource",
      request:     request,
      responses:   responses

    assert.parse """
      HOST: http://example.com

      --- API ---

      GET url
      < 200

      GET /
      < 200

      GET /url
      < 200
    """, new Blueprint
      location:    "http://example.com"
      name:        "API"
      sections:    [
        new Section interactions: [
          new Interaction url: "url"
          new Interaction url: "/"
          new Interaction url: "/url"
        ]
      ]

    assert.parse """
      HOST: http://example.com/

      --- API ---

      GET url
      < 200

      GET /
      < 200

      GET /url
      < 200
    """, new Blueprint
      location:    "http://example.com/"
      name:        "API"
      sections:    [
        new Section interactions: [
          new Interaction url: "url"
          new Interaction url: "/"
          new Interaction url: "/url"
        ]
      ]

    assert.parse """
      HOST: http://example.com/path

      --- API ---

      GET url
      < 200

      GET /
      < 200

      GET /url
      < 200
    """, new Blueprint
      location:    "http://example.com/path"
      name:        "API"
      sections:    [
        new Section interactions: [
          new Interaction url: "/path/url"
          new Interaction url: "/path/"
          new Interaction url: "/path/url"
        ]
      ]

    assert.parse """
      HOST: http://example.com/path/

      --- API ---

      GET url
      < 200

      GET /
      < 200

      GET /url
      < 200
    """, new Blueprint
      location:    "http://example.com/path/"
      name:        "API"
      sections:    [
        new Section interactions: [
          new Interaction url: "/path/url"
          new Interaction url: "/path/"
          new Interaction url: "/path/url"
        ]
      ]

  # Canonical InteractionDescription is "Root resource".
  it "parses InteractionDescription", ->
    assert.parse """
      --- API ---

      abcd
      GET /
      < 200
    """, interactionBlueprint description: "abcd"

    assert.parse """
      --- API ---

      abcd
      efgh
      ijkl
      GET /
      < 200
    """, interactionBlueprint description: "abcd\nefgh\nijkl"

  # Canonical InteractionDescriptionLine is "abcd".
  it "parses InteractionDescriptionLine", ->
    assert.parse """
      --- API ---

      abcd
      GET /
      < 200
    """, interactionBlueprint description: "abcd"

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
    """, interactionBlueprint method: "GET"

    assert.parse """
      --- API ---

      POST /
      < 200
    """, interactionBlueprint method: "POST"

    assert.parse """
      --- API ---

      PUT /
      < 200
    """, interactionBlueprint method: "PUT"

    assert.parse """
      --- API ---

      DELETE /
      < 200
    """, interactionBlueprint method: "DELETE"

    assert.parse """
      --- API ---

      OPTIONS /
      < 200
    """, interactionBlueprint method: "OPTIONS"

    assert.parse """
      --- API ---

      PATCH /
      < 200
    """, interactionBlueprint method: "PATCH"

    assert.parse """
      --- API ---

      PROPPATCH /
      < 200
    """, interactionBlueprint method: "PROPPATCH"
    assert.parse """
      --- API ---

      LOCK /
      < 200
    """, interactionBlueprint method: "LOCK"

    assert.parse """
      --- API ---

      UNLOCK /
      < 200
    """, interactionBlueprint method: "UNLOCK"

    assert.parse """
      --- API ---

      COPY /
      < 200
    """, interactionBlueprint method: "COPY"

    assert.parse """
      --- API ---

      MOVE /
      < 200
    """, interactionBlueprint method: "MOVE"

    assert.parse """
      --- API ---

      DELETE /
      < 200
    """, interactionBlueprint method: "DELETE"

    assert.parse """
      --- API ---

      MKCOL /
      < 200
    """, interactionBlueprint method: "MKCOL"

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
    """, interactionBlueprint
      request: new Request
        headers: { "Content-Type": "application/json" }
        body:    null

    assert.parse """
      --- API ---

      GET /
      > Content-Type: application/json
      { "status": "ok" }
      < 200
    """, interactionBlueprint
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

  # Canonical Responses is:
  #
  #   < 200
  #   < Content-Type: application/json
  #   { "id": 1 }
  #   +++++
  #   < 200
  #   < Content-Type: application/json
  #   { "id": 1 }
  #   +++++
  #   < 200
  #   < Content-Type: application/json
  #   { "id": 1 }
  #
  it "parses Responses", ->
    responses = [
      new Response
        headers: { "Content-Type": "application/json" }
        body:    "{ \"id\": 1 }"
      new Response
        headers: { "Content-Type": "application/json" }
        body:    "{ \"id\": 2 }"
      new Response
        headers: { "Content-Type": "application/json" }
        body:    "{ \"id\": 3 }"
    ]

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
      { "id": 1 }
    """, interactionBlueprint responses: responses[0..0]

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
      { "id": 1 }
      +++++
      < 200
      < Content-Type: application/json
      { "id": 2 }
    """, interactionBlueprint responses: responses[0..1]

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
      { "id": 1 }
      +++++
      < 200
      < Content-Type: application/json
      { "id": 2 }
      +++++
      < 200
      < Content-Type: application/json
      { "id": 3 }
    """, interactionBlueprint responses: responses[0..2]

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
    """, interactionBlueprint
      responses: [
        new Response
          status:  200
          headers: { "Content-Type": "application/json" }
          body:    null
      ]

    assert.parse """
      --- API ---

      GET /
      < 200
      < Content-Type: application/json
      { "status": "ok" }
    """, interactionBlueprint
      responses: [
        new Response
          status:  200
          headers: { "Content-Type": "application/json" }
          body:    "{ \"status\": \"ok\" }"
      ]

  # Canonical ResponseStatus is "> 200".
  it "parses ResponseStatus", ->
    assert.parse """
      --- API ---

      GET /
      < 200
    """, interactionBlueprint()

    assert.parse """
      --- API ---

      GET /
      < 200
    """,   interactionBlueprint()

    assert.parse """
      --- API ---

      GET /
      < 200
    """, interactionBlueprint()

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

  # Canonical ResponseSeparator is "+++++".
  it "parses ResponseSeparator", ->
    blueprint = interactionBlueprint responses: [new Response, new Response]

    assert.parse """
      --- API ---

      GET /
      < 200
      +++++
      < 200
    """, blueprint

    assert.parse """
      --- API ---

      GET /
      < 200
      +++++
      < 200
    """, blueprint

    assert.parse """
      --- API ---

      GET /
      < 200
      +++++
      < 200
    """, blueprint

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

  it "parses demo blueprint", ->
    assert.parse """
      HOST: http://www.google.com/

      --- Sample API v2 ---
      ---
      Welcome to the our sample API documentation. All comments can be written in (support [Markdown](http://daringfireball.net/projects/markdown/syntax) syntax)
      ---

      --
      Shopping Cart Interactions
      The following is a section of interactions related to the shopping cart
      --
      List products added into your shopping-cart. (comment block again in Markdown)
      GET /shopping-cart
      < 200
      < Content-Type: application/json
      { "items": [
        { "url": "/shopping-cart/1", "product":"2ZY48XPZ", "quantity": 1, "name": "New socks", "price": 1.25 }
      ] }

      Save new products in your shopping cart
      POST /shopping-cart
      > Content-Type: application/json
      { "product":"1AB23ORM", "quantity": 2 }
      < 201
      < Content-Type: application/json
      { "status": "created", "url": "/shopping-cart/2" }


      -- Payment Interactions --
      This resource allows you to submit payment information to process your *shopping cart* items
      POST /payment
      { "cc": "12345678900", "cvc": "123", "expiry": "0112" }
      < 200
      { "receipt": "/payment/receipt/1" }
    """, new Blueprint
      location:    "http://www.google.com/"
      name:        "Sample API v2"
      description: "Welcome to the our sample API documentation. All comments can be written in (support [Markdown](http://daringfireball.net/projects/markdown/syntax) syntax)"
      sections:    [
        new Section
          name:        "Shopping Cart Interactions"
          description: "The following is a section of interactions related to the shopping cart"
          interactions:   [
            new Interaction
              description: "List products added into your shopping-cart. (comment block again in Markdown)"
              method:      "GET"
              url:         "/shopping-cart"
              request:     new Request
              responses:   [
                new Response
                  status: 200
                  headers: { "Content-Type": "application/json" }
                  body: """
                    { "items": [
                      { "url": "/shopping-cart/1", "product":"2ZY48XPZ", "quantity": 1, "name": "New socks", "price": 1.25 }
                    ] }
                  """
              ]
            new Interaction
              description: "Save new products in your shopping cart"
              method:      "POST"
              url:         "/shopping-cart"
              request: new Request
                headers: { "Content-Type": "application/json" }
                body:    "{ \"product\":\"1AB23ORM\", \"quantity\": 2 }"
              responses: [
                new Response
                  status:  201
                  headers: { "Content-Type": "application/json" }
                  body:    "{ \"status\": \"created\", \"url\": \"/shopping-cart/2\" }"
              ]
          ]
        new Section
          name:      "Payment Interactions"
          interactions: [
             new Interaction {
               description: "This resource allows you to submit payment information to process your *shopping cart* items"
               method:      "POST"
               url:         "/payment"
               request:     new Request
                 body: "{ \"cc\": \"12345678900\", \"cvc\": \"123\", \"expiry\": \"0112\" }"
               responses:   [
                 new Response
                   status: 200
                   body:   "{ \"receipt\": \"/payment/receipt/1\" }"
               ]
             }
          ]
      ]
