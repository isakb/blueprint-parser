{
  assert
} = require './_utils'
parser     = require "../"

Blueprint            = parser.ast.Blueprint
Transaction          = parser.ast.Transaction
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

filledTransaction = (n) ->
  new Transaction
    description: "Post to resource #{n}"
    request:     filledRequest("POST", "/post-#{n}")
    response:    filledResponse()

filledTransactions = (filledTransaction(n) for n in [1..3])

filledBlueprint = new Blueprint
  name:        "API"
  description: "Test API"
  transactions:  filledTransactions

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


filledTransactionJson = (n) ->
  {
    description: "Post to resource #{n}"
    request:     filledRequestJson("POST", "/post-#{n}")
    response:    filledResponseJson()
  }

filledTransactionJsons = (filledTransactionJson(n) for n in [1..3])

filledBlueprintJson =
  name:         "API"
  description:  "Test API"
  transactions: filledTransactionJsons

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

filledTransactionBlueprint = (n) ->
  """
    Post to resource #{n}
    #{filledRequestBlueprint("POST", "/post-#{n}")}
    #{filledResponseBlueprint()}
  """

filledTransactionBlueprints = (filledTransactionBlueprint(n) for n in [1..3])

filledBlueprintBlueprint = """
  --- API ---

  ---
  Test API
  ---

  #{filledTransactionBlueprints[0]}

  #{filledTransactionBlueprints[1]}

  #{filledTransactionBlueprints[2]}
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

        assert.deepEqual blueprint.name,         "API"
        assert.deepEqual blueprint.description,  "Test API"
        assert.deepEqual blueprint.transactions, filledTransactions

    describe "when not passed property values", ->
      it "uses correct defaults", ->
        assert.deepEqual emptyBlueprint.name,         null
        assert.deepEqual emptyBlueprint.description,  null
        assert.deepEqual emptyBlueprint.transactions, []

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

describe "Transaction", ->
  emptyTransaction = new Transaction

  describe ".fromJSON", ->
    it "creates a new transaction from a JSON-serializable object", ->
      assert.deepEqual Transaction.fromJSON(filledTransactionJsons[0]), filledTransactions[0]

  describe "#constructor", ->
    describe "when passed property values", ->
      it "initializes properties correctly", ->
        transaction = filledTransactions[0]

        assert.deepEqual transaction.description, "Post to resource 1"
        assert.deepEqual transaction.request,     filledRequest("POST", "/post-1")
        assert.deepEqual transaction.response,    filledResponse()

    describe "when not passed property values", ->
      it "uses correct defaults", ->
        assert.deepEqual emptyTransaction.description, null
        assert.deepEqual emptyTransaction.request,     new Request(method: "GET", url: "/")
        assert.deepEqual emptyTransaction.response,    new Response

  describe "#toJSON", ->
    describe "on a filled-in transaction", ->
      it "returns a correct JSON-serializable object", ->
        assert.deepEqual filledTransactions[0].toJSON(), filledTransactionJsons[0]

  describe "#toBlueprint", ->
    describe "on an empty transaction", ->
      it "returns a correct blueprint", ->
        assert.deepEqual emptyTransaction.toBlueprint(), "GET /\n< 200"

    describe "on a filled-in transaction", ->
      it "returns a correct blueprint", ->
        assert.deepEqual filledTransactions[0].toBlueprint(), filledTransactionBlueprints[0]

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
