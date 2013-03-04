{
  /*
   * Converts headers from format like this:
   *
   *   [
   *     { name: "Content-Type",   value: "application/json" },
   *     { name: "Content-Length", value: "153"              }
   *   ]
   *
   * into format like this:
   *
   *   {
   *     "Content-Type":   "application/json",
   *     "Content-Length": "153"
   *   }
   */
  function convertHeaders(headers) {
    var result = {}, i;

    for (i = 0; i < headers.length; i++) {
      result[headers[i].name] = headers[i].value;
    }

    return result;
  }

  function nullIfEmpty(s) {
    return s !== "" ? s : null;
  }

  function combineHeadTail(head, tail) {
    if (head !== "") {
      tail.unshift(head);
    }

    return tail;
  }

  /*
   * We must save these because |this| doesn't refer to the parser in actions.
   */
  var Blueprint            = this.ast.Blueprint,
      Interaction          = this.ast.Interaction,
      Request              = this.ast.Request,
      Response             = this.ast.Response;

  var urlPrefix = "", bodyTerminator;
}

/* ===== Primary Rules ===== */

API
  = EmptyLine*
    name:APIName
    EmptyLine*
    description:APIDescription?
    EmptyLine*
    interactions:Interactions
    EmptyLine*
    {
      return new Blueprint({
        name:         nullIfEmpty(name),
        description:  nullIfEmpty(description),
        interactions: interactions
      });
    }

APIName
  = "---" S+ name:Text1 EOLF {
      return name.replace(/\s+---$/, "");
    }

APIDescription
  = "---" S* EOL lines:APIDescriptionLine* "---" S* EOLF {
    return lines.join("\n");
  }

APIDescriptionLine
  = !("---" S* EOLF) text:Text0 EOL { return text; }

Interactions
  = head:Interaction?
    tail:(EmptyLine* interaction:Interaction { return interaction; })*
    {
      return combineHeadTail(head, tail);
    }

Interaction
  = description:InteractionDescription?
    signature:Signature
    request:Request
    response:Response
    {
      var url = urlPrefix !== ""
        ? "/" + urlPrefix.replace(/\/$/, "") + "/" + signature.url.replace(/^\//, "")
        : signature.url;

      return new Interaction({
        description: nullIfEmpty(description),
        method:      signature.method,
        url:         url,
        request:     request,
        response:    response
      });
    }

InteractionDescription "interaction description"
  = lines:InteractionDescriptionLine+ { return lines.join("\n"); }

InteractionDescriptionLine
  = !HttpMethod text:Text0 EOL { return text; }

/* Assembled from RFC 2616, 5323, 5789. */
HttpMethod
  = "GET"
  / "POST"
  / "PUT"
  / "DELETE"
  / "OPTIONS"
  / "PATCH"
  / "PROPPATCH"
  / "LOCK"
  / "UNLOCK"
  / "COPY"
  / "MOVE"
  / "DELETE"
  / "MKCOL"

Request
  = headers:RequestHeaders body:Body? {
      return new Request({
        headers: headers,
        body:    nullIfEmpty(body)
      });
    }

RequestHeaders
  = headers:RequestHeader* { return convertHeaders(headers); }

RequestHeader
  = In header:HttpHeader { return header; }

Response
  = status:ResponseStatus headers:ResponseHeaders body:Body? {
      return new Response({
        status:  status,
        headers: headers,
        body:    nullIfEmpty(body)
      });
    }

ResponseStatus
  = Out status:HttpStatus S* EOLF { return status; }

ResponseHeaders
  = headers:ResponseHeader* { return convertHeaders(headers); }

ResponseHeader
  = Out header:HttpHeader { return header; }

HttpStatus "HTTP status code"
  = digits:[0-9]+ { return parseInt(digits.join(""), 10); }

HttpHeader
  = name:HttpHeaderName ":" S* value:HttpHeaderValue EOLF {
      return {
        name:  name,
        value: value
      };
    }

/*
 * See RFC 822, 3.1.2: "The field-name must be composed of printable ASCII
 * characters (i.e., characters that have values between 33. and 126., decimal,
 * except colon)."
 */
HttpHeaderName "HTTP header name"
  = chars:[\x21-\x39\x3B-\x7E]+ { return chars.join(""); }

HttpHeaderValue "HTTP header value"
  = Text0

Signature
  = method:HttpMethod S+ url:Text1 EOL {
      return {
        method: method,
        url:    url
      };
    }

Body
  = DelimitedBodyFixed
  / DelimitedBodyVariable
  / SimpleBody

DelimitedBodyFixed
  = "<<<" S* EOL
    lines:DelimitedBodyFixedLine*
    ">>>" S* EOLF
    {
      return lines.join("\n");
    }

DelimitedBodyFixedLine
  = !(">>>" S* EOLF) text:Text0 EOL { return text; }

DelimitedBodyVariable
  = "<<<" terminator:Text1 EOL
    &{ bodyTerminator = terminator; return true; }
    lines:DelimitedBodyVariableLine*
    DelimitedBodyVariableTerminator
    {
      return lines.join("\n");
    }

DelimitedBodyVariableLine
  = !DelimitedBodyVariableTerminator text:Text0 EOL { return text; }

DelimitedBodyVariableTerminator
  = terminator:Text1 EOLF &{ return terminator === bodyTerminator }

SimpleBody
  = !"<<<" lines:SimpleBodyLine+ { return lines.join("\n"); }

SimpleBodyLine
  = !In !Out !EmptyLine text:Text1 EOLF { return text; }

In
  = ">" S+

Out
  = "<" S+

/* ===== Helper Rules ===== */

Text0 "zero or more characters"
  = chars:[^\n\r]* { return chars.join(""); }

Text1 "one or more characters"
  = chars:[^\n\r]+ { return chars.join(""); }

EmptyLine "empty line"
  = S* EOL

EOLF "end of line or file"
  = EOL / EOF

EOL "end of line"
  = "\n"
  / "\r\n"
  / "\r"

EOF "end of file"
  = !. { return ""; }

/*
 * What "\s" matches in JavaScript regexps, sans "\r", "\n", "\u2028" and
 * "\u2029". See ECMA-262, 5.1 ed., 15.10.2.12.
 */
S "whitespace"
  = [\t\v\f \u00A0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000\uFEFF]
