Format: 1A
Host: http://blog.acme.com

# Basic ACME Blog API
Welcome to the **ACME Blog** API. This API provides access to the **ACME Blog** service.

# GET /posts{/id}
Retrieves **ACME Blog** posts. 

## Parameters
+ id = 1234 (number) ... Id of a post to retrieve. If there is no id specified all **ACME Blog** posts are returned.

## Response Header
	X-ACME-API-Ver: 1

## Response 200 (application/json)
Array of **ACME Blog** posts. Might contain just one item if there is a valid @id specified. Null if there are no posts.

+ author (string) ... Name of **ACME Blog** author.  
+ title (string) ... Title of the blog post.  
+ body (string) ... Blog post body.

	[
		{
		    "_id" : "1234",
		    "author" : "Jakub Nesetril",
		    "body" : "This is a blog entry",
		    "title" : "This is a blog post title",		    
		    "comments" : [
		    	{
		            "body" : "This is my comment",
		            "author" : "Jakub Nesetril"
		        },
		        {
		            "body" : "Give me liberty or give me death.",
		            "author" : "Jan Moravec"
		        }
		    ],
		    "date" : "2012-11-10T06:42:55.733Z"
		}
	]


# PUT /posts
Creates a new **ACME Blog** posts. Post can be created either as a copy of an existing post or as a completely new post submitting its body, title and author.

## Duplicate Request (application/json)
+ source_id (number) ... Id of an existing post to be duplicated.

	{ source_id : 1234 }

## New Post Request (application/json)
	{
	    "author" : "Jakub Nesetril",
	    "body" : "This is a blog entry",
	    "title" : "This is a blog post title"
	}

## Response Header
	X-ACME-API-Ver: 1

## Response 201 (application/json)
	{ "message" : "created" }


# /posts/{id}/comments
Comments for **ACME Blog** post of a given @id. 

## Parameters
+ id = 1234 (number) ... Id of a **ACME Blog** post.

## GET
Retrieves all comments for the given post.

### Response 200 (application/json)
Returns an array of post comments. 

	[	
		{
			"body" : "This is my comment",
			"author" : "Jakub Nesetril"
		},
		{
			"body" : "Give me liberty or give me death.",
			"author" : "Jan Moravec"
		}
	]

## PUT
Creates new comment on the given post.

### Request (application/json)
	{
		"body" : "This is my comment",
		"author" : "Jakub Nesetril"
	}

### Response 201 (application/json)
	{ "message" : "created" }
