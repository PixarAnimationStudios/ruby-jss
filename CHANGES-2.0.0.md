# ruby-jss 2.0: Combined access to the Classic and Jamf Pro APIs

Version 2.0.0 is a major refactoring of ruby-jss. While attempting to provide as much backward compatibility as possible, there are some significant changes under the hood. **_PLEASE TEST YOUR CODE EXTENSIVELY_**

This document discusses the major changes, attempts to list the changes that have already happened, as well as planned changes and deprecations. It also provides some discussion and background for the changes.

These changes have been in mind for some time, but the ability (soon to be requirement) for the Classic API authenticate with Bearer Tokens from the Jamf Pro API means that the time has come, so here we are!

**CONTENTS**

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Requirements](#requirements)
- [Ruby 3.x support](#ruby-3x-support)
- [Combined API access](#combined-api-access)
	- [A single Connection class](#a-single-connection-class)
		- [Connecting to the API](#connecting-to-the-api)
			- [The default connection](#the-default-connection)
	- [A single namespace `Jamf`](#a-single-namespace-jamf)
		- [Inherant differences between the APIs](#inherant-differences-between-the-apis)
			- [Which API does an object come from?](#which-api-does-an-object-come-from)
- [Automatic code generation](#automatic-code-generation)
- [Autoloading of files](#autoloading-of-files)
- [Specific changes from ruby-jss 1.x](#specific-changes-from-ruby-jss-1x)
	- [Paged queries to the Jamf Pro API](#paged-queries-to-the-jamf-pro-api)
	- [API data are no longer cached](#api-data-are-no-longer-cached)
- [Planned deprecations](#planned-deprecations)
	- [Use of the term 'api' in method names, parameter names, and attributes](#use-of-the-term-api-in-method-names-parameter-names-and-attributes)
	- [`#map_all_ids_to` method for Classic API collection classes](#mapallidsto-method-for-classic-api-collection-classes)
	- [Using `.make`, `#create`, and `#update` for Classic API objects](#using-make-create-and-update-for-classic-api-objects)

<!-- /TOC -->


## Requirements

ruby-jss 2.0.0 requires ruby 2.7, and a Jamf Pro server running version 10.35 or higher.

## Ruby 3.x support

The plan is for ruby-jss 2.0+ to be compatible with ruby 3.x.

As of this writing, no work towards this has been done, but it's next up after getting everything else mentioned here ready for beta-testing in ruby 2.7.

## Combined API access

ruby-jss has always used the `JSS` module to encapsulate all access to the Classic API. When the Jamf Pro API became a thing, the `Jamf` module was created as the way to interact with that API as it grew and developed.

Even though the latest Jamf Pro release notes say the Jamf Pro API is still officially "open for user testing", it has stablized enough that it is used by many folks for production work.

The announcement with Jamf Pro 10.35 that the Classic API can use, and will eventually require, a Bearer Token from the Jamf Pro API meant that it was time to merge the two in ruby-jss.

### A single Connection class

There is now one `Jamf::Connection` class, instances of which are connections to a Jamf Pro server. Once connected, the connection instance maintains connections to _both_ APIs and other classes use them as needed. As before, there are low-level methods available for sending HTTP requests manually, which are specific to each API. See the documentation for `Jamf::Connection` (link TBA) for details.

#### Connecting to the API

Most of the previous methods and parameters for making API connections to either API should still work, including using a URL rather than individual connection parameters. So both of these are valid and identical:

```ruby
a_connection = Jamf::Connection.new 'https://apiuser@my.jamf.server:8443/', pw: :prompt

another_connection = Jamf::Connection.new host: 'my.jamf.server', port: 8443, user: 'apiuser', pw: :prompt
```

Other connection parameters can be passed in as normal.

##### The default connection

The top-level module methods for accessing the 'default' connection are still available and are now synonyms: `Jamf.cnx` and `JSS.api` both return the current default Jamf::Connection instance. There is also a top-level methods`Jamf.connect` which is the same as `Jamf.cnx.connect`. The top-level methods for changing the default connection are still there. The use of `JSS::API` has been deprecated for years now, and still is (see below).

### A single namespace `Jamf`

Version 2.0.0 combines the `JSS` module and the `Jamf` module into a single `Jamf` module, with `JSS` aliased to it. This means you can use them interchangably to refer to the Jamf module, and existing code that used either should still work. The module name no longer indicates which API you're working with.

For example, the `JSS::Computer` class, from the Classic API, is still a thing, but now just points to the `Jamf::Computer` class, still from the Classic API.  The `Jamf::InventoryPreloadRecord` class, from the Jamf Pro API remains as is, but can also be referred to as `JSS::InventoryPreloadRecord`

#### Inherant differences between the APIs

In theory, you shouldn't need to worry about which classes and objects come from which API - you can just `.fetch`, `.create`, `.save`, etc.. and ruby-jss will deal with the API interaction for you.

However, in reality the two APIs have different functionality, some of which must be reflected in the ruby classes that represent objects in those APIs.

Take, for example, the classes for 'Collection Resources' - API endpoints that let you deal with collections of objects like Computers, or Inventory Preload Records.  These classes implement a `.all` class method, which retrieves a list of some data about all members of the collection.

Not only is the data returned in such lists very different between the APIs, but in the Jamf Pro API, you can ask the server to return the list already sorted, possibly filtered, or 'paged' in groups of some number of items. None of that is possible in the Classic API.

The `.all` method, and its relatives like `.all_ids`, `.all_names`, etc. exist for Collection Resources in both APIs, but the methods take different parameters, e.g. to deal with sorting and filtering. Jamf Pro API classes have a `.pager` method which returns an object from which you can retrieve the 'pages' of your query.

##### Which API does an object come from?

To confirm which API an class comes from, just look at its `API_SOURCE` constant, e.g. `Jamf::Computer::API_SOURCE`. This constant will return a symbol, either `:classic` or `:jamf_pro`

## Automatic code generation

While the Classic API classes in ruby-jss are very hand-built and must be manually edited to add access to new data, the Jamf Pro API has an OpenAPI3 specification - a JSON document that fully describes the entire API and what it can do.

The API documentation you see at your own Jamf Pro server at https://your.jamf.server/api/doc/ is generated from the OAPI specification. The specification itself can be seen at https://your.jamf.server/api/schema.

In ruby-jss 2.0 and up, the OAPI spec is used to automatically generate hundreds of 'base' classes in ruby-jss, each with automatically generated attribute getters, setters, validators, and other useful methods. These base classes can then be used as the superclasses of the Jamt Pro API objects we implement for direct use in ruby-jss - and the majority of the coding is already done! The subclasses implementing objects in ruby-jss can then be expanded and customized beyond the simple, auto-generated superclass.

Not only does this make it fast and simple to implement new objects in ruby-jss, but allows fast and simple updates to existing objects, when new functionality is introduced to the API.

If you develop ruby-jss, please see (documentation link TBA) for more info about how to use the auto-generated classes.

## Autoloading of files

Because the classes generated from the OAPI spec number in the hundreds, it's a waste of memory and time to load all of them in every time you `require ruby-jss`, since most of them will never be used for any given application.

To deal with this, ruby-jss now uses the wonderfully cool [Zeitwerk gem](https://github.com/fxn/zeitwerk) to automatically load only the files needed for classes and modules as they are used.

In fact, if you'd like to see it in action, just `touch /tmp/ruby-jss-verbose-loading` or `export RUBY_JSS_VERBOSE_LOADING=1` before you `require ruby-jss`.
Then as files load, lines will be written to standard error indicating:

  - Zeitwerk just loaded something from a file
  - A module was mixed-in to some other module or class
  - A method was just automatically defined

## Specific changes from ruby-jss 1.x

### Paged queries to the Jamf Pro API

In the previous Jamf module, to get paged API results from a list of all objects in a collection, you would use the `page_size:` and `page:` parameters to the `.all` class method, and then use `.next_page_of_all` to get subsequent pages. Unfortunately the way this happened was not threadsafe.

Now to get paged results, use the `.pager` class method, optionally sorted and filtered, as with `.all`. You'll be given a `Jamf::Pager` object, which you can then use to retrieve sequential or arbitrary pages from the query.

The `.all` method will never deliver paged results, however if you give it a `filter` parameter for classes that support filtering, then `.all` returns "all that match the filter", which may be fewer than the entire collection.

### API data are no longer cached

NOTE: As of this writing, caching has been removed for the objects from the Jamf Pro API, but caching remains in the Classic API. Its removal, or the re-instatement of caching for JP API objects, are pending discussion with users of ruby-jss.

Pre-2.0, methods that would fetch large datasets from the server would always cache that data in the Connection object, and by default use the cache in future calls unless a `refresh` parameter is given. These datasets included:

- collection lists, used by `.all` and friends, like `.all_ids` and `.valid_id`
- EA definitions, used for validating Extension Attribute values

In 2.0+, that caching has been removed. If you want to avoid repeated GET requests to the server when you aren't worried that the resulting data may have changed, you can store the results of `.all` in a variable, and either use it yourself, or pass it in to other methods via the `cached_list:` parameter. Passing in a cached_list wil prevent those methods from calling `.all` and reaching out to the server again.

**WARNING**: Be careful that the list you pass in via `cached_list` contains the correct data structure for the class, and came from the desired Connection instance.


## Planned deprecations

### Use of the term 'api' in method names, parameter names, and attributes

Use `cnx` instead. Example:

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

In ruby-jss < 2.0, the term `api` is used with the Classic API in method names, method parameters, instance variables, attributes, and constants. It is used to pass, access, or hold instances of JSS::APIConnnection, e.g. so a method that talks to the server would use the passed connection rather than the module-wide default connection.  But, the thing being passed is a 'connection' not an 'API', and now that there are actually two APIs at play, that usage is even less appropriate.

The Original Jamf module, which accessed only the Jamf Pro API, has always used the better-suited abbreviation `cnx` for this, and now that is standard everywhere. For now `api` should continue to work, but it will be removed 'eventually', so please start changing your code now.

Accordingly, `JSS::API` (which should never have been a constant to begin with) is also deprecated. To access the default connection, use `Jamf.cnx`

### `#map_all_ids_to` method for Classic API collection classes

The `map_all_ids_to` method for the Classic API collection classes has been superceded by the more flexible `map_all` method, bringing it in-line with the Jamf Pro API classes.

For now `map_all_ids_to` still works, however it's just a wrapper for `map_all`. Eventually the older method will be removed.

### Using `.make`, `#create`, and `#update` for Classic API objects

Use `.create` and `#save` instead, as with the Jamf Pro API objects

In previous ruby-jss, both APIs avoided the use of the ruby-standard `.new` on Collection Resource classes, because the word 'new' in this context is ambiguous: are you creating a new instance of the class in ruby (which might already exist on the server), or are you creating a new object in Jamf Pro that doesn't yet exist on the server?

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

This also should never have been a constant.  Use Jamf.config.  JSS::CONFIG will go away eventually.

### Jamf::Connection instance methods `#next_refresh`, `#secs_to_refresh`, &  `#time_to_refresh`

These values are actually part of the token used by the connection, not the conection itself. Replace them with `#token.next_refresh`, `#token.secs_to_refresh`, & `#token.time_to_refresh`
