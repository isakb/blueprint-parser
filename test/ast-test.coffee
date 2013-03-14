parser     = require "../lib/katt-blueprint-parser"
{ assert } = require "chai"


Blueprint            = parser.ast.Blueprint
Operation            = parser.ast.Operation
Request              = parser.ast.Request
Response             = parser.ast.Response

# AST nodes

filledRequest = (method = "GET", url = "/") ->
  new Request
    method: method
    url: url
    headers: { "Content-Type": "application/json" }
    body:    "{ \"status\": \"ok\" }"

filledResponse = ->
  new Response
    status:  200
    headers: { "Content-Type": "application/json" }
    body:    "{ \"id\": 1 }"

filledOperation = (n) ->
  new Operation
    description: "Post to resource #{n}"
    request:     filledRequest("POST", "/post-#{n}")
    response:    filledResponse()

filledOperations = (filledOperation(n) for n in [1..3])

filledBlueprint = new Blueprint
  name:        "API"
  description: "Test API"
  operations:  filledOperations

# JSONs

filledRequestJson = (method = "GET", url = "/") ->
  method: method,
  url: url,
  headers: { "Content-Type": "application/json" }
  body:    "{ \"status\": \"ok\" }"

filledResponseJson = ->
  status:  200
  headers: { "Content-Type": "application/json" }
  body:    "{ \"id\": 1 }"


filledOperationJson = (n) ->
  {
    description: "Post to resource #{n}"
    request:     filledRequestJson("POST", "/post-#{n}")
    response:    filledResponseJson()
  }

filledOperationJsons = (filledOperationJson(n) for n in [1..3])

filledBlueprintJson =
  name:         "API"
  description:  "Test API"
  operations: filledOperationJsons

# Blueprints

filledRequestBlueprint = (method = "GET", url = "/") ->
  """
  #{method} #{url}
  > Content-Type: application/json
  { "status": "ok" }
  """

filledResponseBlueprint = ->
  """
  < 200
  < Content-Type: application/json
  { "id": 1 }
  """

filledOperationBlueprint = (n) ->
  """
    Post to resource #{n}
    #{filledRequestBlueprint("POST", "/post-#{n}")}
    #{filledResponseBlueprint()}
  """

filledOperationBlueprints = (filledOperationBlueprint(n) for n in [1..3])

filledBlueprintBlueprint = """
  --- API ---

  ---
  Test API
  ---

  #{filledOperationBlueprints[0]}

  #{filledOperationBlueprints[1]}

  #{filledOperationBlueprints[2]}
"""

bodyTestcases = [
  { body: "> ",           blueprint: "<<<\n> \n>>>"                }
  { body: ">   ",         blueprint: "<<<\n>   \n>>>"              }
  { body: "line\n> ",     blueprint: "<<<\nline\n> \n>>>"          }
  { body: "> \nline",     blueprint: "<<<\n> \nline\n>>>"          }
  { body: "a> ",          blueprint: "a> "                         }

  { body: "< ",           blueprint: "<<<\n< \n>>>"                }
  { body: "<   ",         blueprint: "<<<\n<   \n>>>"              }
  { body: "line\n< ",     blueprint: "<<<\nline\n< \n>>>"          }
  { body: "< \nline",     blueprint: "<<<\n< \nline\n>>>"          }
  { body: "a< ",          blueprint: "a< "                         }

  { body: " ",            blueprint: "<<<\n \n>>>"                 }
  { body: "   ",          blueprint: "<<<\n   \n>>>"               }
  { body: "line\n",       blueprint: "<<<\nline\n\n>>>"            }
  { body: "\nline",       blueprint: "<<<\n\nline\n>>>"            }
  { body: "a ",           blueprint: "a "                          }
  { body: " a",           blueprint: " a"                          }

  { body: "\n>>>",        blueprint: "<<<EOT\n\n>>>\nEOT"          }
  { body: "\n>>> ",       blueprint: "<<<EOT\n\n>>> \nEOT"         }
  { body: "\n>>>   ",     blueprint: "<<<EOT\n\n>>>   \nEOT"       }
  { body: "\n\n>>>",      blueprint: "<<<EOT\n\n\n>>>\nEOT"        }
  { body: "\n>>>\n",      blueprint: "<<<EOT\n\n>>>\n\nEOT"        }
  { body: "\na>>>",       blueprint: "<<<\n\na>>>\n>>>"            }
  { body: "\n>>>a",       blueprint: "<<<\n\n>>>a\n>>>"            }

  { body: "\n>>>\nEOT",   blueprint: "<<<EOT1\n\n>>>\nEOT\nEOT1"   }
  { body: "\n>>>\n\nEOT", blueprint: "<<<EOT1\n\n>>>\n\nEOT\nEOT1" }
  { body: "\n>>>\nEOT\n", blueprint: "<<<EOT1\n\n>>>\nEOT\n\nEOT1" }
  { body: "\n>>>\naEOT",  blueprint: "<<<EOT\n\n>>>\naEOT\nEOT"    }
  { body: "\n>>>\nEOTa",  blueprint: "<<<EOT\n\n>>>\nEOTa\nEOT"    }
]

describe "Blueprint", ->
  emptyBlueprint = new Blueprint

  describe ".fromJSON", ->
    it "creates a new blueprint from a JSON-serializable object", ->
      assert.deepEqual Blueprint.fromJSON(filledBlueprintJson), filledBlueprint

  describe "#constructor", ->
    describe "when passed property values", ->
      it "initializes properties correctly", ->
        blueprint = filledBlueprint

        assert.deepEqual blueprint.name,        "API"
        assert.deepEqual blueprint.description, "Test API"
        assert.deepEqual blueprint.operations,  filledOperations

    describe "when not passed property values", ->
      it "uses correct defaults", ->
        assert.deepEqual emptyBlueprint.name,        null
        assert.deepEqual emptyBlueprint.description, null
        assert.deepEqual emptyBlueprint.operations,  []

  describe "#toJSON", ->
    describe "on a filled-in blueprint", ->
      it "returns a correct JSON-serializable object", ->
        assert.deepEqual filledBlueprint.toJSON(), filledBlueprintJson

  describe "#toBlueprint", ->
    describe "on an empty blueprint", ->
      it "returns a correct blueprint", ->
        assert.deepEqual emptyBlueprint.toBlueprint(), ""

    describe "on a filled-in blueprint", ->
      it "returns a correct blueprint", ->
        assert.deepEqual filledBlueprint.toBlueprint(), filledBlueprintBlueprint

describe "Operation", ->
  emptyOperation = new Operation

  describe ".fromJSON", ->
    it "creates a new operation from a JSON-serializable object", ->
      assert.deepEqual Operation.fromJSON(filledOperationJsons[0]), filledOperations[0]

  describe "#constructor", ->
    describe "when passed property values", ->
      it "initializes properties correctly", ->
        operation = filledOperations[0]

        assert.deepEqual operation.description, "Post to resource 1"
        assert.deepEqual operation.request,     filledRequest("POST", "/post-1")
        assert.deepEqual operation.response,    filledResponse()

    describe "when not passed property values", ->
      it "uses correct defaults", ->
        assert.deepEqual emptyOperation.description, null
        assert.deepEqual emptyOperation.request,     new Request(method: "GET", url: "/")
        assert.deepEqual emptyOperation.response,    new Response

  describe "#toJSON", ->
    describe "on a filled-in operation", ->
      it "returns a correct JSON-serializable object", ->
        assert.deepEqual filledOperations[0].toJSON(), filledOperationJsons[0]

  describe "#toBlueprint", ->
    describe "on an empty operation", ->
      it "returns a correct blueprint", ->
        assert.deepEqual emptyOperation.toBlueprint(), "GET /\n< 200"

    describe "on a filled-in operation", ->
      it "returns a correct blueprint", ->
        assert.deepEqual filledOperations[0].toBlueprint(), filledOperationBlueprints[0]

describe "Request", ->
  emptyRequest = new Request

  describe ".fromJSON", ->
    it "creates a new request from a JSON-serializable object", ->
      assert.deepEqual Request.fromJSON(filledRequestJson()), filledRequest()

  describe "#constructor", ->
    describe "when passed property values", ->
      it "initializes properties correctly", ->
        assert.deepEqual filledRequest().headers, { "Content-Type": "application/json" }
        assert.deepEqual filledRequest().body,    "{ \"status\": \"ok\" }"

    describe "when not passed property values", ->
      it "uses correct defaults", ->
        assert.deepEqual emptyRequest.headers, {}
        assert.deepEqual emptyRequest.body,    null

  describe "#toJSON", ->
    describe "on a filled-in request", ->
      it "returns a correct JSON-serializable object", ->
        assert.deepEqual filledRequest().toJSON(), filledRequestJson()

  describe "#toBlueprint", ->
    describe "on an empty request", ->
      it "returns a correct blueprint", ->
        assert.deepEqual emptyRequest.toBlueprint(), "GET /"

    describe "on a filled-in request", ->
      it "returns a correct blueprint", ->
        assert.deepEqual filledRequest().toBlueprint(), filledRequestBlueprint()

    describe "on requests with weird bodies", ->
      it "uses suitable body syntax", ->
        for testcase in bodyTestcases
          request = new Request body: testcase.body

          assert.deepEqual request.toBlueprint(), "GET /\n" + testcase.blueprint

describe "Response", ->
  emptyResponse = new Response

  describe ".fromJSON", ->
    it "creates a new response from a JSON-serializable object", ->
      assert.deepEqual Response.fromJSON(filledResponseJson()), filledResponse()

  describe "#constructor", ->
    describe "when passed property values", ->
      it "initializes properties correctly", ->
        response = filledResponse()

        assert.deepEqual response.status,  200
        assert.deepEqual response.headers, { "Content-Type": "application/json" }
        assert.deepEqual response.body,    "{ \"id\": 1 }"

    describe "when not passed property values", ->
      it "uses correct defaults", ->
        assert.deepEqual emptyResponse.status,  200
        assert.deepEqual emptyResponse.headers, {}
        assert.deepEqual emptyResponse.body,    null

  describe "#toJSON", ->
    describe "on a filled-in response", ->
      it "returns a correct JSON-serializable object", ->
        assert.deepEqual filledResponse().toJSON(), filledResponseJson()

  describe "#toBlueprint", ->
    describe "on an empty response", ->
      it "returns a correct blueprint", ->
        assert.deepEqual emptyResponse.toBlueprint(), "< 200"

    describe "on a filled-in response", ->
      it "returns a correct blueprint", ->
        assert.deepEqual filledResponse().toBlueprint(), filledResponseBlueprint()

    describe "on responses with weird bodies", ->
      it "uses suitable body syntax", ->
        for testcase in bodyTestcases
          response = new Response body: testcase.body

          assert.deepEqual response.toBlueprint(), "< 200\n#{testcase.blueprint}"
