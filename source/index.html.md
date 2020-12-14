---
title: SparkAI documentation
language_tabs:
  - python: Python
  - javascript: Javascript
  - shell: cURL
language_clients:
  - python: ""
  - javascript: ""
  - shell: ""
toc_footers: []
includes: []
search: true
highlight_theme: darkula
headingLevel: 2

---

<!-- Generator: Widdershins v4.0.1 -->

# Introduction

> Scroll down for code samples, example requests and responses. Select a language for code samples from the tabs above or the mobile navigation menu.



[SparkAI](https://www.spark.ai)'s mission is to accelerate the proliferation of automation and robotics.

We know how hard it is to perfect AI – every model struggles in some way, and that gap dictates the pace of progress. SparkAI makes it easy to instantly deploy a human-in-the-loop solution to your hardest AI challenges. We specialize in delivering high-integrity, real-time resolution to longtail AI exceptions in production, empowering you to launch & scale revolutionary products faster than ever before.

Common ways engineering and product teams leverage SparkAI include:

* Resolving low-confidence decisions and edge cases in production
* Launching new products & features with in-development AI models
* Rapidly generating ground truth data
* Real-time quality assurance of model outputs
* Bootstrapping new models for evaluation with customers

When you ping the SparkAI API, you tap into an expansive apparatus of tightly coupled technology and human operations that invisibly scale up with your needs, directed toward your most important goals.

# Overview

## SparkAI service

Interacting with the SparkAI service occurs through a web-based HTTP API. New `engagement` requests are made via a REST-based API, and can be polled for status updates. If a requestor requires immediate notification on any status change, the SparkAI service can push a `resolution` via a provided `web-hook` URL.

New `engagement` requests can be made with an associated associated `program`, which contains metadata and context about the `engagement`. If a `program` is not provided with a request, SparkAI will still make a best effort at providing a resolution with provided instructions.

All calls using the HTTP API follow the form of `https://app.spark.ai/v1/<path>`.

## Enviroments

SparkAI provides two environments, one for integration testing (*sandbox*) and the second for billable API calls (*production*).

### Sandbox server

The sandbox server can be used to test the API interface. This server acts exactly like the production server, but is intended for integration and testing before entering production.

When new engagement requests are made to the Sandbox server, a resolution will be automatically generated. The results from teh resolution are for testing only.

Sandbox server URL: `https://sandbox.spark.ai`

### Production server

Production server URL: `https://app.spark.ai`

## Error handling

API calls to the SparkAI service will return an HTTP status code that reflects the status of the `engagement`. HTTP status codes follow classic [conventions](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) where possible.

Requests that don't succeed will return either a 4xx or 5xx error. The 4xx range means there was a problem with the request, like a missing parameter.

Examples of status codes returned are below:

| Code | Meaning |
|------|---------|
| 200 | Request was succesful |
| 400 | Invalid parameters in the request|
| 401 | Authentication problem |
| 403 | User does not have permission to access this resource |
| 404 | Resource not found |
| 500 | A problem internal to the SparkAI service |

# Nomenclature

### Engagement
The unit of work for the SparkAI service is an `engagement`. Any `engagement` request will be routed through the SparkAI service.

### Program
A `program` is the meta-data asssociated with engagment requests made of the SparkAI service, such as clear instructions, categories, or reference material.

### Resolution
A `resolution` is the response to an `engagement` request.

### Response time
Reponse time is measured from the time a new `engagement` request reaches the SparkAI service, to the time a `resolution` is created.

# Webhook URL

Two options exist for obtaining `resolutions` from the SparkAI service.

* A user can poll the `engagement` API endpoint for status and `resolution`. This option is always available, even if the webhook URL option is used.
* Create the initial `engafgement` request with a webhook URL. The SparkAI service will attempt to `POST` results to the provided URL on any change of `engagement` status.

The webhook URL should be:

* Well-formed
* Able to service HTTP `POST` requests
* Capable of accepting JSON content
* Able to respond with a 200 (OK) status code on receipt

SparkAI will attempt the URL 5 times, at 30 second intervals unless a successful request has been made.

# Typical usage flow

Requests to the SparkAI service can be made with one simple REST call. For users with an established `program`, all that is required in a new `engagement` request is a pointer to the content.

## Polling flow

* (Optional) Upload an image file to the SparkAI image server by making a `POST` request to the `/v1/image` route, storing the signed URL for use in future API calls.
* Make an API call to `POST` to the `engagement` path, supplying either the `program_name` parameter, or `instructions`, an array of URL `image_locations`. The API call will return a `token`.
* Periodically poll the `engagement` resource using the returned `engagement` for status.

## Webhook flow
* (Optional) Upload an image file to the SparkAI image server by making a `POST` request to the `/v1/image` route, storing the signed URL for use in future API calls.
* Make an API call to `POST` to the `engagement` path, supplying either the `program_name` parameter, or `instructions`, an array of URL `image_locations`. The API call will return a `token`.
* When the `engagement` changes status, the SparkAI service will `POST` the `resolution` to a provided URL.

# Token-based authentication

API calls are authenticated via a required API token which is included in the HTTP header as an `Authorization` field. See the header format below:

Authorization: Bearer *provided_token*

Please reach out to <support@spark.ai> for assistance with the authorization token.

# Metadata

Metadata about the request may optionally be included in the request to provide additional context. Metadata should take the form of a set of JSON key-value pairs.

# Annotations

New `engagement` requests may include a set of annotations. The SparkAI service will use these annotations to assist in providing a `resolution`. Corrections may also be provided. Similarly, resolutions to engagement requests may also contain annotations.

Note that annotations vertices are in relative coordinates to the image size, and must be between [0, 1)

Annotations take three parameters:

* A set of vertices
* A label
* A type (`polygon` or `bounding_box`)

# Python example code

```python
# Python3 example

import os
import requests
import json
import sys
import http.server

base_url = 'https://sandbox.spark.ai'
image_path = '/tmp/image.png'
# Example auth token. Replace with a provided token
auth_token = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBfdXNlcl9pZCI6IjY1Y2ExM2U0LTM3OTEtNDFlMC05ZmE0LTY5NTFmYzE5MDdlNyIsImlhdCI6MTYwNzg5MTIyNCwiZXhwIjoxNjM5NDI3MjI0LCJpc3MiOiJzcGFyay5haSIsInN1YiI6IjIuMCJ9.j5kKufsSXQWGfZcVL-FD7G1IVy-9dmEAbnbCR8YqOVcFXawcPxf_TOm-CzN-OSJE3Z9A6-BA3m3VOJl_FWyphcQmGL8nINoBszoMJCnwaHZahe6DIR_mx2SsRaQRrnDPPZ3vYUmKaDAUVZU3Woo2yvCF5XWQBQnHNLCW4RFVhCq-bWJptYz74ylWJPKSk-mith3qQF0L70hoTSvsZjz6rJfoYKrSdU1miG-3cdYqcFJZbFedSJ750XShLa3mNxPtbWZ608OHlroSuI0ZGTH_iqi3lRWW3vyO_7c1VxY-XTVeuVptMTWLgwI69OI_7Ww5xcdPd5JyR0KDCIow07Yh9vtod0PqCd5VfQYj6HNb4xq0boOfeBS4DjYbMVLNOsGUdNZVOysrKozJcoOYg-Xxqub-upgHj3Gbw5Tiw_z_I9jQ62-2ptGNh9GTeAjCQUzSYrwW1nY9Ihi104osIr6zVQyrQ6hgTHcmg51iFIt3rN11bHdNCdTo4SIyVGN5VRPF-9HEqZAojAqooSljBBWA9nNkM8-4zBNqjKQEpp-1-uAbe8Ft80XJ_bcP0pahJHqJpav8F-dA-9an6PG-75ZFuNWZKNdu2ms0ZzbQbTcmw4ujInjuvDcaYsZ3pL3zfI0tDIF2YUiQuZUa93D8G8xyecbF8PBogLYWJbMfZIg6-jQ'
instructions = 'Confirm there are no obstructions in the path of this robot'

# Example webhook URL. Replace or omit.
webhook_local_server_port = 3388
webhook_url = 'http://77bb049f3629.ngrok.io'

headers = {
 'Authorization': 'Bearer ' + auth_token
}

# Upload an image to the SparkAI Image Server.
image_resource_url = '/v1/image'
binary_image = open(image_path, 'rb')
image_name = os.path.basename(image_path)
files= { 'image_file': (image_name, binary_image, 'multipart/form-data') }
r = requests.post(base_url + image_resource_url, headers=headers, files=files, data={})

if r.status_code == 200:
    image_url = json.loads(r.content)['signedUrl']
    print('Uploaded image to SparkAI image server', image_url)
else:
    resp = json.loads(r.content)
    print(resp['statusCode'], resp['message'])
    sys.exit()

# Create a new engagement request
engagement_data = {
    'content_location': image_url,
    'webhook_url': webhook_url,
    'instructions': instructions
}
# An alternate option
# engagement_data = {
#     'content_location': image_url,
#     'program_name': 'your_program',
# }

engagement_resource_url = '/v1/engagement'
r = requests.post(base_url + engagement_resource_url, headers=headers, json=engagement_data)
resp = json.loads(r.content)
if r.status_code == 200:
    print('Created a new engagement request, with token', resp['token'])
else:
    print(resp['statusCode'], resp['message'])
    sys.exit()

# Check status of the engagement
r = requests.get(base_url + engagement_resource_url + '/' + resp['token'], headers=headers)
print('Checking engagement status')
print(json.dumps(json.loads(r.content), indent=2))

# Setup a simple HTTP server to receive webhook URL.
# This isnt necessary, but helps demonstrate the use of webhooks.
# This local server can be tunnelled to the internet by using a tool such as ngrok (www.ngrok.io)
class SimpleHTTPRequestHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        body = self.rfile.read(content_length)
        self.send_response(200)
        self.end_headers()
        print('Received response from SparkAI service')
        response = json.loads(body)
        print(json.dumps(response, indent=2))
        sys.exit()

# Create a local server that accepts the resolutions from SparkAI as a webhook
httpd = http.server.HTTPServer(('', webhook_local_server_port), SimpleHTTPRequestHandler)
httpd.serve_forever()
```

# Contact

Reach out to us at any time through <support@spark.ai>.









<h1 id="--v1-engagement">/v1/engagement</h1>

## Create a new SparkAI engagement

<a id="opIdpost-engagement"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer {access-token}'
}

r = requests.post('https://app.spark.ai/v1/engagement', headers = headers)

print(r.json())

```

```javascript
const inputBody = '{
  "content_location": "http://example.com",
  "program_name": "string",
  "instructions": "string",
  "webhook_url": "http://example.com",
  "metadata": {
    "key1": "string",
    "key2": "string"
  },
  "priors": {
    "label_set": [
      "string"
    ],
    "annotations": [
      {
        "label": "string",
        "type": "bounding_box",
        "vertices": [
          {
            "x": 0,
            "y": 0
          }
        ]
      }
    ]
  }
}';
const headers = {
  'Content-Type':'application/json',
  'Accept':'application/json',
  'Authorization':'Bearer {access-token}'
};

fetch('https://app.spark.ai/v1/engagement',
{
  method: 'POST',
  body: inputBody,
  headers: headers
})
.then(function(res) {
    return res.json();
}).then(function(body) {
    console.log(body);
});

```

```shell
# You can also use wget
curl -X POST https://app.spark.ai/v1/engagement \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer {access-token}'

```

`POST /v1/engagement`

When authorized, this API call will initate a new engagement request.

> Body parameter

```json
{
  "content_location": "http://example.com",
  "program_name": "string",
  "instructions": "string",
  "webhook_url": "http://example.com",
  "metadata": {
    "key1": "string",
    "key2": "string"
  },
  "priors": {
    "label_set": [
      "string"
    ],
    "annotations": [
      {
        "label": "string",
        "type": "bounding_box",
        "vertices": [
          {
            "x": 0,
            "y": 0
          }
        ]
      }
    ]
  }
}
```

<h3 id="create-a-new-sparkai-engagement-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|content_location|body|string(uri)|true|An array of correctly formatted image URLs|
|program_name|body|string|false|The associated program name with this `engagement`. If `program_name` is omitted, instructions must be supplied.|
|instructions|body|string|false|Optional instructions, which can be used if `program_name` is omitted.|
|webhook_url|body|string(uri)|false|A well-formatted URL. The SparkAI service will POST status changes and results to this address.|
|metadata|body|object|false|A set of key-value pairs that can provide additional context to the request|
|» key1|body|string|false|none|
|» key2|body|string|false|none|
|priors|body|object|false|none|
|» label_set|body|[string]|false|An optional array of labels to choose from in corrections|
|» annotations|body|[object]|false|Annotations provided for the service on this content. Annotations are relative to the dimensions of the content and between [0, 1)|
|»» label|body|string|false|This annotation's label|
|»» type|body|string|false|Annotation type|
|»» vertices|body|[object]|false|Vertices of the annotation. For bounding_box, the first vertex should be the top-left corner of the box, moving clockwise|
|»»» x|body|number|false|x coordinate, between [0, 1)|
|»»» y|body|number|false|y coordinate, between [0, 1)|

#### Enumerated Values

|Parameter|Value|
|---|---|
|»» type|bounding_box|
|»» type|polygon|

> Example responses

> 200 Response

```json
{
  "token": "b5507016-7da2-4777-a161-1e8042a6a377"
}
```

<h3 id="create-a-new-sparkai-engagement-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|Indicates a new engagement has been initiated, and return a token for tracking responses|Inline|

<h3 id="create-a-new-sparkai-engagement-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» token|string(uuid)|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
bearerAuth
</aside>

## Get status of a SparkAI engagement

<a id="opIdget-engagement"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'Bearer {access-token}'
}

r = requests.get('https://app.spark.ai/v1/engagement', headers = headers)

print(r.json())

```

```javascript

const headers = {
  'Accept':'application/json',
  'Authorization':'Bearer {access-token}'
};

fetch('https://app.spark.ai/v1/engagement',
{
  method: 'GET',

  headers: headers
})
.then(function(res) {
    return res.json();
}).then(function(body) {
    console.log(body);
});

```

```shell
# You can also use wget
curl -X GET https://app.spark.ai/v1/engagement \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer {access-token}'

```

`GET /v1/engagement`

This API call can be used to poll for the status of any ongoing or completed SparkAI engagement requested by the user.

<h3 id="get-status-of-a-sparkai-engagement-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|limit|query|number|false|Limit the number of responses, up to 50|
|count|query|boolean|false|Return the total count of the query, instead of results|
|cursor|query|number|false|Obtain results beginning at the cursor|
|state|query|string|false|State of engagement|

#### Enumerated Values

|Parameter|Value|
|---|---|
|state|open|
|state|assigned|
|state|closed|

> Example responses

> 200 Response

```json
[
  {
    "date_created": "2019-08-24T14:15:22Z",
    "date_closed": "2019-08-24T14:15:22Z",
    "token": "b5507016-7da2-4777-a161-1e8042a6a377",
    "instructions": "string",
    "webhook_url": "http://example.com",
    "program_name": "string",
    "image_location": "http://example.com",
    "state": "open",
    "response": "string",
    "annotations": [
      {
        "original_annotation": {},
        "label": "string",
        "type": "bounding_box",
        "vertices": [
          {
            "x": 0,
            "y": 0
          }
        ]
      }
    ]
  }
]
```

<h3 id="get-status-of-a-sparkai-engagement-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="get-status-of-a-sparkai-engagement-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» date_created|string(date-time)|false|none|none|
|» date_closed|string(date-time)|false|none|none|
|» token|string(uuid)|false|none|none|
|» instructions|string|false|none|Instructions, if provided|
|» webhook_url|string(uri)|false|none|The webhook URL, if provided|
|» program_name|string(string)|false|none|The program name, if provided|
|» image_location|string(uri)|false|none|none|
|» state|string|false|none|none|
|» response|string|false|none|none|
|» annotations|[object]|false|none|New or modified annotations associated with the response|
|»» original_annotation|object|false|none|Correction to the annotation, if provided. Follows the format of the annotations below|
|»» label|string|false|none|This annotation's label|
|»» type|string|false|none|Annotation type|
|»» vertices|[object]|false|none|Vertices of the annotation. For bounding_box, the first vertex should be the top-left corner of the box, moving clockwise|
|»»» x|number|false|none|x coordinate, between [0, 1)|
|»»» y|number|false|none|y coordinate, between [0, 1)|

#### Enumerated Values

|Property|Value|
|---|---|
|state|open|
|state|assigned|
|state|closed|
|type|bounding_box|
|type|polygon|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
bearerAuth
</aside>

## Get status of a SparkAI engagement by token

<a id="opIdget-engagement-token"></a>

> Code samples

```python
import requests
headers = {
  'Accept': 'application/json',
  'Authorization': 'Bearer {access-token}'
}

r = requests.get('https://app.spark.ai/v1/engagement/{token}', headers = headers)

print(r.json())

```

```javascript

const headers = {
  'Accept':'application/json',
  'Authorization':'Bearer {access-token}'
};

fetch('https://app.spark.ai/v1/engagement/{token}',
{
  method: 'GET',

  headers: headers
})
.then(function(res) {
    return res.json();
}).then(function(body) {
    console.log(body);
});

```

```shell
# You can also use wget
curl -X GET https://app.spark.ai/v1/engagement/{token} \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer {access-token}'

```

`GET /v1/engagement/{token}`

This API call can be used to poll for the status of a SparkAI engagement by its unique token

<h3 id="get-status-of-a-sparkai-engagement-by-token-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|limit|query|number|false|Limit the number of responses, up to 50|
|cursor|query|number|false|Obtain results beginning at the cursor|
|state|query|string|false|State of engagement|
|token|path|string(uuid)|false|Unique engagement token|

#### Enumerated Values

|Parameter|Value|
|---|---|
|state|open|
|state|assigned|
|state|closed|

> Example responses

> 200 Response

```json
[
  {
    "date_created": "2019-08-24T14:15:22Z",
    "date_closed": "2019-08-24T14:15:22Z",
    "token": "b5507016-7da2-4777-a161-1e8042a6a377",
    "instructions": "string",
    "webhook_url": "http://example.com",
    "program_name": "string",
    "image_location": "http://example.com",
    "state": "open",
    "response": "string",
    "annotations": [
      {
        "original_annotation": {},
        "label": "string",
        "type": "bounding_box",
        "vertices": [
          {
            "x": 0,
            "y": 0
          }
        ]
      }
    ]
  }
]
```

<h3 id="get-status-of-a-sparkai-engagement-by-token-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|Inline|

<h3 id="get-status-of-a-sparkai-engagement-by-token-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» date_created|string(date-time)|false|none|none|
|» date_closed|string(date-time)|false|none|none|
|» token|string(uuid)|false|none|none|
|» instructions|string|false|none|Instructions, if provided|
|» webhook_url|string(uri)|false|none|The webhook URL, if provided|
|» program_name|string(string)|false|none|The program name, if provided|
|» image_location|string(uri)|false|none|none|
|» state|string|false|none|none|
|» response|string|false|none|none|
|» annotations|[object]|false|none|New or modified annotations associated with the response|
|»» original_annotation|object|false|none|Correction to the annotation, if provided. Follows the format of the annotations below|
|»» label|string|false|none|This annotation's label|
|»» type|string|false|none|Annotation type|
|»» vertices|[object]|false|none|Vertices of the annotation. For bounding_box, the first vertex should be the top-left corner of the box, moving clockwise|
|»»» x|number|false|none|x coordinate, between [0, 1)|
|»»» y|number|false|none|y coordinate, between [0, 1)|

#### Enumerated Values

|Property|Value|
|---|---|
|state|open|
|state|assigned|
|state|closed|
|type|bounding_box|
|type|polygon|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
bearerAuth
</aside>

<h1 id="--v1-image">/v1/image</h1>

## Upload an image

<a id="opIdpost-image"></a>

> Code samples

```python
import requests
headers = {
  'Content-Type': 'multipart/form-data',
  'Accept': 'application/json',
  'Authorization': 'Bearer {access-token}'
}

r = requests.post('https://app.spark.ai/v1/image', headers = headers)

print(r.json())

```

```javascript
const inputBody = '{
  "tag": "string",
  "image_file": "string"
}';
const headers = {
  'Content-Type':'multipart/form-data',
  'Accept':'application/json',
  'Authorization':'Bearer {access-token}'
};

fetch('https://app.spark.ai/v1/image',
{
  method: 'POST',
  body: inputBody,
  headers: headers
})
.then(function(res) {
    return res.json();
}).then(function(body) {
    console.log(body);
});

```

```shell
# You can also use wget
curl -X POST https://app.spark.ai/v1/image \
  -H 'Content-Type: multipart/form-data' \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer {access-token}'

```

`POST /v1/image`

Uploads an image to SparkAI, returning a cryptographically signed URL

> Body parameter

```yaml
tag: string
image_file: string

```

<h3 id="upload-an-image-parameters">Parameters</h3>

|Name|In|Type|Required|Description|
|---|---|---|---|---|
|tag|body|string|false|One single tag for the image|
|image_file|body|string(binary)|false|none|

> Example responses

> 200 Response

```json
{
  "signedUrl": "http://example.com",
  "url": "http://example.com"
}
```

<h3 id="upload-an-image-responses">Responses</h3>

|Status|Meaning|Description|Schema|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|The URL where the image is stored. An optionally signed version is also available|Inline|

<h3 id="upload-an-image-responseschema">Response Schema</h3>

Status Code **200**

|Name|Type|Required|Restrictions|Description|
|---|---|---|---|---|
|» signedUrl|string(uri)|false|none|none|
|» url|string(uri)|false|none|none|

<aside class="warning">
To perform this operation, you must be authenticated by means of one of the following methods:
bearerAuth
</aside>

