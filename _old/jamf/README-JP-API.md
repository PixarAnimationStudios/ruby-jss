## Implementing the Jamf Pro API in ruby-jss

The Jamf Pro API, formerly known as the 'Universal' API, aims to be a far more robust, modern, and standardized way to programmatically access a Jamf Pro server.  While its been in development for a while, it is finally starting to settle in to some standards, to the point that its worth releasing some early ruby-jss code to access it.

Because the JP-API is so fundamentally different from the Classic API, it's being implemented as a totally separate ruby module 'Jamf', and many of the underlying standards of ruby-jss's JSS module are being re-thought and modernized, much like the JP-API itself. Therefore there are some very big changes afoot.

This README is a quick overview of the big changes, for both using the Jamf module, and for contributing to its development.

**IMPORTANT:** As with the JP-API, this is an early work-in-progress, and things might change drastically at any point - For example, we're investigating automated generation of classes, enums, and other items directly from the OpenAPI JSON which defines the API itself.

The original work on the Jamf module was started long before the current server-side standards were in place, and much of that old-code is still here, but won't work.  Please mention 'ruby-jss' in MacAdmins Slack channels #jamf-api or #ruby, or email ruby-jss@pixar.com, or open an issue on github if you have questions or want to contribute.

At the moment, our focus is on these classes:
- InventoryPreloadRecords
- ComputerPrestage and MobileDevicePrestage
- DeviceEnrollment



CONTENTS:

 <!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

 - [Requirements](#requirements)
 	- [Ruby 2.3 or higher](#ruby-23-or-higher)
 - [The Jamf module](#the-jamf-module)
 - [Overview of differences between JSS and Jamf modules](#overview-of-differences-between-jss-and-jamf-modules)
 - [Connecting to the JP-API](#connecting-to-the-jp-api)
 	- [Connection Objects](#connection-objects)
 	- [Connection Parameters](#connection-parameters)
 	- [Connection Tokens](#connection-tokens)
 		- [Tokens are objects](#tokens-are-objects)
 		- [Tokens Expire](#tokens-expire)
 		- [Tokens can be refreshed](#tokens-can-be-refreshed)
 		- [Connections can refresh the token automatically](#connections-can-refresh-the-token-automatically)
 		- [Using a token to make a new connection](#using-a-token-to-make-a-new-connection)
 		- [Token strings work too](#token-strings-work-too)
 		- [Tokens can be invalidated](#tokens-can-be-invalidated)
 	- [Endpoints Implemented](#endpoints-implemented)
 - [Under the Hood](#under-the-hood)
 	- [Classes classes everywhere](#classes-classes-everywhere)
 		- [Jamf::JSONObject](#jamfjsonobject)
 		- [Jamf::Resource](#jamfresource)
 		- [Jamf::SingletonResource](#jamfsingletonresource)
 		- [Jamf::CollectionResource](#jamfcollectionresource)
 		- [MixIns](#mixins)
 		- [The OBJECT_MODEL constant](#the-objectmodel-constant)
 			- [class: \[Symbol or Class]](#class-symbol-or-class)
 			- [identifier: \[Boolean, or Symbol :primary]](#identifier-boolean-or-symbol-primary)
 			- [required: \[Boolean]](#required-boolean)
 			- [readonly: \[Boolean]](#readonly-boolean)
 			- [multi: \[Boolean]](#multi-boolean)
 			- [enum: \[Constant -> Array<Constants> ]](#enum-constant-arrayconstants-)
 			- [validator: \[Symbol]](#validator-symbol)
 			- [aliases: \[Array of Symbols]](#aliases-array-of-symbols)
 			- [Documenting OBJECT_MODEL](#documenting-objectmodel)
 			- [Sub-subclassing and OBJECT_MODEL](#sub-subclassing-and-objectmodel)
 			- [Data Validation \{#data_validation}](#data-validation-datavalidation)
 			- [Constructor / Instantiation](#constructor-instantiation)
 		- [Required Instance Methods](#required-instance-methods)
 	- [Autoloading](#autoloading)
 - [More to come.....](#more-to-come)

 <!-- /TOC -->



# Requirements
#### Ruby 2.3 or higher
Some features of ruby 2.3 are used throughout the Jamf module.

macOS 10.12.6 or higher can use the ruby that comes with the OS, at /usr/bin/ruby.

# The Jamf module

The ruby-jss gem now contains two modules, which can be 'required' separately:

- `require 'ruby-jss'` or `require 'jss'` works as always, and loads in the 'JSS' module, which is unchanged in how it works for accessing the Classic API.  As long as the classic API is around, the JSS module will remain.

- `require 'jamf'` will load the 'Jamf' module, which is where access to the JP-API will happen.

Because everything is separated between the two modules, they can be used side by side, but remember when doing so, that objects are not compatible between them. So you if do

`classicPol = JSS::Policy.fetch name: 'myPolicy'`

and

`jpPol = Jamf::Policy.fetch name: 'myPolicy'`

the objects in `classicPol` and `jpPol` are very different things in ruby, even tho they represent the same policy.

# Overview of differences between JSS and Jamf modules

While the general concepts will be the same (working with lists, fetching objects, updating them,), the start-from-scratch aspect of coding the Jamf module allows for some changes that I wish I could have made before, including the names of some classes, methods and attributes.

- The active connection object is available in `Jamf.cnx` vs. the older `Jamf.cnx`, and when passing a connection object as a named parameter, the name is `cnx:`.  This more accurately reflects what the object is - a 'connection' not an 'api'

- Creating a connection can take a URL as a first positional parameter, e.g. `Jamf.connect 'https://myjamf.mysch.edu/'`. See 'Connection Parameters' below

- As with the JSS module, classes representing API Resources don't accept the `.new` method for creating instances, since the word 'new' is ambiguous in this context (are you making a new instance in ruby, or a new object in Jamf Pro?). The `.fetch` method is still the way to retrieve a resource and instantuate an object in ruby with it. However, to create a new object in ruby to then add to Jamf Pro, you should now use `.create` instead of `.make`. Saving changes to the server is always done with `.save`. Here are some examples:

 Action | Classic API with JSS |  JP-API with Jamf
 -------|----------------------|------------------
Fetch a Computer | `JSS::Computer.fetch name: 'compName'` | `Jamf::Computer.fetch name: 'compName'
Update a Policy after making changes | `mypol.update` or `mypol.save` | `mypol.save`
Make a new static User group | `new_grp = JSS::UserGroup.make name: 'ngrp', type: :static` |  `new_grp = Jamf::UserGroup.create name: 'ngrp', type: :static`
Save the new static group to the server  | `new_grp.create` or `new_grp.save` | `new_grp.save`


- Most attribute names for resources are in lowerCamelCase. While the ruby standard for attribute & method names is snake_case, the JSON data from the api uses lowerCamelCase for the names of attributes. The Jamf module mirrors those names, for better alignement with the actual data.

  Example: JSS::MobileDevice has an instance method `serial_number`, while Jamf::MobileDevice has `serialNumber`

# Connecting to the Jamf Pro API

## Connection Objects

Connections are instances of Jamf::Connection, analagous to the previous JSS::APIConnection.

The way to access the 'active' connection in the Jamf module is via `Jamf.cnx`, which is the equivalent to the previous `Jamf.cnx`.

Like before, a 'default' one is created when the library is loaded, and it is made the 'active' one. The Jamf module now has a direct `.connect` method so `Jamf.connect <params>` is the same as `Jamf.cnx.connect <params>`

As before, new connection objects can be created and stored in variables, then passsed around to various class methods as needed.

```
cnx1 = Jamf::Connection.new <params>
cnx2 = Jamf::Connection.new <params>

comp1 = Jamf::Computer.fetch id: 12, cnx: cnx1
comp2 = Jamf::Computer.fetch id: 12, cnx: cnx2
```
## Connection Parameters

The older connection parameters should still work as before, although `host: 'myjss.hostname.com'` is preferred over `server: 'myjss.hostname.com'`.

However, the connection can be made using a URL as the first positional parameter, e.g.

    Jamf.connect 'https://myAPIuser:myAPIpasswd@myjss.hostname.com:8443'

When a URL is provided like this, the following parameters are parsed from it:

- use_ssl:  true if the URL is 'https' scheme
- user: extracted from the URL if provided. Otherwise, must be passed as a param, or available from the config file.
- pw: extracted from the URL if provided. Otherwise, must be passed as a param, or if not, defaults to :prompt
  - **WARNING**: beware of hard-coding passwords anywhere
- host: extracted from the URL
  - any `host:` param will be ignored if a URL is used.
- port: extracted from the URL explicitly if provided, or via the URL scheme if not (https = port 443, http = port 80)
  - any `port:` param will be ignored if a URL is used

If a URL is used, any values present in the URL override any that might be given as a parameter.

If a pw: parameter is not provided or present in a URL, the default is to prompt in a terminal, the same as `pw: :prompt`

## Connection Tokens

The JP-API uses token-based access, which is far more secure than sending the password along with every request.

For the most part, dealing with tokens is invisible to the user of ruby-jss. However, here are some things to think about as you work with them:

### Tokens are objects

Once you are connected, the token is available in the `#token` method of the Connection object. So for the active connection, `my_token = Jamf.cnx.token`

### Tokens Expire

Tokens come with an expiration time, defined by the server. The duration of a token is the same as the duration of a JamfPro Web-UI session, which defaults to 30 minutes. After that time, the token is no longer valid and API access using it will fail.  To see the expiration time, use the '#expires' method: `Jamf.cnx.token.expires`.

### Tokens can be refreshed

As long as you have a valid, not-expired token, you can use it to refresh itself, which replaces the internally-stored token data and resets the expiration. Just use, e.g. `Jamf.cnx.token.refresh` which will return the new expiration time. Once refreshed, the original token data is no longer valid.

### Connections can refresh the token automatically

If you have a long-running process that's likely to run longer than the life of a token, you can tell your connection object to automatically refresh its token some number of seconds before the token expires. To do so, just set the connection's 'keep_alive' attribute to true: `Jamf.cnx.keep_alive = true`. This will start a thread in the background that mostly stays asleep. Every 60 seconds it wakes up and checks to see if the current token's expiration is less than 'token_refresh' seconds from now, and if so, will refresh the token.

You can set token_refresh when you create your connection using the `token_refresh:  nnn` param, where nnn is an integer number of seconds. You can also set it dynamically, `Jamf.cnx.token_refresh = nnn`

#### pw-fallback

Occasionally a valid token refresh might fail. In that case, by default, the pw-fallback option is used when the token is refreshed manually or via `keep_alive`.

By default this option is 'true' and the password used to connect is kept in memory in the Connection object. If the token-refresh process fails, the password is used again to generate a new token and keep the connection alive.

If you don't want the password stored in memory, just provide `pw-fallback: false` in the connection parameters - however if the token fails to refresh, you will lose your connection altogether.

### Using a token to make a new connection

Since tokens are objects, they can be used to make a connection. Just use `token: <token object>` in the connection parameters. E.g.

  `Jamf.connect token: my_token`

As long as the token is valid on the API host, and hasn't expired, it will work until it expires, or is invalidated from elsewhere.

When using a token object this way, any host, port, user, pw, or use_ssl parameters are ignored, whether explicitly set, or in a URL.


### Token strings work too

In the actual HTTP transactions, the token is actually a long string of gibberish-looking characters. If you don't have a `Jamf::Connection::Token` object, but you have a valid, not-expired token string, you can provide that in place of a user: and pw: value when making a connection. You still have to provide the correct host, port, and other values, which can be done via a url or parameters.

e.g.
```ruby
tk_str = '<long token string here>'

Jamf.connect 'https://myjamf.mysch.edu:8443/', token: tk_str
# or
Jamf.connect host: 'myjamf.mysch.edu', port: 8443, token: tk_str

```
Once the connection is made, a fresh token is generated using the token string, and the string itself will be invalidated.

### Tokens can be invalidated

If you know you're done using a token, and want to be sure a copy of it cant be used from anywhere else, use the token's `invalidate` method, which will tell the server to stop accepting it as valid. The Connection object also has a `logout` method which will invalidate the token before disconnecting.

Be careful if you use tokens in multiple places, since invalidating a token would break any other connection using it.

## Endpoints Implemented

As the Jamf Pro API evolves, many enpoints are coming and going and changing.

All of the more-recent, stable endpoints have a version number in their path, e.g. 'v1'. However even they have often have internal breaking changes until Jamf officially releases the new API.

Ruby-jss will only implement endpoints that have a version number, since the others are deprecated or in preview.

Even among those that have version numbers, ruby-jss will probably never implement all of them. The developers at Pixar will focus on those useful to them.  If you would like to see others, feel free to contribute your own code, or send us a note asking for what you'd like. If you want to contribute, we'll be happy to help out if you're just learning ruby.

As of this writing, here are the resources that are at least partially implemented in the Jamf module:

- /v1/auth
- /v1/buildings
- /v1/categories
- /v2/computer-prestages
- /v1/departments
- /v1/device-enrollments
- /v2/inventory-preload
- /v2/mobile-device-prestages
- /v1/time-zones
- /v1/locales
- /v1/app-store-country-codes

# Under the Hood

## Classes classes everywhere

Because of the more modern standards being used as the JP-API is developed, implementing endpoints in ruby-jss is in some ways far easier, but pickier, than it was in the classic API.

In JSON & Javascript, an 'object' is a data structure equivalent to a hash in ruby, a dictionary in python, a record in Applescript, and so on. Almost all of the JSON data exchanged with the API is formatted as these JSON objects.

The Jamf Pro API uses well-defined JSON 'Object Models' to describe and format the objects sent to and from the server. The model gives the name of each key, and the data-type of its value.  The data-type might be a primative like a string, integer, float or boolean, or it might be an array of things, or it might be another JSON object (Hash) which will have its own model.

To see these Object Model definitions,, have a look at your Jamf Pro server's documentation at https://your.jamf.server/api/doc

Take a look at the GET docs for an endpoint, e.g. Buildings -> GET /v1/buildings, and you can click to view either the the 'Model' and the 'Model Schema' (an example of a JSON object matching the model with sample data)

Ruby-jss's Jamf module is built around these object models, using a hierarchy of base classes and a representation of the Object Model in ruby. Every 'hash' of data that is sent to or recieved from the API has a matching ruby class that is a descendant of Jamf::JSONObject.

To be clear: *almost every* Hash that you see in the API JSON data has a matching ruby class in ruby-jss. That means there will be LOTS of classes! After all, what is a 'class' in object-oriented programming? It's a model of an object.

Here's the relationship between these base classes:

                    Jamf::JSONObject
                       (base class)
                           |
                           |
                 -----------------------
                |                       |
          Jamf::Resource                |
            (base class)                  |
                |                       |
                |                       |
                |                 Jamf::Location
                |             Jamf::Computer::Reference
                |              Jamf::ChangeLog::Entry
                |                    (etc...)
                |
                |----------------------------------------
                |                                        |
                |                                        |
       Jamf::SingletonResource                Jamf::CollectionResource
            (base class)                               (base class)
                |                                        |
                |                                        |
     Jamf::Settings::ReEnrollment                  Jamf::Computer
     Jamf::Settings::SelfService                   Jamf::Building
          Jamf::SystemInfo                       Jamf::PatchPolicy
            (etc...)                                  (etc...)


> Note: An 'base' class, is not meant to have instances. Instead, it holds common code shared among its subclasses.
> An example of real-world base classes would be 'Animal', and its subclass 'Mammal'. In the real world there is no such thing as an individual 'Animal' or 'Mammal' that you could hold or touch. However 'Dog' is a subclass of Mammal, and it is not base, so there are instances of Dogs in the real world, and you can hold them and touch them.

### Jamf::JSONObject

This is the top of the class hierarchy for working with API data, and automates much of the work of creating a ruby class from a JSON object model.

All subclasses inheriting from JSONObject must define the constant `OBJECT_MODEL` which implements the JSON object model in ruby. See below for details about the OBJECT_MODEL constant.

Direct subclasses of JSONObject are nearly always used internally in other classes. For example, Jamf location data for a computer or mobile device (username, room number, building etc.) is a Jamf::Location object contained inside a Computer or MobileDevice object.

### Jamf::Resource

This base class is a subclass of JSON object, and represents a thing you can access via the API. The code here handles the actual interaction with the API for all resources. Subclasses of Jamf::Resource must define the constants RSRC_VERSION (e.g. 'v1') and RSRC_PATH (e.g. 'buildings') which are used together to create the URI path to the resource.

Jamf::Resource is never subclassed directly. Instead, it has two subclasses that are themselves base classes, representing the two kinds of resources:

### Jamf::SingletonResource

This base class represents API resources that are single, persistent sets of values on the server, usually various preferences, settings or static data.  These resources can only be read and perhaps updated, never created or deleted.  There is really only one 'instance' of these classes, and When accessed via ruby-jss, they are cached locally to minimize server access, but can be refreshed as needed. Examples include enrollment and reenrollment settings, app store country codes, and timezone data.

### Jamf::CollectionResource

This base class represents API resources that are 'collections' - groups of individual objects that have id numbers and can be listed in various ways. Instances of the class represent those individual objects. Shared code for dealing with collections as a whole (listing, filtering, searching, fetching, creating, etc) is defined here.

### MixIns

Mixin Modules are used heavily throughout ruby-jss to share common code needed in the many classes. Some of them are meant to be extended into a class (for adding class methods) others are included (for instance methods) and some work both ways.

### The OBJECT_MODEL constant

Each descendent of JSONObject, including those of SingletonResource and CollectionResource, must define the constant OBJECT_MODEL.

This constant is a Hash of Hashes that collectively define the top-level keys of the JSON object as attributes of the matching ruby class.

The OBJECT_MODEL Hash directly implements the matching JSON object model defined at https://developer.jamf.com/apis/jamf-pro-api/index and is used to automatically create attributes & accessor methods mirroring those in the API.

Immediately after the definition of OBJECT_MODEL, the subclass *MUST* call `self.parse_object_model` to convert the model into actual ruby attributes with getters and setters.

The keys of the main hash are the symbolized names of the attributes as they come from the JSON fetched from the API.

_ATTRIBUTE NAMES_

The attribute names in the Jamf Pro API JSON data are in [lowerCamelCase](https://en.wikipedia.org/wiki/Camel_case), and are used that way throughout the Jamf module in order to maintain consistency with the API itself. This differs from the ruby standard of using [snake_case](https://en.wikipedia.org/wiki/Snake_case) for attributes, methods, & local variables. I believe that maintaining consistency with the API we are mirroring is more important (and simpler) than conforming with ruby's community standards. I also believe that doing so is in-line with the ruby community's larger philosophy:

> There's more than one way to do it - because context matters.

(If that weren't true, I'd be writing Python)

Each attribute key in OBJECT_MODEL points to a Hash of details defining how the attribute is used in the class. Getters and setters are created from these details, and they are used to parse incoming, and generate outgoing JSON data

The possible keys of the details Hash for each attribute are:

- class - The value of this attribute is this kind of object.
- identfier - is this attribute a unique identifier for instances of a Collection Resource?
- required - is this attribute required when creating a new Jamf object?
- readonly - is this attribute readonly?
- multi - can this attribute contain more than one value?
- enum - an Array of the allowed values for this attribute.
- validator - a method used to validate new values for this attribute.
- aliases - other names this attribute is known by.
- filter_key - can this attribute be used in a filter query for a CollectionResource?

For an example of an OBJECT_MODEL hash, see Jamf::MobileDeviceDetails::OBJECT_MODEL

For a full discussion of the OBJECT_MODEL constant, see the documentation for Jamf::JSONObject, located in the file .../lib/jamf/api/abstract_classes/json_object.rb

## Autoloading

Since the number of classes is so huge, and they aren't always needed in any given project, the Jamf module is using ruby's autoloading feature to load most of the files only as they are used.  See the file .../lib/jamf.rb  to see how that all works


# More to come.....
