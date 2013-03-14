fillProps = (object, props, defaults) ->
  for key of defaults
    object[key] = props[key] or defaults[key]

combineParts = (separator, builder) ->
  parts = []
  builder(parts)
  parts.join(separator)

escapeBody = (body) ->
  if /^>\s+|^<\s+|^\s*$/m.test(body)
    if /^>>>\s*$/m.test(body)
      if /^EOT$/m.test(body)
        i = 1
        while /^EOT#{i}$/m.test(body)
          i++
        "<<<EOT#{i}\n#{body}\nEOT#{i}"
      else
        "<<<EOT\n#{body}\nEOT"
    else
      "<<<\n#{body}\n>>>"
  else
    body

# Represents a KATT API blueprint.
class Blueprint
  @fromJSON: (json) ->
    new this
      name:         json.name
      description:  json.description
      operations:   Operation.fromJSON(s) for s in json.operations

  constructor: (props = {}) ->
    fillProps this, props,
      name:         null
      description:  null
      operations:   []

  toJSON: ->
    name:        @name
    description: @description
    operations:  o.toJSON() for o in @operations

  toBlueprint: ->
    combineParts "\n\n", (parts) =>
      parts.push "--- #{@name} ---"          if @name
      parts.push "---\n#{@description}\n---" if @description

      parts.push o.toBlueprint() for o in @operations

# Represents an operation of a KATT API blueprint scenario.
class Operation
  @fromJSON: (json) ->
    new this
      description: json.description
      request:     Request.fromJSON(json.request)
      response:    Response.fromJSON(json.response)

  constructor: (props = {}) ->
    fillProps this, props,
      description: null
      request:     new Request
      response:    new Response

  toJSON: ->
    description: @description
    request:     @request.toJSON()
    response:    @response.toJSON()

  toBlueprint: ->
    combineParts "\n", (parts) =>
      parts.push @description if @description

      requestBlueprint = @request.toBlueprint()
      parts.push requestBlueprint if requestBlueprint isnt ""

      responseBlueprint =  @response.toBlueprint()
      parts.push responseBlueprint if responseBlueprint isnt ""

# Represents a request of an operation.
class Request
  @fromJSON: (json) ->
    new this
      method:  json.method
      url:     json.url
      headers: json.headers
      body:    json.body

  constructor: (props = {}) ->
    fillProps this, props,
      method:  "GET"
      url:     "/"
      headers: {},
      body:    null

  toJSON: ->
    method:  @method
    url:     @url
    headers: @headers
    body:    @body

  toBlueprint: ->
    combineParts "\n", (parts) =>
      parts.push "#{@method} #{@url}"
      parts.push "> #{name}: #{value}" for name, value of @headers
      parts.push escapeBody(@body) if @body

# Represents a response of an operation.
class Response
  @fromJSON: (json) ->
    new this
      status:  json.status
      headers: json.headers
      body:    json.body

  constructor: (props = {}) ->
    fillProps this, props,
      status:  200,
      headers: {},
      body:    null

  toJSON: ->
    status:  @status
    headers: @headers
    body:    @body

  toBlueprint: ->
    combineParts "\n", (parts) =>
      parts.push "< #{@status}"
      parts.push "< #{name}: #{value}" for name, value of @headers
      parts.push escapeBody(@body) if @body

module.exports =
  Blueprint:            Blueprint
  Operation:            Operation
  Request:              Request
  Response:             Response
