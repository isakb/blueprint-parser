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
      location:     json.location
      name:         json.name
      description:  json.description
      interactions: Interaction.fromJSON(s) for s in json.interactions

  constructor: (props = {}) ->
    fillProps this, props,
      location:     null
      name:         null
      description:  null
      interactions: []

  interactions: (opts) ->
    for i in s.interactions
      if opts?.method and opts.method isnt i.method then continue
      if opts?.url and opts.url isnt i.url then continue
      i

  toJSON: ->
    location:     @location
    name:         @name
    description:  @description
    interactions: i.toJSON() for i in @interactions

  toBlueprint: ->
    combineParts "\n\n", (parts) =>
      parts.push "HOST: #{@location}"        if @location
      parts.push "--- #{@name} ---"          if @name
      parts.push "---\n#{@description}\n---" if @description

      parts.push s.toBlueprint() for s in @interactions

# Represents an interaction of a KATT API blueprint scenario.
class Interaction
  @fromJSON: (json) ->
    new this
      description: json.description
      method:      json.method
      url:         json.url
      request:     Request.fromJSON(json.request)
      response:    Response.fromJSON(json.response)

  constructor: (props = {}) ->
    fillProps this, props,
      description: null
      method:      "GET"
      url:         "/"
      request:     new Request
      response:    new Response

  getUrlFragment: -> "#{@method.toLowerCase()}-#{encodeURIComponent @url}"

  toJSON: ->
    description: @description
    method:      @method
    url:         @url
    request:     @request.toJSON()
    response:    @response.toJSON()

  toBlueprint: ->
    combineParts "\n", (parts) =>
      parts.push @description if @description
      parts.push "#{@method} #{@url}"

      requestBlueprint = @request.toBlueprint()
      parts.push requestBlueprint if requestBlueprint isnt ""

      responseBlueprint =  @response.toBlueprint()
      parts.push responseBlueprint if responseBlueprint isnt ""

# Represents a request of an interaction.
class Request
  @fromJSON: (json) ->
    new this
      headers: json.headers
      body:    json.body

  constructor: (props = {}) ->
    fillProps this, props,
      headers: {},
      body:    null

  toJSON: ->
    headers: @headers
    body:    @body

  toBlueprint: ->
    combineParts "\n", (parts) =>
      parts.push "> #{name}: #{value}" for name, value of @headers
      parts.push escapeBody(@body) if @body

# Represents a response of an interaction.
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
  Interaction:          Interaction
  Request:              Request
  Response:             Response
