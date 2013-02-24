Author: z@apiary.io

# API Blueprint Language Specification

## Revision 1A

---

## Contents
1. [Introduction][Introduction]
2. [API Blueprint Language][Language]
3. [API Blueprint Document][Document]
	1. [Sections][Sections]
	2. [Reserved Section Names][ReservedSectionNames]
	3. [Nested sections][NestedSections] 
	4. [Other Markdown headers][OtherMarkdownHeaders]
	5. [Special Sections][SpecialSections]
4. [API Blueprint Document Structure][DocumentStructure]
	1. [Metadata Section][MetadataSection]
	2. [API Name & Overview Section][APINameOverviewSection]
	3. [Endpoint Section][EndpointSection]
		1. [Parameters Section][EndpointParametersSection]
		2. [Method Section][MethodSection]
		3. [Request Section][EndpointRequestSection]
		4. [Response Section][EndpointResponseSection]
		5. [Headers Section][HeadersSection]
	4. [Grouping endpoints][EndpointGroups]
5. [Payloads][Payloads]
	1. [Headers Section][PayloadHeadersSection]
	2. [Body Section][PayloadBodySection]
	3. [Schema Section][PayloadSchemaSection]
6. [Assets][DocumentAssets]
	1. [Inline Asset][InlineDocumentAsset]
---

## 1. Introduction [Introduction]
This documents is full specification of [Apiary.io](http://apiary.io)'s API Blueprint Language. API Blueprint Language is a domain-specific language in which you can describe any modern [REST](http://www.restapitutorial.com) or [Hypermedia]() API.

The language is written for the **convenience of business users**, not only back-end developers.
While the language is simple enough to be used by anybody with the elementary programming skills it is recommended to go through [Tutorial](http://apiary.io/blueprint) first before continuing with the full specification.

Also note that it is not in scope of this document to discuss any of the Apiary.io tools such as [Mock Server](http://apiary.io) or [Proxy](http://apiary.io) although some of it may be mentioned in this document.

---

## 2. API Blueprint Language [Language]
API Blueprint Language is essentially a superset of John Gruber's [Markdown](http://daringfireball.net/projects/markdown). It inherits few major [MultiMarkdown](http://fletcherpenney.net/multimarkdown) features extending Markdown's referencing and MultiMarkdown's cross-referencing. 

The language is not Turing-complete but it has a limited branching support

Before you will proceed with this document please make yourself familiar with the basic [Markdown Syntax](http://daringfireball.net/projects/markdown/syntax) as well as with the Metadata and Automatic Cross-References sections of [MultiMarkdown Syntax](https://github.com/fletcher/MultiMarkdown/blob/master/Documentation/MultiMarkdown%20User%27s%20Guide.md#multimarkdown-syntax-guide).

---

## 3. API Blueprint Document [Document]
API Blueprint Document is the façade of your API. This is where you describe, explain and define the interface.

The document itself is divided into several logical sections forming **API Blueprint Document Structure**.

### 3.1. Sections [Sections]
A section represents a logical unit of your API Blueprint. For example an API overview, resource definition or an endpoint discussion.

Section are recognized by a **reserved section name** or an **URI template** in **Markdown header**. Only **atx-style** headers  (e.g. `# Header`) are considered.

Each sections has strictly defined name, meaning and content. Anything between a Section Markdown header and another such a header at the same level is considered to be a section. This implies you **must avoid** using reserved section names in other Markdown headers.

### 3.2. Reserved Section Names [ReservedSectionNames]
Reserved sections names are listed in [API Blueprint Document Structure](DocumentStructure). Note that some section names can contain variable components such as identifiers or modifiers. See relevant section's entry to find out more about how section name is built.

Currently reserved keywords are:

* Request
* Response
* Headers
* Body
* Schema
* \+ HTTP Methods
* \+ URIs

### 3.3. Nested sections [NestedSections]
Sections can be nested. To nest a section in another section simply **increase** its atx-style **header level**. 

Example:

	# Section A
	... Section A content ...
	
	## Nested Section of Section A
	... Nested Section content ...
	
	# Section B
	... Section B content...
	
What section can be nested and where depends on the actual section as described in relevant [API Blueprint Document Structure](DocumentStructure) section's entry.

### 3.4. Other Markdown headers [OtherMarkdownHeaders]
You are free to use any Markdown header of your liking anywhere as long as it does not clash with [Reserved Section Names](ReservedSectionNames). It is considered a good practice to keep your own header level nested to your actual section.
	
### 3.5. Special Sections [SpecialSections]
There are **two additional** sections of a Blueprint Document to sections represented by a [Reserved Name Sections][Sections]: A [Metadata Section][MetadataSection] and the [API Name & Overview][APINameOverviewSection]. These will be discussed in the [API Blueprint Document Structure][DocumentStructure]

---

## 4. API Blueprint Document Structure [DocumentStructure]
Bellow you will find description of every section of the API Blueprint Document. Note that all sections but [API Name & Overview][APINameOverviewSection] section are optional. That is your API Blueprint Document **must** contain at least the API Name. However the document should contain one or more [Endpoint][EndpointSection] Section.

An example of a possible API Blueprint Document layout:

	Metadata: ...
	
	# API Name
	...
	# Group 1
	...
	## Endpoint 1.1
	...
	### Parameters
	...
	### Request
	...
	### Response
	...
	## Endpoint 1.2
	...
	### Response
	...
	# Group 2
	...
	## Endpoint 2.1
	...	

### 4.1. Metadata Section [MetadataSection]
**Optional**. Section containing API metadata.

This section is **recognized** as [MultiMarkdown' Metadata](https://github.com/fletcher/MultiMarkdown/blob/master/Documentation/MultiMarkdown%20User%27s%20Guide.md#metadata). It starts from the beginning of the document and ends with a first Markdown header.

**TODO: Specify available metadata.**

Example:
	
	HOST: http://blog.acme.com
	Format: 1A

### 4.2. API Name & Overview Section [APINameOverviewSection]
**Required**. Name of the API in the form of a Markdown header.

This section is **recognized** as the **first** Markdown header in your document its name is considered to be your **API name**. 

This section can contain **further Markdown-formatted content**. If a content is provided it is considered to represent the API Overview.

Example:

	# My API Name
	
	-- or -- 

	# Basic ACME Blog API
	Welcome to the **ACME Blog** API. This API provides access to the **ACME Blog** service.


### 4.3. Endpoint Section [EndpointSection]
**Optional**. Definition of exactly *one* API endpoint. 

This section is **recognized** by an [RFC 6570 URI template](http://tools.ietf.org/html/rfc6570) written in an atx-style Markdown header. Optionally the header can contain one leading [HTTP Request Method](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods). 

This section can contain **further Markdown-formatted content**. If a content is provided it is considered to represent the endpoint's description.

Example:

	# PUT /posts

	-- or -- 
		
	# GET /posts{/id}
	
	-- or -- 
		
	# /posts
	
This section may include nested [Headers Section][HeadersSection].

#### 4.3.1. Parameters Section [EndpointParametersSection]
**Optional**. Description of [Endpoint Section][EndpointSection]'s URI parameters. Content of this section is subject to additional formatting. 

This section is **recognized** by the **"Parameters"** reserved **keyword** written in an atx-style Markdown header. This section must be nested under an [Endpoint Section][EndpointSection].

This section can contain **further Markdown-formatted content**. If a content is provided it is considered to represent general endpoint's parameter description. The rest of this section is formatted per URI parameter as follows:

	@<parameter name> [= <default value>] [(<type>)] ... Markdown-formatted content
	
Where:

* `<parameter name>` is a parameter name as written in [Endpoint Section][EndpointSection]'s URI (e.g. "id").
* `<default value>` is **optional** parameter default or example value (e.g. 1234).
* `<type>` is **optional** parameter type as expected by your API (e.g. "number").

Example:

	# GET /posts{/id}
	## Parameters
	@id ... Id of a post.
	
	-- or -- 
	
	@id = 1234 ... Id of a post.
	
	-- or -- 
	
	@id (number) ... Id of a post.
	
	-- or --
	
	@id = 1234 (number) ... Id of a post.

#### 4.3.2. Method Section [MethodSection]
**Required** if there is no HTTP method specified in [Endpoint Section][EndpointSection]'s header. **Illegal** otherwise. [HTTP Request Method](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods) available on this endpoint.

This section is **recognized** by one of the [HTTP Request Methods](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods) written in capitals as an atx-style Markdown header. This section must be nested under an [Endpoint Section][EndpointSection].

This section can contain **further Markdown-formatted content**. If a content is provided it is considered to represent this endpoint method description.

One [Endpoint Section][EndpointSection] can contain **one or more** different Method Sections.

Example:

	# /posts{/id}
	## Prameters
	...
	
	## GET 
	Retrieves a **ACME Blog** posts.
	...
	
	## PUT
	...
	
	
If provided, the relevant [Request][EndpointRequestSection] and [Response][EndpointResponseSection] sections must be nested under this section.

This section may include nested [Headers Section][HeadersSection].

#### 4.3.3. Request Section [EndpointRequestSection]
**Optional**. Description of exactly *one* HTTP request including expected HTTP body.

This section is **recognized** by the **"Request"** reserved **keyword** written in an atx-style Markdown header. The **"Request"** can be preceded by an arbitrary string representing user identifier of this request. In case HTTP body is specified the **"Request"** keyword should be followed by HTTP Body [Media Type (MIME type)](http://en.wikipedia.org/wiki/Internet_media_type).

Full Request section header syntax is as follows:

	# [<identifier>] Request [(<Media Type>)]

This section **must** be nested under a [Method Section][MethodSection] unless a HTTP method is specified in the [Endpoint Sections][EndpointSection]'s header. In that case this section must be nested under the [Endpoint Section][EndpointSection].

The content of this section is a [Payload][Payloads] carried by this request. See [Payloads Documentation][Payloads] for details on how to specify the content of this request.

If a Media Type is specified in this sections' header it is also expected as a `Content-Type` header of this request.

One [Endpoint Section][EndpointSection] or [Method Section][MethodSection] can contain **one or more different** Request Sections.

Example:

	# Request (text/plain)
		Hello World
		
	-- or --
	
	# Create Blog Post Request (application/json)
	    { "message" : "Hello World." }
	 
#### 4.3.4. Response Section [EndpointResponseSection]
**Required**. Description of exactly *one* HTTP response including expected HTTP body and HTTP status code.

This section is **recognized** by the **"Response"** reserved **keyword** written in an atx-style Markdown header followed by a [HTTP Status code](http://www.restapitutorial.com/httpstatuscodes.html). In case HTTP body is specified the **"Response"** keyword should be followed by HTTP Body [Media Type (MIME type)](http://en.wikipedia.org/wiki/Internet_media_type).

Full Response section header syntax is as follows:

	# Response <Status Code> [(<Media Type>)]

This section **must** be nested under a [Method Section][MethodSection] unless a HTTP method is specified in the [Endpoint Sections][EndpointSection]'s header. In that case this section must be nested under the [Endpoint Section][EndpointSection].

The content of this section is a [Payload][Payloads] carried by this response. See [Payload Documentation][Payloads] for details on how to specify the content of this response.

If a Media Type is specified in this sections' header it is also send as a `Content-Type` header of this response.

One [Endpoint Section][EndpointSection] or [Method Section][MethodSection] can contain **one or more different** Response Sections.

Example: 
	
	# Response 201 (application/json)
		{ "message" : "created" }

#### 4.3.5. Headers Section [HeadersSection]
**Optional**. Description HTTP Headers parameters. Content of this section is subject to additional formatting. 

This section is **recognized** by the **"Headers"** reserved **keyword** written in an atx-style Markdown header. Optionally the **"Headers"** keyword can be preceded by either response or request header keyword syntax excluding media type.

Full Header section header syntax is as follows:

	# [[<identifier>] Request | Response <status code>] Headers

This section must be nested under one of the following sections: 

* [Endpoint Section][EndpointSection]
* [Method Section][MethodSection]

Based on where is this sections is nested the headers are expected or send as follows:

* **Endpoint Section**: Headers are expected and/or send with **every** request and/or response on this endpoint.
* **Method Section**: Headers are expected and/or send with **every** request and/or response with specific method and endpoint.

Based on keywords preceding the **"Headers"** keyword the headers are expected or send as follows:

* **Request** keyword: Headers are expected only for specified request.
* **Response** keyword: Headers are send only for specified response.

The section is formatted as an Markdown's [Pre-formatted code blocks](http://daringfireball.net/projects/markdown/syntax#precode) with following syntax:

	<HTTP header name>: <value>
	
One HTTP header per line.
	
Example:

	# Headers
	    Accept-Charset: utf-8
	    Connection: keep-alive
	    
	# Request Headers
	    Accept-Charset: utf-8
	    Connection: keep-alive
	 
	# Response 201 Headers
		 X-ACME-API-Version: 42
	

### 4.4. Grouping endpoints [EndpointGroups]
Endpoint sections can be grouped together for example by a common task such as handling payments, shopping cart manipulation, blog post management or user management.

To group endpoints simply [nest][NestedSections] your endpoint section(s) under an atx-style Markdown header of the group's name. 

This section can contain **further Markdown-formatted content**. If a content is provided it is considered to represent group description.

Example:

	# Blog Posts
	Endpoints in this groups manipulates **ACME Blog** posts.
	
	## GET /posts{/id}
		...
		
	## PUT /posts
		...
		
	# Authors
	## GET /authors
		...
		
	# Comments
		...
		
---

## 5. Payloads [Payloads]
An payload is essentially data expected in a HTTP request or send in a HTTP response. Payload consists of meta information in form of HTTP headers and content received or send in a HTTP body.

Note that a payload in the sense used in this document is a subset of [HTTP Payload](http://www.w3.org/TR/di-gloss/) as there might be additional metadata (HTTP headers) specified outside of the scope of the payload that will form up the final complete HTTP Payload.

A Payload has **always** its Media Type associated. Payload's Media type represents a metadata that is always received or send in form of an HTTP `Content-Type` header.

Payload section header syntax is follows:

	# <Payload Identifier> (<Media Type>)
	
Content of a payload is formed from up to three *nested* sections: **Headers** Section, **Body** Section and **Schema** section.

If **no section** is specified content of the payload section is treated as [PayloadBodySection][PayloadBodySection].

Example: 

	# MyPayload (application/json)
	## Headers
		X-My-Payload-Size: 42
		
	## Body
		{ ... }
		
	## Schema
		{ ... }
		

### 5.1. Headers Section [PayloadHeadersSection]
**Optional**. Specifies the metadata in form of HTTP headers to be received or send with the payload.

This section is **recognized** by the **"Headers"** reserved **keyword** written in an atx-style Markdown header. No further keywords or modifiers are expected.

See to [Endpoint's Headers Section][HeadersSection] for this section's syntax definition. 

### 5.2. Body Section [PayloadBodySection]
**Required**. Specifies content of the payload received or send in the form of HTTP body.

This section is **recognized** by the **"Body"** reserved **keyword** written in an atx-style Markdown header.

This section represents an API Blueprint Document [Asset][DocumentAssets].

Prior to an [asset][DocumentAssets] content this section can contain **further Markdown-formatted content**. If a content is provided it is considered to represent assets's description.

Additionally For **application/json** media types the section can also contain asset's field description as follows:

	@.<parameter name> [= <default value>] [(<type>)] ... Markdown-formatted content
	
See Endpoint's [Parameters Section][EndpointParametersSection] for further details.

Example: 

	# MyPayload (application/json)
	## Headers
		X-My-Payload-Size: 42
		
	## Body
	@.message (string) ... A message from **ACME Blog** API.
	
		{ "message" : "Hello World." }


### 5.3. Schema Section [PayloadSchemaSection]
**Optional**. Where applicable specifies a schema used to validate this payload's body content.

This section is **recognized** by the **"Schema"** reserved **keyword** written in an atx-style Markdown header.

This section represents an API Blueprint Document [Asset][DocumentAssets].

---

## 6. Assets [DocumentAssets]
An API Blueprint Document Asset is simply a resource (not to be confused with API Resource) – a piece data used in [payloads][Payloads].

### 6.1. Inline Asset [InlineDocumentAsset]
In its simplest form an asset is essentially a Markdown's [Pre-formatted code blocks](http://daringfireball.net/projects/markdown/syntax#precode). The sole content of this block is considered to represent the Asset's data. 

Example: 

	# Asset Name
		{ "message" : "Hello World." }

---