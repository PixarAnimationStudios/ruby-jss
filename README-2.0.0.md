# ruby-jss 2.0: Combined access to the Classic and Jamf Pro APIs

Version 2.0.0 is a major refactoring of ruby-jss. While attempting to provide as much backward compatibility as possible, there are some significant changes under the hood. **_PLEASE TEST YOUR CODE EXTENSIVELY_**

This document discusses the high-level changes, a few specific changes that have already happened, as well as planned changes and deprecations. It also provides some discussion and background around all of this. 

This is a work-in-progress at the moment, and will probably remain so well after initial release. Hopefully this document will prompt discussion and decision-making in the [#ruby-jss channel of Macadmins Slack](https://macadmins.slack.com/archives/C03C7F563MK) (Please join us!)

These changes have been in mind for some time, but the requirement in late 2022 for the Classic API to authenticate with Bearer Tokens from the Jamf Pro API means that the time has come, so here we are!

**CONTENTS**

<!-- TOC -->

- [Requirements](#requirements)
- [High level changes](#high-level-changes)
  - [Ruby 3.x support](#ruby-3x-support)
  - [Combined API access](#combined-api-access)
    - [A single Connection class](#a-single-connection-class)
      - [Connecting to the API](#connecting-to-the-api)
        - [The default connection](#the-default-connection)
    - [A single namespace Jamf](#a-single-namespace-jamf)
      - [Inherant differences between the APIs](#inherant-differences-between-the-apis)
      - [Which API does an object come from?](#which-api-does-an-object-come-from)
  - [Automatic code generation](#automatic-code-generation)
  - [Autoloading with Zeitwerk](#autoloading-with-zeitwerk)
- [Known Breaking Changes](#known-breaking-changes)
- [Notable changes from ruby-jss 1.x](#notable-changes-from-ruby-jss-1x)
  - [Paged queries to the Jamf Pro API](#paged-queries-to-the-jamf-pro-api)
  - [API data are no longer cached ?](#api-data-are-no-longer-cached-)
  - [No Attribute aliases for Jamf Pro API objects](#no-attribute-aliases-for-jamf-pro-api-objects)
  - [Class/Mixin hierarchy for Jamf Pro API objects](#classmixin-hierarchy-for-jamf-pro-api-objects)
  - [Support for 'Sticky Sessions' in Jamf Cloud](#support-for-sticky-sessions-in-jamf-cloud)
  - [The valid_id method for Classic API collection classes](#the-valid_id-method-for-classic-api-collection-classes)
- [Planned deprecations](#planned-deprecations)
  - [Use of the term 'api'](#use-of-the-term-api)
  - [map_all_ids_to method for Classic API collection classes](#map_all_ids_to-method-for-classic-api-collection-classes)
  - [Using .make, #create, and #update for Classic API objects](#using-make-create-and-update-for-classic-api-objects)
  - [JSS::CONFIG](#jssconfig)
  - [Jamf::Connection instance methods #next_refresh, #secs_to_refresh, &  #time_to_refresh](#jamfconnection-instance-methods-next_refresh-secs_to_refresh---time_to_refresh)
  - [Cross-object validation in setters](#cross-object-validation-in-setters)
  - [fetch :random](#fetch-random)
- [Documentation](#documentation)
- [How to install for testing](#how-to-install-for-testing)
- [Contact](#contact)

<!-- /TOC -->

## Requirements

ruby-jss 2.0,0 requires ruby 2.6.3 or higher, and a Jamf Pro server running version 10.35 or higher.

This means it will work with the OS-supplied /usr/bin/ruby in macOS 10.15 Catalina and above, until Apple removes ruby from the OS.

## High level changes

### Ruby 3.x support

The plan is for ruby-jss 2.0+ to be compatible with ruby 2.6.3 and higher, including ruby 3.x

As of this writing, basic access to the API seems to be working in ruby 3, but much much more testing is needed.

It looks like the biggest changes have been dealing with keyword arguments as Hashs.  Methods defined with `def methodname([...] foo = {})` need to be changed to `def methodname([...] **foo)` and calls to those methods, even in your own code, need to be changed to `methodname([...] **foo)` when `foo` is a hash of keyword args.

**IMPORTANT**: This may be a breaking change. Do not pass raw hashes as 'keyword' args. Instead use the double-splat: `methodname(**hash)` which should be compatible with ruby 3.x and 2.6.x

For more info see [Separation of positional and keyword arguments in Ruby 3.0](https://www.ruby-lang.org/en/news/2019/12/12/separation-of-positional-and-keyword-arguments-in-ruby-3-0/)

### Combined API access

Previous versions of ruby-jss used the `JSS` module to encapsulate all access to the Classic API. When the Jamf Pro API became a thing, it was a vary different beast, so the `Jamf` module was created as the way to interact with that API as it grew and developed.

Even though the latest Jamf Pro release notes say the Jamf Pro API is still officially "open for user testing", it has stablized enough that it is used by many folks for production work.

The announcement with Jamf Pro 10.35 that the Classic API can use, and will eventually require, a Bearer Token from the Jamf Pro API meant that it was time to merge the two in ruby-jss.

#### A single Connection class

There is now one `Jamf::Connection` class, instances of which are connections to a Jamf Pro server. Once connected, the connection instance maintains connections to _both_ APIs and other classes use them as needed. As before, there are low-level methods available for sending HTTP requests manually, which are specific to each API. See the documentation for [Jamf::Connection](https://www.rubydoc.info/gems/ruby-jss/Jamf/Connection) for details.

##### Connecting to the API

Most of the previous methods and parameters for making connections to either API should still work, including using a URL rather than individual connection parameters. So both of these are valid and identical:

```ruby
a_connection = Jamf::Connection.new 'https://apiuser@my.jamf.server:8443/', pw: :prompt

another_connection = Jamf::Connection.new host: 'my.jamf.server', port: 8443, user: 'apiuser', pw: :prompt
```
Other connection parameters can be passed in as normal.

###### The default connection

The top-level module methods for accessing the 'default' connection are still available and are now synonyms: `Jamf.cnx` and `JSS.api` both return the current default Jamf::Connection instance. There is also a top-level method`Jamf.connect` which is the same as `Jamf.cnx.connect`. The top-level methods for changing the default connection are still there. 

NOTE: The use of `JSS::API` has been deprecated for years now, and still is (see below).

#### A single namespace `Jamf`

Version 2.0.0 combines the `JSS` module and the `Jamf` module into a single `Jamf` module, with `JSS` aliased to it. This means you can use the names interchangably to refer to the Jamf module, and existing code that used either should still work. The module name no longer indicates which API you're working with.

For example, the `JSS::Computer` class, from the Classic API, is still a thing, but now just points to the `Jamf::Computer` class, still from the Classic API.  The `Jamf::InventoryPreloadRecord` class, from the Jamf Pro API remains as is, but can also be referred to as `JSS::InventoryPreloadRecord`

##### Inherant differences between the APIs

In theory, you shouldn't need to worry about which classes and objects come from which API - you can just `.fetch`, `.create`, `.save`, etc.. and ruby-jss will deal with the API interaction for you.

However, in reality the two APIs have different functionality, some of which must be reflected in the ruby classes that represent objects in those APIs.

Take, for example, the classes for 'Collection Resources' - API endpoints that let you deal with collections of objects like Computers, or Inventory Preload Records.  These classes implement a `.all` class method, which retrieves an Array of some data about all members of the collection.

Not only is the data returned in such Arrays very different between the APIs, but in the Jamf Pro API, you can ask the server to return the list already sorted, possibly filtered, or 'paged' in groups of some number of items. None of that is possible in the Classic API.

The `.all` method, and its relatives like `.all_ids`, `.all_names`, etc. exist for Collection Resources in both APIs, but the methods take different parameters, e.g. to deal with sorting and filtering. Jamf Pro API classes have a `.pager` method which returns an object from which you can retrieve the 'pages' of your query.

##### Which API does an object come from?

To confirm which API a class comes from, just look at its `API_SOURCE` constant, e.g. `Jamf::Computer::API_SOURCE`. This constant will return a symbol, either `:classic` or `:jamf_pro`

### Automatic code generation
---
**UPDATE** 

As of version 4.2.0, the auto-generated class definitions will only be used as a starting point for more bespoke, hand-maintained classes. This is due to ongoing inconsistencies across the Jamf Pro API, and occasional name-clashes.
See the Deprecations section for version 4.2.0 in the [CHANGES](CHANGES.md) file for a longer explaination.

---

While the Classic API classes in ruby-jss are very hand-built and must be manually edited to add access to new data, the Jamf Pro API has an OpenAPI3 specification - a JSON document that fully describes the entire API and what it can do.

The API documentation you see at your own Jamf Pro server at https://your.jamf.server/api/doc/ is generated from the OAPI specification. The specification itself can be seen at https://your.jamf.server/api/schema.

In ruby-jss 2.0 and up, the OAPI spec is used to automatically generate hundreds of 'base' classes in ruby-jss, each with automatically generated attribute getters, setters, validators, and other useful methods. These base classes can then be used as the superclasses of the Jamt Pro API objects we implement for direct use in ruby-jss - and the majority of the coding is already done! The subclasses implementing objects in ruby-jss can then be expanded and customized beyond the simple, auto-generated superclass.

Not only does this make it fast and simple to implement new objects in ruby-jss, but allows fast and simple updates to existing objects, when new functionality is introduced to the API. 

Hopefully it will also allow a single version of ruby-jss to work with a wide range of Jamf Pro versions, as API endpoint versions are added and deprecated (details of how that'll work are TBD)

If you develop ruby-jss, please see (documentation link will go here) for more info about how to use the auto-generated classes, or reach out to us. (See [Contact](#contact), below)

### Autoloading with Zeitwerk

Because ruby-jss implements so many classes and modules, it's a waste of memory and time to load all of them in every time you `require 'ruby-jss'`, since most of them will never be used for any given application.

To deal with this, ruby-jss now uses the wonderfully cool [Zeitwerk gem](https://github.com/fxn/zeitwerk) to automatically load only the files needed for classes and modules as they are used.

In fact, if you'd like to see it in action, just `touch /tmp/ruby-jss-verbose-loading` or `export RUBY_JSS_VERBOSE_LOADING=1` before you `require ruby-jss`.
Then as files load, lines will be written to standard error indicating:

  - Zeitwerk just loaded something from a file
  - A module was mixed-in to some other module or class
  - A method was just automatically defined

## Known Breaking Changes

So far we've only uncovered a few areas where our ruby-jss 1.x code didn't work with ruby-jss 2.0.0

- Using unsplatted Hashes as 'named parameters' to method calls. 
  - See [Ruby 3.x support](#ruby-3x-support) above

- Jamf Pro API objects no longer have aliases for their attributes
  - See [No Attribute aliases for Jamf Pro API objects](#no-attribute-aliases-for-jamf-pro-api-objects) below

- Subclassing ruby-jss classes in your own code.
  - Those classes, and methods called on them, may need to be updated to match the new ruby-jss classes, in order to maintain _their_ backward compatibility.

- If you make calls to Classic API's `.valid_id` class method for collection classes, and you pass in an integer as a String, e.g. '1234', expecting to get the valid id of the object with the _name_ or _serial_number_ '1234' you will now get back the id 1234 if there is an object with that id. That may not be the id of the object you were looking for.
  - See [The valid_id method for Classic API collection classes](#the-valid_id-method-for-classic-api-collection-classes) below for details and how to do such a validation now.

## Notable changes from ruby-jss 1.x

### Paged queries to the Jamf Pro API

In the previous Jamf module, to get paged API results from a list of all objects in a collection, you would use the `page_size:` and `page:` parameters to the `.all` class method, and then use `.next_page_of_all` to get subsequent pages. Unfortunately the way this happened was not threadsafe.

Now to get paged results, use the `.pager` class method, optionally sorted and filtered, as with `.all`. You'll be given a `Jamf::Pager` object, which you can then use to retrieve sequential or arbitrary pages from the query.

The `.all` method will never deliver paged results, however if you give it a `filter` parameter for classes that support filtering, then `.all` returns "all that match the filter", which may be fewer than the entire collection.

### API data are no longer cached (?)

---
**NOTE:** 
Caching has been removed for the objects from the Jamf Pro API, but remains for those from the Classic API. The re-instatement of caching for JP API objects is pending discussion with other users of ruby-jss.

---

Pre-2.0, methods that would fetch large datasets from the server would always cache that data in the Connection object, and by default use the cache in future calls unless a `refresh` parameter is given. These datasets included:

- collection lists, used by `.all` and friends, like `.all_ids` and `.valid_id`
- Extension Attribute definitions, used for validating Extension Attribute values

In 2.0+, that caching has been removed for objects from them Jamf Pro API.

If you want to avoid repeated GET requests to the server when you aren't worried that the resulting data may have changed, you can store the results of `.all` in a variable, and either use it yourself, or pass it in to other methods via the `cached_list:` parameter. Passing in a cached_list wil prevent those methods from calling `.all` and reaching out to the server again.

**WARNING**: Caching a list yourself and using it with `cached_list` can cause all kinds of problems if you don't ensure these points:
- the cached_list contains the correct data structure for the class
  - i.e. pass in the results of `.all` for that class, not `.all_ids` or other sub-lists.
- the cached_list came from the correct Connection instance
- the cached_list is sufficiently up to date.

### No Attribute aliases for Jamf Pro API objects

In most cases, objects from the Jamf Pro API will no longer define aliases for the attribute names that come from the API itself. This means, e.g., to get the name of a ComputerPrestage or MobileDevicePrestage, you have to ask for its `displayName` not its `name`, since the property comes from the API as `displayName`. To see a list  of all the names, you must use `.all_displayNames` not `.all_names`.  For objects with a 'name' property (most of them) then you can use `.name` and `.all_names`. 

The reason behind this is twofold: 
1) to simplify ruby-jss's code and automate as much as possible
2) to reflect what Jamf actually gives us in the APIs

There may be times when exceptions to this are appropriate. For example, in the Jamf Pro Webapp, the API Roles assigned to API Clients are called 'API Roles' or just 'roles'.  However in the API data for APIClients (which themselves are called APIIntegrations), the roles are called 'authorizationScopes'.  In order to agree with the webapp, the various 'authorizationScopes*' methods have matching 'roles*' aliases.

**IMPORTANT** This is a breaking change from earlier ruby-jss versions, for which Jamf Pro API objects had the potential for aliases of their attribute names.

### Class/Mixin hierarchy for Jamf Pro API objects

If you contribute to ruby-jss, be aware that the structure of superclasses, subclasses, and mixin modules, and their file locations has changed drastically. Also changed is how to implement new objects using the OAPI auto-generated classes. These changes are due to using the auto-generated classes, as well as using Zeitwerk to autoload everything.

There's a lot to document about these changes, and much of the current documentation is out of date, referring to how things were done when the Jamf module was separate and only talked to the Jamf Pro API.

Give us time and we'll get everything updated. In the meantime, feel free to reach out for assistance or questions. (See [Contact](#contact), below)

### Support for 'Sticky Sessions' in Jamf Cloud

If you are connecting to a Jamf Cloud server, you can specifcy `sticky_session: true` when calling `Jamf::Connection.new` or `Jamf::Connection#connect`. If you already have a connected Connection object, you can enable or disable Sticky Sessions using `my_connection_object.sticky_session =` with a boolean value (for the default connection use `Jamf.cnx.sticky_session = <boolean>`). To see the actual cookie being sent to enable sticky sessions, use `Jamf::Connection#sticky_session_cookie`. 

Attempting to enable a sticky session with a connection to an on-prem server (host not ending in 'jamfcloud.com') will raise an error.

For details about Sticky Sessions see [Sticky Sessions for Jamf Cloud](https://developer.jamf.com/developer-guide/docs/sticky-sessions-for-jamf-cloud) at the Jamf Developer site. 

**WARNING:** Jamf recommends NOT using sticky sessions unless they are needed. Using them inappropriately may negatively impact performance, especially for large automated processes.

### The `valid_id` method for Classic API collection classes 

In the Classic API, object ids are Integers, but in the Jamf Pro API, they are Strings containing integers. 

In previous versions of ruby-jss, the `valid_id` class method for the Jamf Pro API will accept Integers and convert them to Strings to search for the valid id. In order to provide the same flexibility, `valid_id` now works the same way for regardless of which API is used.

Previously, the Classic API collection classes would return nil (no match) if you passed in an id as a string, unless you had an object with a name or other identifier with that numeric string value.

So for example, assuming you wanted to find out if the id 1234 was valid, you could do

```ruby
ok_id = JSS::Computer.valid_id 1234
# =>  1234, or nil if 1234 is not a valid id
```

But if you did

```ruby
ok_id = JSS::Computer.valid_id '1234'
# => nil, or the id of a computer _named_ '1234'
# (no computer would have '1234' as a serialnumber, udid, or macaddress)
```
you would likely not get the integer id 1234 back.

In ruby-jss 2.0.0, the valid_id method has changed so that the second example above will return the integer id 1234, if it exists as an id. If not, it will look at other identifiers with the string value, and return the id of any match, or nil if there's no match.

The downside of this is: what if you really _are_ looking for the id of the object with the name '1234'? 

To deal with that situation, the valid_id method for the Classic API now behaves like the one for the Jamf Pro API: it can accept an arbitrary key: value pair, limiting the search to the indentifier used as the key.  

So you can use this to get what you're looking for

```ruby
ok_id = JSS::Computer.valid_id name: '1234'
# => nil, or the id of a computer named '1234'
```

## Planned deprecations

Even though it was publically released in 2014, ruby-jss's origins are from 2009, so it's been around for a while. We've learned a lot since then, and lots of the old lingering code is terribly out of date.

The move to 2.0.0 is our opportunity to start streamlining things and cleaning up not just the code, but how it's used.

We wanted to make the initial transition to 2.0.0 as backward-compatible as possible, but going forward, a lot of things will be changing or going away. 

All of this is up for discussion! If you have suggestions or ideas for improvement, cleanup, or modernization, or if one of these deprecated items is important to you, [please reach out](#contact) and let us hear your thoughts.

As a side effect of these planned changes, and due to our attempts to adhere to [Semantic Versioning](https://semver.org), you can expect the major version number to start going up faster than it used to.

Here are the things we are planning on removing or changing in the coming months-to-years:

### Use of the term 'api' 

In ruby-jss < 2.0, the term `api` is used with the Classic API in method names, method parameters, instance variables, attributes, and constants. It is used to pass, access, refer to, or hold instances of JSS::APIConnnection, e.g. so a method that talks to the server would use the passed connection rather than the module-wide default connection.  

The term 'api' is inappropriate because the thing being referred to is a 'connection' not an 'api'. Now that there are actually two APIs at play, that usage is even less appropriate.

Going forward, use `cnx` (simpler to type than 'connection') instead. Example:

```ruby
my_connection = Jamf::Connection.new 'https://user@my.jamf.server:8443/', pw: :prompt

# OLD
JSS::Computer.all_names api: my_connection

# NEW
JSS::Computer.all_names cnx: my_connection

# OLD
comp = JSS::Computer.fetch name: 12, api: my_connection
comp.api # => my_connection

# NEW
comp = JSS::Computer.fetch id: 12, cnx: my_connection
comp.cnx # => my_connection
```

The original Jamf module, which accessed only the Jamf Pro API, has always used the better-suited abbreviation `cnx` for this, and now that is standard everywhere. 

For now `api` should continue to work, but it will be removed 'eventually', so please start changing your code now.

Accordingly, `JSS::API` (which should never have been a constant to begin with) has been deprecated for years in favor of `JSS.api`, which is now also deprecated. To access the default connection, use `Jamf.cnx`

### `.map_all_ids_to` method for Classic API collection classes

The `map_all_ids_to` method for the Classic API collection classes has been superceded by the more flexible `map_all` method, bringing it in-line with the Jamf Pro API classes.

For now `map_all_ids_to` still works, however it's just a wrapper for `map_all`. Eventually the older method will be removed.

### Using `.make`, `#create`, and `#update` for Classic API objects

Use `.create` and `#save` instead, as with the Jamf Pro API objects

All versions of ruby-jss have avoided the use of the ruby-standard `.new` on Collection Resource classes, because the word 'new' in this context is ambiguous: are you creating a new instance of the class in ruby (which might already exist on the server), or are you creating a new object in Jamf Pro that doesn't yet exist on the server?

In v2.0.0 we are standardizing on the behavior of the previous Jamf module:

  - `Jamf::SomeCollectionClass.create` class method for instantiating a ruby object to be added as a new SomeCollectionClass object to Jamf Pro

  - `Jamf::SomeCollectionClass#save` instance method for sending an object to the server to be created OR updated in Jamf pro.
    - Note that `#save` has been available for this use since the earliest versions of ruby-jss.

This means that these deprecated methods will go away for Classic API objects

  - `Jamf::SomeCollectionClass.make` class method for instantiating a ruby object to be added as a new SomeCollectionClass to Jamf Pro
    - use `Jamf::SomeCollectionClass.create` instead

  - `Jamf::SomeCollectionClass#create` instance method for sending a new object to the API to be created on the server.
    - Use `Jamf::SomeCollectionClass#save` instead.
    - Note that `#save` has been a wrapper for both `#create` and `#update` since the earliest versions of ruby-jss.

  - `Jamf::SomeCollectionClass#update` instance method for then sending changes to an existing object to the API to be update on the server.
    - Use `Jamf::SomeCollectionClass#save` instead.
    - Note that `#save` has been a wrapper for both `#create` and `#update` since the earliest versions of ruby-jss.

```ruby
# OLD

# Get a ruby instance of a new policy to be added to Jamf Pro
new_policy = Jamf::Policy.make name: 'my-policy'
# ... set other values for the policy, then
# Create it in Jamf Pro
new_policy.create # new_policy.save has always been a synonym

# fetch an existing policy from the server
existing_policy = Jamf::Policy.fetch name: 'older-policy'
# ... change some values for the policy, then
# Update it in Jamf Pro
existing_policy.update # existing_policy.save has always been a synonym

# NEW

# Get a ruby instance of a new policy to be added to Jamf Pro
new_policy = Jamf::Policy.create name: 'my-policy'
# ... set other values for the policy, then
# Create it in Jamf Pro
new_policy.save

# fetch an existing policy from the server
existing_policy = Jamf::Policy.fetch name: 'older-policy'
# ... change some values for the policy, then
# Update it in Jamf Pro
existing_policy.save
```

### JSS::CONFIG

This should never have been a constant.  Use Jamf.config.  JSS::CONFIG will go away eventually.

### Jamf::Connection instance methods `#next_refresh`, `#secs_to_refresh`, &  `#time_to_refresh`

These values are actually part of the token used by the connection, not the conection itself. Replace them with `#token.next_refresh`, `#token.secs_to_refresh`, & `#token.time_to_refresh`

### Cross-object validation in setters

Most 'setters' (methods that let you set values for the attributes of an object) in ruby-jss perform some kind of validation to make sure the value you're trying to set is valid for that attribute. While still true, in v2.0 and up, this validation will be much more limited, mostly to ensuring the new value is of the correct type, e.g. an integer or a string, or a Jamf::Timestamp.

Objects from the Classic API have also provided validation that goes beyond that - using other API objects as needed to 'pre-validate' your data in the setter method.

For example, If you try to target a Policy scope to a certain ComputerGroup, when you use `my_policy.scope.add_target :computer_group, 1234` ruby-jss will use the Classic API to confirm that there actually is a computer group with the id 1234. If not, it will raise an exception.

Or when you try to set the value of an extension attribute on a Computer object, ruby-jss will retrieve the details of the ComputerExtensionAttribute definition from the api, and make sure that the value you are setting is valid - the data type, and if a Popup Menu is the input, the value is one of the popup choices.

This validation happens before you try to send the new data to the server.

This type of pre-validation will not be use when using the Jamf Pro API, for 3 reasons:

1) The API itself will perform this validation when you send the data, and will return an error if there's a problem.
2) Removing this validation will simplify the code, and reduce interdependency between objects
3) Removing this code will make it easier to understand the permissions needed to do things in ruby-jss, removing 'hidden permissions requirements' when interacting with class-specific API endpoints.

The last point is very important.  Right now, in order to be able to manipulate the scope of any scopable object, the account with which you're accessing the API must have at least 'read' permission on all the different kinds of objects that _might_ be in the scope: computers, computer groups, buildings, departments, network segments, and so on. Removing or limiting the validation-based interdependency will make it easier to limit the access needed for API service accounts, and thereby increase overall security.

### .fetch :random

You can still fetch random objects from a collection, but use `.fetch random: true`. The older `.fetch :random` is deprecated and will be removed.

## Documentation

The YARD documentation for v2.0.0 is available before release in the [github.io site for ruby-jss](http://pixaranimationstudios.github.io/ruby-jss/docs/v2.x/index.html).

All the documentation for ruby-jss is in serious need of updating, from the top-level README to the auto-generated YARD docs. Forgive us while we slowly get it up to snuff. If you have questions that aren't answered there, please reach out (see [Contact](#contact), below)

## How to install for testing

`gem install ruby-jss --version 2.0.0xy`

where x is 'a' or 'b', and y is the alpha or beta number

You can also clone the GitHub repo, cd into the top level of the project and run `gem build ruby-jss.gemspec`, then install the resulting gem.

Check GitHub or rubygems.org to make sure you have the lastest test version.

## Contact

If you have questions or feedback about all this, please reach out in the [#ruby-jss channel of Macadmins Slack](https://macadmins.slack.com/archives/C03C7F563MK), or open an issue on GitHub, or email ruby-jss@pixar.com.
