 Implementing the Jamf Pro API in ruby-jss

 <!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

 - [Requirements](#requirements)
 	- [Ruby 2.3 or higher](#ruby-23-or-higher)
 	- [Manully install Faraday and Faraday Middleware](#manully-install-faraday-and-faraday-middleware)
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

The Jamf Pro API, formerly known as the 'Universal' API, aims to be a far more robust, modern, and standardized way to programmatically access a Jamf Pro server.  While its been in development for a while, it is finally starting to settle in to some standards, to the point that its worth releasing some early ruby-jss code to access it.

Because the JP-API is so fundamentally different from the Classic API, it's being implemented as a totally separate ruby module 'Jamf', and many of the underlying standards of ruby-jss's JSS module are being re-thought and modernized, much like the JP_API itself. Therefore there are some very big changes afoot.

This README is a quick overview of the big changes, for both using the Jamf module, and for contributing to its development.

**IMPORTANT:** As with the JP-API, this is an early work-in-progress, and things might change drastically at any point. The original work on the JP-API code was started long before the current server-side standards were in place, and much of that old-code is still here, but won't work.  Please mention 'ruby-jss' in MacAdmins Slack #jamf-api or #ruby, or email ruby-jss@pixar.com, or open an issue on github if you have questions or want to contribute.
# Requirements
#### Ruby 2.3 or higher
Some features of ruby 2.3 are used throughout the Jamf module.

macOS 10.12.6 or higher can use the ruby that comes with the OS, at /usr/bin/ruby.
#### Manully install Faraday and Faraday Middleware

The Jamf module uses the [Faraday Gem](https://github.com/lostisland/faraday) and its companion [faraday_middleware](https://github.com/lostisland/faraday_middleware), as its underlying HTTP connector. You will need to install two gems manually:

`gem install faraday`

and

`gem install faraday_middleware`

The plan is to migrate the original classic API connection to also use Faraday, moving away from the 'rest-client' gem. The primary reason being that Faraday has fewer dependencies, none of which require being compiled. This means that installing ruby-jss on a Mac will no longer need the XCode CommandLine tools. When that happens, the ruby-jss gem will be updated to automatically install faraday when ruby-jss is installed.  Until then, please install it manually before using the new JP-API code.
# The Jamf module

The ruby-jss gem now contains two modules, which can be 'required' separately:

- `require 'ruby-jss'` or `require 'jss'` works as always, and loads in the 'JSS' module, which is unchanged in how it works for accessing the Classic API.  As long as the classic API is around, the JSS module will remain.

- `require 'jamf'` will load the 'Jamf' module, which is where access to the JP-API will happen.

Because everything is separated between the two modules, they can be used side by side, but remember when doing so, that objects are not compatible between them. So you if do `classicPol = JSS::Policy.fetch name: 'myPolicy'` and `jpPol = Jamf::Policy.fetch name: 'myPolicy'`, the objects in `classicPol` and `jpPol` are very different things, even tho they represent the same policy.
# Overview of differences between JSS and Jamf modules

While the general concepts will be the same (working with lists, fetching objects, updating them,), the start-from-scratch aspect of coding the Jamf module allows for some changes that I wish I could have made before, including the names of some classes, methods and attributes.

- The active connection object is available in `Jamf.cnx` vs. the older `JSS.api`, and when passing a connection object as a named parameter, the name is `cnx:`.  This more accurately reflects what the object is - a 'connection' not an 'api'

- Creating a connection can take a URL as a first positional parameter, e.g. `Jamf.connect 'https://myjamf.mysch.edu/'`. See 'Connection Parameters' below

- As with the JSS module, classes representing API Resources don't accept the `.new` method for creating instances, since the word 'new' is ambiguous in this context (are you making a new instance in ruby, or a new object in Jamf Pro?). The `.fetch` method is still the way to retrieve a resource and instantuate an object in ruby with it. However, to create a new object in ruby to then add to Jamf Pro, you should now use `.create` instead of `.make`. Saving changes to the server is always done with `.save`. Here are some examples:

 Action | Classic API with JSS |  JP-API with Jamf
 -------|----------------------|------------------
Fetch a Computer | `JSS::Computer.fetch name: 'compName'` | `Jamf::Computer.fetch name: 'compName'
Update a Policy after making changes | `mypol.update` or `mypol.save` | `mypol.save`
Make a new static User group | `new_grp = JSS::UserGroup.make name: 'ngrp', type: :static` |  `new_grp = Jamf::UserGroup.create name: 'ngrp', type: :static`
Save the new static group to the server  | `new_grp.create` or `new_grp.save` | `new_grp.save`


- Most attribute names for resources are in lowerCamelCase. While the ruby standard for attribute & method names is snake_case, the JSON data from the api uses lowerCamelCase for the names of attributes. The Jamf module mirrors those names, for better alignement with the actual data.

  Example: JSS::Computer has an instance method `serial_number`, while Jamf::Computer has `serialNumber`

# Connecting to the JP-API

## Connection Objects

Connections are instances of Jamf::Connection, analagous to the previous JSS::APIConnection.

The way to access the 'active' connection in the Jamf module is via `Jamf.cnx`, which is the equivalent to the previous `JSS.api`.

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
  - WARNING: beware of hard-coding passwords anywhere
- host: extracted from the URL
  - any `host:` param will be ignored if a URL is used.
- port: extracted from the URL explicitly if provided, or via the URL scheme if not (https = port 443, http = port 80)
  - any `port:` param will be ignored if a URL is used

If a URL is used, any values present in the URL override any that might be given as a parameter.

If a pw: parameter is not provided or present in a URL, the default is to prompt in a termminal, the same as `pw: :prompt`

## Connection Tokens

The JP-API uses token-based access, which is far more secure than sending the password along with every request.

For the most part, dealing with tokens is invisible to the user of ruby-jss. However, here are some things to think about as you work with them:

### Tokens are objects

Once you are connected, the token is available in the `#token` method of the Connection object. So for the active connection, `my_token = Jamf.cnx.token`

### Tokens Expire

Tokens come with an expiration time, defined by the server. After that time, the token is no longer valid and API access using it will fail.  To see the expiration time, use the '#expires' method: `Jamf.cnx.token.expires`.
### Tokens can be refreshed

As long as you have a valid token, you can use it to refresh itself, which replaces the internally-stored token data and resets the expiration. Just use, e.g. `Jamf.cnx.token.refresh` which will return the new expiration time. Once refreshed, the original token data is no longer valid.

### Connections can refresh the token automatically

If you have a long-running process that's likely to run longer than the life of a token, you can tell your connection object to automatically refresh its token some number of seconds before the token expires. To do so, just set the connection's 'keep_alive' attribute to true: `Jamf.cnx.keep_alive = true`. This will start a thread in the background that mostly stays asleep. Every 60 seconds it wakes up and checks to see if the current token's expiration is less than 'token_refresh' seconds from now, and if so, will refresh the token.

You can set token_refresh when you create your connection using the `token_refresh:  nnn` param, where nnn is an integer number of seconds. You can also set it dynamically, `Jamf.cnx.token_refresh = nnn`

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
 or
Jamf.connect host: 'myjamf.mysch.edu', port: 8443, token: tk_str

```
Once the connection is made, a fresh token is generated using the token string, and the string itself will be invalidated.

### Tokens can be invalidated

If you know you're done using a token, and want to be sure a copy of it cant be used from anywhere else, use the token's `invalidate` method, which will tell the server to stop accepting it as valid. The Connection object also has a `logout` method which will invalidate the token before disconnecting.

Be careful if you use tokens in multiple places, since invalidating a token would break any other connection using it.
## Endpoints Implemented


As the Jamf Pro API evolves during its early stages, many enpoints are coming and going and changing.

All of the more-recent, stable endpoints have a version number in their path, e.g. 'v1'. Ruby-jss will only implement endpoints that have a version number, since the others are deprecated. The only current exception to this is the /auth endpoint, needed for authentication to the API.  Once it is updated, ruby-jss will use the new endpoint.

Even among those that have version numbers, ruby-jss will probably never implement all of them. The developers at Pixar will focus on those useful to them.  If you would like to see others, feel free to contribute your own code, or send us a note asking for what you'd like. If you want to contribute, we'll be happy to help out if you're just learning ruby.

As of this writing, here are the endpoints/resources that are at least partially implemented in the Jamf module:

- /auth
- /v1/app-store-country-codes
- /v1/buildings
- /v2/categories
- /v1/computer-prestages
- /v1/departments
- /v1/inventory-preload
- /v1/mobile-device-prestages

# Under the Hood

## Classes classes everywhere

Because of the more modern standards being used as the JP-API is developed, implementing endpoints in ruby-jss is in some ways far easier, but pickier, than it was in the classic API.

In JSON & Javascript, an 'object' is a data structure equivalent to a hash in ruby, a dictionary in python, a record in Applescript, and so on. Almost all of the JSON data exchanged with the API is formatted as these JSON objects.

The Jamf Pro API uses well-defined JSON 'Object Models' to describe and format the objects sent to and from the server. The model gives the name of each key, and the data-type of its value.  The data-type might be a primative like a string, integer, float or boolean, or it might be an array of things, or it might be another JSON object (which will have its own model).

To see these Object Model definitions,, have a look at your Jamf Pro server's documentation at https://your.jamf.server.edu/uapi/doc

Take a look at the GET docs for an endpoint, e.g. Buildings -> GET /v1/buildings, and you can click to view either the the 'Model' and the 'Model Schema' (an example of a JSON object matching the model with sample data)

Ruby-jss's Jamf module is built around these object models, using a hierarchy of abstract classes and a representation of the Object Model in ruby. Every 'hash' of data that is sent to or recieved from the API has a matching ruby class that is a descendant of Jamf::JSONObject.

Here's the relationship between these abstract classes:

                    Jamf::JSONObject
                       (abstract)
                           |
                           |
                 -----------------------
                |                       |
          Jamf::Resource                |
            (abstract)                  |
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
            (abstract)                               (abstract)
                |                                        |
                |                                        |
     Jamf::Settings::ReEnrollment                  Jamf::Computer
     Jamf::Settings::SelfService                   Jamf::Building
          Jamf::SystemInfo                       Jamf::PatchPolicy
            (etc...)                                  (etc...)



### Jamf::JSONObject

This is the top of the class hierarchy for working with API data, and automates much of the work of creating a ruby class from a JSON object model.

All subclasses inheriting from JSONObject must define the constant `OBJECT_MODEL` which implements the JSON object model in ruby. See below for details about the OBJECT_MODEL constant.

Direct subclasses of JSONObject are nearly always used internally in other classes. For example, Jamf location data for a computer or mobile device (username, room number, building etc.) is a Jamf::Location object contained inside a Computer or MobileDevice object.

### Jamf::Resource

This abstarct class is a subclass of JSON object, and represents a resource or endpoint in the API. The code here handles the actual interaction with the API for all resources. Subclasses of Jamf::Resource must define the constants RSRC_VERSION (e.g. 'v1') and RSRC_PATH (e.g. 'buildings') which are used together to create the URI path to the resource.

Jamf::Resource is never subclassed directly. Instead, it has two subclasses that are themselves abstract, representing the two kinds of resources:

### Jamf::SingletonResource

This abstract class represents API resources that are single, persistent sets of values on the server, usually various preferences, settings or static data.  These resources can only be read and updated, never created or deleted.  There is really only one 'instance' of these classes, and When accessed via ruby-jss, they are cached locally to minimize server access, but can be refreshed as needed. Examples include enrollment and reenrollment settings, app store country codes, and timezone data.

### Jamf::CollectionResource

This abstract class represents API resources that are 'collections' - groups of individual objects that have id numbers. Instances of the class represent those individual objects. The code for dealing with the collections as a whole (listing, filtering, searching, fetching, created) are defined here.

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

"There's more than one way to do it" - because context matters.
(If that weren't true, I'd be writing Python)

Each attribute key in OBJECT_MODEL points to a Hash of details defining how the attribute is used in the class. Getters and setters are created from these details, and they are used to parse incoming, and generate outgoing JSON data

The possible keys of the details Hash for each attribute are:

- class:
- identfier:
- required:
- readonly:
- multi:
- enum:
- validator:
- aliases:

For an example of an OBJECT_MODEL hash, see Jamf::MobileDeviceDetails::OBJECT_MODEL

The details for each key's value are as follows. Note that omitting a boolean key is the same as setting it to false.

#### class: \[Symbol or Class]
This is the only required key for all attributes.

JSON primative types are represented by the symbols  :string, :integer, :float, or :boolean. These are the JSON data types that don't need parsing into ruby beyond that done by `JSON.parse`. When processing an attribute with one of these symbols as the `class:`, the JSON value is used as-is.

When this is not a Symbol, it must be an actual class, such as Jamf::Timestamp or Jamf::Location.

Classes used this way _MUST_:

- Have an #initialize method that takes two parameters and performs validation on them:

 The first parameters is positional, and is the value used to create the instance, which accepts, at the very least, the Parsed JSON data for the attribute. This can be a single value (e.g. a string for Jamf::Timestamp), or a Hash (e.g. for Jamf::Location), or whatever. Other values are allowed if your initialize method handles them properly.

 A keyword parameter `cnx:`. This can be ignored if not needed, but #initialize must accept it. If used, it will contain a Jamf::Connection object, either the one from which the first param came, or the one to which we'll be validating or creating a new object.

- Define a #to_jamf method that returns a value that can be used in the data sent back to the API. Subclasses of JSONObject already have this requirement, and the value is a Hash.


Classes used in the class: value of an attribute definition are often also subclasses of JSONObject (e.g. Jamf::Location) but do not have to be as long as they conform to the standards above, e.g. Jamf::Timestamp.

See also: Data Validation below.


#### identifier: \[Boolean, or Symbol :primary]

Only applicable to descendents of Jamf::CollectionResource

If true, this value must be unique among all members of the class in Jamf Pro, and can be used to look up objects.

If the symbol :primary, this is the primary identifier, used in API resource paths for this particular object. This should always be the 'id' attribute, according to the JP-API standards.


#### required: \[Boolean]

If true, this attribute must be provided when creating a new local instance and cannot be set to nil or empty.


#### readonly: \[Boolean]

If true, no setter method(s) will be created, and the value is not sent to the API with #save


#### multi: \[Boolean]

When true, this value comes as a JSON array and its items are defined by the 'class:' setting described above. The JSON array is used to contstruct an attribute array of the correct kind of item.

Example:
> The OBJECT_MODEL for a ComputerGroup might define the 'computers' attribute like this:
>
>         computers: {
>           class: Jamf::Computer::Reference,
>           multi: true
>         }

meaning that the `computers` attribute of a Jamf::ComputerGroup instance will be an array of Jamf::Computer::Reference instances.


The stored array is not directly accessible, the getter will return a frozen duplicate of it.

If not readonly, several setters are created:

- a direct `=` setter which takes an Array of 'class:', replacing the original
- an `attrname_append` method, appends a new value to the array, aliased as `<<`
- an `attrname_prepend` method, prepends a new value to the array
- an `attrname>_insert` method, inserts a new value to the array at the given index
- an `attrname>_delete_at` method, deletes a value at the given index

This protection of the underlying array is needed for two reasons:

1. so ruby-jss knows when changes are made and need to be saved
2. so that validation can be performed on values added to the array.


#### enum: \[Constant -> Array<Constants> ]

This is a constant defined somewhere in the Jamf module. The constant must contain an Array of other Constant values, usually Strings.

Setters for attributes with an enum require that the new value is a member of the enum array.

Example:
> The OBJECT_MODEL for Attribute Jamf::ExtentionAttribute has an attribute `dataType` defined like this:
>
>       dataType: {
>         class: :string,
>         enum: Jamf::ExtentionAttribute::DATA_TYPES
>       }
>
> The constant Jamf::ExtentionAttribute::DATA_TYPES is defined thus:
>
>      DATA_TYPE_STRING = 'STRING'.freeze
>      DATA_TYPE_INTEGER = 'INTEGER'.freeze
>      DATA_TYPE_DATE = 'DATE'.freeze
>
>      DATA_TYPES = [
>        DATA_TYPE_STRING,
>        DATA_TYPE_INTEGER,
>        DATA_TYPE_DATE,
>      ]
>
> When setting the type attribute via `some_ea.dataType = newval`, a validation method will ensure that
>  `Jamf::ExtentionAttribute::DATA_TYPES.include? newval` is true

When using such setters, its wise to use the array members themselves rather than a different but identical string, however either will work.  In other words, this:

    my_ea.dataType = Jamf::ExtentionAttribute::DATA_TYPE_INTEGER

is preferred over:

    my_ea.dataType = 'INTEGER'

since the second version creates a new string in memory, but the first uses
the one already stored in a constant.

See also: [Data Validation](#data_validation) below.

#### validator: \[Symbol]

(ignored if readonly: is true, or if enum: is set)

Data validation can (and should) happen when a setter is used, rather than sending invalid data to the API and getting an error back.

If an enum is defined for an attribute (see above) then that enum is used for validation. If a non-primative class is used for the attribute, e.g. Jamf::Location or Jamf::Timestamp, the initialization method for that class will validate the data used to create it.

But sometimes you'll need other forms of validation to happen, e.g. to ensure that a String is a properly formatted MACaddress.

That's where the Jamf::Validate module, and the `validator` setting come in. The Jamf::Validate module only exists to hold standardized methods for validating values.

The symbol in the `validator` setting is the name of a Jamf::Validators module method used in the setter to validate new values for this attribute. It only is used when class: is :string, :integer, :boolean, and :float

If omitted, and there is no enum defined, the setter will take any value passed to it, which is generally unwise.

Example:
> The `macAddress` attribute of a  MobileDevice might be defined like this:
>
>      macAddress: {
>        class: :string,
>        identifier: true,
>        validator: :mac_address
>      }
>
>  When the setter method for macAddress is defined (`macAddress=(newval)`), that method will include this line:
>
>      newval = Jamf::Validate.mac_address newval
>
> and the `Jamf::Validate.mac_address` method will raise an error if the newval isn't a proper macaddress. If it
> is a valid macaddress, it will be returned.
>
> Some validator methods can take multiple input types or formats, and if the input is valid, will always return a
> standardized value.


#### aliases: \[Array of Symbols]

Other names for this attribute.

If provided, getters, and setters will be made for all aliases. Should be used very sparingly.

Attributes of class :boolean automatically have a getter alias ending with a '?'.

#### Documenting OBJECT_MODEL

For documenting attributes with YARD, put this above each attribute name key:

```
     # @!attribute <attrname>
     #   @param [Class] <Describe setter value if needed>
     #   @return [Class] <Describe value if needed>
```

If the value is readonly, remove the @param line, and add \[r], like this:

```
     # @!attribute [r] <attrname>
```

for more info see https://www.rubydoc.info/gems/yard/file/docs/Tags.md#attribute


#### Sub-subclassing and OBJECT_MODEL

If you need to subclass a subclass of JSONObject, and the new subclass needs to expand on the OBJECT_MODEL in its parent, then you must use Hash#merge to combine them in the subclass. Here's an example of ComputerPrestage which inherits from Prestage:

     class ComputerPrestage < Jamf::Prestage

        OBJECT_MODEL = superclass::OBJECT_MODEL.merge(

              newAttr: {
                [attr details]
              }

          ).freeze


#### Data Validation \{#data_validation}

Attributes that are not readonly are subject to data validation when values are assigned. How that validation happens depends on the definition of the attribute as described above. Validation failure will raise an exception, usually Jamf::InvalidDataError.

If the attribute is defined with an enum, the value must be a key or value of the enum.

If the attribute's class: is defined as a Class, (e.g. Jamf::Timestamp) its .new  method is called with the value and the current API connection. The class itself performs valuation when the value is used to instantiate it.

If the attribute is defined with a validator, the value is passed to that validator.

If the attribute is defined as a :string, :integer, :float or :bool without an enum or validator, it is checked to be the correct type

If an attribute is an identifier, it must be unique in its class and API connection.

#### Constructor / Instantiation

The .new method should rarely (never?) be called directly for any JSONObject
class.

The Resource classes are instantiated via the .fetch and .create methods.

Other JSONObject classes are embedded inside the Resource classes
and are instantiated while parsing data from the API or by the setters for
the attributes holding them, or via setters in the objects containing them.

When subclassing JSONObject, you can often just use the #initialize defined
there. You may want to override #initialize to accept different kinds of data
and if you do, you _must_:

- Have an #initialize method that takes two parameters and performs
 validation using them:

 1. A positional first parameter: the value used to create the instance
    Your method may accept any kind of value, as long as it can use it
    to create a valid object. At the very least it _must_ accept a Hash
    that comes from the API for this object. If you call `super` then
    that Hash must be passed.

    For example, Jamf::GenericReference, which defines references to
    other resources, such as Buildings, can take a Hash containing the
    name: and id: of the building (as provided by the API), or can take
    just a name or id, or can take a Jamf::Building object.

    The initialize method must perform validation as necessary and raise
    an exception if the data provided is not acceptable.

 2. A keyword parameter `cnx:` containing a Jamf::Connection instance.
    This is the API connection through which this JSON object interacts
    with the appropriate Jamf Pro server. Usually this is used to validate
    the data recieved in the first positional parameter.

### Required Instance Methods

Subclasses of JSONObject must have a #to_jamf method.
For most simple objects, the one defined in JSONObject will work as is.

If you need to override it, it _must_

- Return a Hash that can be used in the data sent back to the API.
- Not call #.to_json. All conversion to and from JSON happens in the
 Jamf::Connection class.




## Autoloading

Since the number of classes is so huge, and they aren't always needed in any given project, the Jamf module is using ruby's autoloading feature to load most of the files only as they are used.  See the file .../lib/jamf.rb  to see how that all works



# More to come.....
