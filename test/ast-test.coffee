parser     = require "../lib/katt-blueprint-parser"
{ assert } = require "chai"


Blueprint            = parser.ast.Blueprint
Section              = parser.ast.Section
Resource             = parser.ast.Resource
Request              = parser.ast.Request
Response             = parser.ast.Response

# AST nodes

filledRequest = new Request
  headers: { "Content-Type": "application/json" }
  body:    "{ \"status\": \"ok\" }"

filledResponses = [
  new Response
    status:  200
    headers: { "Content-Type": "application/json" }
    body:    "{ \"id\": 1 }"
  new Response
    status:  200
    headers: { "Content-Type": "application/json" }
    body:    "{ \"id\": 2 }"
  new Response
    status:  200
    headers: { "Content-Type": "application/json" }
    body:    "{ \"id\": 3 }"
]

filledResources = [
  new Resource
    description: "Post resource 1"
    method:      "POST"
    url:         "/post-1"
    request:     filledRequest
    responses:   filledResponses
  new Resource
    description: "Post resource 2"
    method:      "POST"
    url:         "/post-2"
    request:     filledRequest
    responses:   filledResponses
  new Resource
    description: "Post resource 3"
    method:      "POST"
    url:         "/post-3"
    request:     filledRequest
    responses:   filledResponses
]

filledSections = [
  new Section
    name:        "Section 1"
    description: "Test section 1"
    resources:    filledResources
  new Section
    name:        "Section 2"
    description: "Test section 2"
    resources:    filledResources
  new Section
    name:        "Section 3"
    description: "Test section 3"
    resources:    filledResources
]

filledBlueprint = new Blueprint
  location:    "http://example.com/"
  name:        "API"
  description: "Test API"
  sections:    filledSections

# JSONs

filledRequestJson =
  headers: { "Content-Type": "application/json" }
  body:    "{ \"status\": \"ok\" }"

filledResponseJsons = [
  {
    status:  200
    headers: { "Content-Type": "application/json" }
    body:    "{ \"id\": 1 }"
  }
  {
    status:  200
    headers: { "Content-Type": "application/json" }
    body:    "{ \"id\": 2 }"
  }
  {
    status:  200
    headers: { "Content-Type": "application/json" }
    body:    "{ \"id\": 3 }"
  }
]

filledResourceJsons = [
  {
    description: "Post resource 1"
    method:      "POST"
    url:         "/post-1"
    request:     filledRequestJson
    responses:   filledResponseJsons
  }
  {
    description: "Post resource 2"
    method:      "POST"
    url:         "/post-2"
    request:     filledRequestJson
    responses:   filledResponseJsons
  }
  {
    description: "Post resource 3"
    method:      "POST"
    url:         "/post-3"
    request:     filledRequestJson
    responses:   filledResponseJsons
  }
]

filledSectionJsons = [
  {
    name:        "Section 1"
    description: "Test section 1"
    resources:    filledResourceJsons
  }
  {
    name:        "Section 2"
    description: "Test section 2"
    resources:    filledResourceJsons
  }
  {
    name:        "Section 3"
    description: "Test section 3"
    resources:    filledResourceJsons
  }
]

filledBlueprintJson =
  location:    "http://example.com/"
  name:        "API"
  description: "Test API"
  sections:    filledSectionJsons

# Blueprints

filledRequestBlueprint = """
  > Content-Type: application/json
  { "status": "ok" }
"""

filledResponseBlueprints = [
  """
    < 200
    < Content-Type: application/json
    { "id": 1 }
  """
  """
    < 200
    < Content-Type: application/json
    { "id": 2 }
  """
  """
    < 200
    < Content-Type: application/json
    { "id": 3 }
  """
]

filledResourceBlueprints = [
  """
    Post resource 1
    POST /post-1
    #{filledRequestBlueprint}
    #{filledResponseBlueprints[0]}
    +++++
    #{filledResponseBlueprints[1]}
    +++++
    #{filledResponseBlueprints[2]}
  """
  """
    Post resource 2
    POST /post-2
    #{filledRequestBlueprint}
    #{filledResponseBlueprints[0]}
    +++++
    #{filledResponseBlueprints[1]}
    +++++
    #{filledResponseBlueprints[2]}
  """
  """
    Post resource 3
    POST /post-3
    #{filledRequestBlueprint}
    #{filledResponseBlueprints[0]}
    +++++
    #{filledResponseBlueprints[1]}
    +++++
    #{filledResponseBlueprints[2]}
  """
]

filledSectionBlueprints = [
  """
    --
    Section 1
    Test section 1
    --

    #{filledResourceBlueprints[0]}

    #{filledResourceBlueprints[1]}

    #{filledResourceBlueprints[2]}
  """
  """
    --
    Section 2
    Test section 2
    --

    #{filledResourceBlueprints[0]}

    #{filledResourceBlueprints[1]}

    #{filledResourceBlueprints[2]}
  """
  """
    --
    Section 3
    Test section 3
    --

    #{filledResourceBlueprints[0]}

    #{filledResourceBlueprints[1]}

    #{filledResourceBlueprints[2]}
  """
]

filledBlueprintBlueprint = """
  HOST: http://example.com/

  --- API ---

  ---
  Test API
  ---

  #{filledSectionBlueprints[0]}

  #{filledSectionBlueprints[1]}

  #{filledSectionBlueprints[2]}
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

        assert.deepEqual blueprint.location,    "http://example.com/"
        assert.deepEqual blueprint.name,        "API"
        assert.deepEqual blueprint.description, "Test API"
        assert.deepEqual blueprint.sections,    filledSections

    describe "when not passed property values", ->
      it "uses correct defaults", ->
        assert.deepEqual emptyBlueprint.location,    null
        assert.deepEqual emptyBlueprint.name,        null
        assert.deepEqual emptyBlueprint.description, null
        assert.deepEqual emptyBlueprint.sections,    []

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

describe "Section", ->
  emptySection = new Section

  describe ".fromJSON", ->
    it "creates a new section from a JSON-serializable object", ->
      assert.deepEqual Section.fromJSON(filledSectionJsons[0]), filledSections[0]

  describe "#constructor", ->
    describe "when passed property values", ->
      it "initializes properties correctly", ->
        section = filledSections[0]

        assert.deepEqual section.name,        "Section 1"
        assert.deepEqual section.description, "Test section 1"
        assert.deepEqual section.resources,   filledResources

    describe "when not passed property values", ->
      it "uses correct defaults", ->
        assert.deepEqual emptySection.name,        null
        assert.deepEqual emptySection.description, null
        assert.deepEqual emptySection.resources,   []

  describe "#toJSON", ->
    describe "on a filled-in section", ->
      it "returns a correct JSON-serializable object", ->
        assert.deepEqual filledSections[0].toJSON(), filledSectionJsons[0]

  describe "#toBlueprint", ->
    describe "on an empty section", ->
      it "returns a correct blueprint", ->
        assert.deepEqual emptySection.toBlueprint(), ""

    describe "on a section with a name but with no description", ->
      it "returns a correct blueprint", ->
        section = new Section name: "Section 1"

        assert.deepEqual section.toBlueprint(), "-- Section 1 --"

    describe "on a section with no name but with a description", ->
      it "returns a correct blueprint", ->
        section = new Section description: "Test section 1"

        assert.deepEqual section.toBlueprint(), ""

    describe "on a filled-in section", ->
      it "returns a correct blueprint", ->
        assert.deepEqual filledSections[0].toBlueprint(), filledSectionBlueprints[0]

describe "Resource", ->
  emptyResource = new Resource

  describe ".fromJSON", ->
    it "creates a new resource from a JSON-serializable object", ->
      assert.deepEqual Resource.fromJSON(filledResourceJsons[0]), filledResources[0]

  describe "#constructor", ->
    describe "when passed property values", ->
      it "initializes properties correctly", ->
        resource = filledResources[0]

        assert.deepEqual resource.description, "Post resource 1"
        assert.deepEqual resource.method,      "POST"
        assert.deepEqual resource.url,         "/post-1"
        assert.deepEqual resource.request,     filledRequest
        assert.deepEqual resource.responses,   filledResponses

    describe "when not passed property values", ->
      it "uses correct defaults", ->
        assert.deepEqual emptyResource.description, null
        assert.deepEqual emptyResource.method,      "GET"
        assert.deepEqual emptyResource.url,         "/"
        assert.deepEqual emptyResource.request,     new Request
        assert.deepEqual emptyResource.responses,   [new Response]

  describe "#toJSON", ->
    describe "on a filled-in resource", ->
      it "returns a correct JSON-serializable object", ->
        assert.deepEqual filledResources[0].toJSON(), filledResourceJsons[0]

  describe "#toBlueprint", ->
    describe "on an empty resource", ->
      it "returns a correct blueprint", ->
        assert.deepEqual emptyResource.toBlueprint(), "GET /\n< 200"

    describe "on a filled-in resource", ->
      it "returns a correct blueprint", ->
        assert.deepEqual filledResources[0].toBlueprint(), filledResourceBlueprints[0]

describe "Request", ->
  emptyRequest = new Request

  describe ".fromJSON", ->
    it "creates a new request from a JSON-serializable object", ->
      assert.deepEqual Request.fromJSON(filledRequestJson), filledRequest

  describe "#constructor", ->
    describe "when passed property values", ->
      it "initializes properties correctly", ->
        assert.deepEqual filledRequest.headers, { "Content-Type": "application/json" }
        assert.deepEqual filledRequest.body,    "{ \"status\": \"ok\" }"

    describe "when not passed property values", ->
      it "uses correct defaults", ->
        assert.deepEqual emptyRequest.headers, {}
        assert.deepEqual emptyRequest.body,    null

  describe "#toJSON", ->
    describe "on a filled-in request", ->
      it "returns a correct JSON-serializable object", ->
        assert.deepEqual filledRequest.toJSON(), filledRequestJson

  describe "#toBlueprint", ->
    describe "on an empty request", ->
      it "returns a correct blueprint", ->
        assert.deepEqual emptyRequest.toBlueprint(), ""

    describe "on a filled-in request", ->
      it "returns a correct blueprint", ->
        assert.deepEqual filledRequest.toBlueprint(), filledRequestBlueprint

    describe "on requests with weird bodies", ->
      it "uses suitable body syntax", ->
        for testcase in bodyTestcases
          request = new Request body: testcase.body

          assert.deepEqual request.toBlueprint(), testcase.blueprint

describe "Response", ->
  emptyResponse = new Response

  describe ".fromJSON", ->
    it "creates a new response from a JSON-serializable object", ->
      assert.deepEqual Response.fromJSON(filledResponseJsons[0]), filledResponses[0]

  describe "#constructor", ->
    describe "when passed property values", ->
      it "initializes properties correctly", ->
        response = filledResponses[0]

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
        assert.deepEqual filledResponses[0].toJSON(), filledResponseJsons[0]

  describe "#toBlueprint", ->
    describe "on an empty response", ->
      it "returns a correct blueprint", ->
        assert.deepEqual emptyResponse.toBlueprint(), "< 200"

    describe "on a filled-in response", ->
      it "returns a correct blueprint", ->
        assert.deepEqual filledResponses[0].toBlueprint(), filledResponseBlueprints[0]

    describe "on responses with weird bodies", ->
      it "uses suitable body syntax", ->
        for testcase in bodyTestcases
          response = new Response body: testcase.body

          assert.deepEqual response.toBlueprint(), "< 200\n#{testcase.blueprint}"
