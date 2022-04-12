# ruby-jss 2.0: Combined access to the Classic and Jamf Pro APIs

Version 2.0.0 is a major refactoring of ruby-jss. While attempting to provide as much backward compatibility as possible, there are some significant changes under the hood and v2.0.0 is not fully backward compatible. **PLEASE TEST YOUR CODE EXTENSIVELY**

This document discusses the major changes

attempts to list the changes that have already happened, as well as planned changes and deprecations. It also provides some discussion and background for the changes.

Contents:

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Combined access to both APIs.](#combined-access-to-both-apis)
	- [A single Connection class](#a-single-connection-class)
		- [Connecting to the API](#connecting-to-the-api)
	- [A single namespace `Jamf`](#a-single-namespace-jamf)
		- [Inherant differences between the APIs](#inherant-differences-between-the-apis)
			- [Which API does an object come from?](#which-api-does-an-object-come-from)
- [Automatic code generation](#automatic-code-generation)
- [Autoloading of files](#autoloading-of-files)
- [Specific changes from ruby-jss 1.x](#specific-changes-from-ruby-jss-1x)
	- [JSS::API is gone](#jssapi-is-gone)
	- [Paged queries to the Jamf Pro API](#paged-queries-to-the-jamf-pro-api)
	- [API data are not cached for the Jamf Pro API](#api-data-are-not-cached-for-the-jamf-pro-api)

<!-- /TOC -->

## Combined access to both APIs.

The ruby-jss has always used the `JSS` module to encapsulate all access to the Classic API. When the Jamf Pro API became a thing, the `Jamf` module was created as the way to interact with that API as it grew and developed.

Even though the latest Jamf Pro release notes say the Jamf Pro API is still officially "open for user testing", it has stablized enough that it is used by many folks for production work.

The announcement with Jamf Pro 10.35 that the Classic API can use, and will eventually require, a Bearer Token from the Jamf Pro API meant that it was time to merge the two in ruby-jss.

### A single Connection class

There is now one `Jamf::Connection` class, instances of which are connections to a Jamf Pro server. Once connected, the connection instance maintains connections to _both_ APIs and other classes use them as needed. As before, there are low-level methods available for sending HTTP requests manually, which are specific to each API. See the documentation for `Jamf::Connection` (link TBA) for details.

#### Connecting to the API

Most of the previous methods for making API connections should still work, with the exception of the former JSS::API constant.

The top level methods for accessing the 'default' connection are still available and are now synonyms: `Jamf.cnx` and `JSS.api` both return the current default Jamf::Connection instance.

### A single namespace `Jamf`

Version 2.0.0 combines the `JSS` module and the `Jamf` module into a single `Jamf` module, with `JSS` aliased to it. This means you can use them interchangably to refer to the Jamf module, and existing code that used either should still work. The module name no longer indicates which API you're working with.

For example, the `JSS::Computer` class, from the Classic API, is still a thing, but now just points to the `Jamf::Computer` class, still from the Classic API.  The `Jamf::InventoryPreloadRecord` class, from the Jamf Pro API remains as is, but can also be referred to as `JSS::InventoryPreloadRecord`

#### Inherant differences between the APIs

In theory, you shouldn't need to worry about which classes and objects come from which API - you can just `.fetch`, `.create`, `.save`, etc.. and ruby-jss will deal with the API interaction for you.

However, in reality the two APIs have different functionality, some of which must be reflected in the ruby classes that represent objects in those APIs.

Take, for example, the classes for 'Collection Resources' - API endpoints that let you deal with collections of objects like Computers, or Inventory Preload Records.  These classes implement a `.all` class method, which retrieves a list of some data about all members of the collection.

Not only is the data returned in such lists very different between the APIs, but in the Jamf Pro API, you can ask the server to return the list sorted, or sometimes filtered, or 'paged' in groups of some number of items.

The `.all` method, and its relatives like `.all_ids`, `.all_names`, etc. exist for Collection Resources in both APIs, but the methods take different parameters, e.g. to deal with sorting and filtering.  For paged lists of resources, Jamf Pro API classes have a `.pager` method which returns an object from which you can retrieve the 'pages' of your query.

##### Which API does an object come from?

To confirm which API an class comes from, just look at its `API_SOURCE` constant, e.g. `Jamf::Computer::API_SOURCE`. This constant will return a symbol, either `:classic` or `:jamf_pro`


## Automatic code generation

While the Classic API classes in ruby-jss are very hand-built and must be manually edited to add access to new data, the Jamf Pro API has an OpenAPI3 specification - a JSON document that fully describes the entire API and what it can do.

The API documentation you see at your own Jamf Pro server at https://your.jamf.server/api/doc/ is generated from the OAPI specification. The specification itself can be seen at https://your.jamf.server/api/schema.

The OAPI spec is also used to automatically generate hundreds of 'base' classes in ruby-jss, each with automatically generated attribute getters, setters, validators, and other useful methods. These base classes can then be used as the superclasses of the Jamt Pro API objects we implement for direct use in ruby-jss - and the majority of the coding is already done!

Not only does this make it fast and simple to implement new objects in ruby-jss, but allows fast and simple updates to existing objects, when new functionality is introduced to the API.


## Autoloading of files

## Specific changes from ruby-jss 1.x

### JSS::API is gone

### Paged queries to the Jamf Pro API

### API data are not cached for the Jamf Pro API

- collection lists
- EA definitions
- singleton resources
