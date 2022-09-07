# ruby-jss: Working with the Jamf Pro APIs in Ruby
[![Gem Version](https://badge.fury.io/rb/ruby-jss.svg)](http://badge.fury.io/rb/ruby-jss)

## Version 2.0.0 has been released

Version 2.0.0 has major changes! While we've strived for backward compatibility, and have done lots of testing, YMMV.  Please report any issues.

### Highlights

- Support for Ruby 3.x
  - tested in 3.0 and 3.1
- Combined access to both the Classic and Jamf Pro APIs
  - A single namespace module
  - Connection objects talk to both APIs & automatically handle details like bearer tokens
- Auto-generated code for Jamf Pro API objects
- Autoloading of code using [Zeitwerk](https://github.com/fxn/zeitwerk)

For details about the changes, the document [README-2.0.0.md](README-2.0.0.md).

## _IMPORTANT_: Known Security Issue in v1.5.3 and below

Versions of ruby-jss prior to 1.6.0 contain a known security issue due to how we were using the 'plist' gem.

This has been resolved in 1.6.0, which now uses the CFProperlyList gem.

__Please update all installations of ruby-jss to at least v1.6.0.__

Many many thanks to actae0n of Blacksun Hackers Club for reporting this issue and providing examples of how it could be exploited.

------

# Table of contents

<!-- TOC -->

- [Version 2.0.0 has been released](#version-200-has-been-released)
  - [Highlights](#highlights)
- [_IMPORTANT_: Known Security Issue in v1.5.3 and below](#_important_-known-security-issue-in-v153-and-below)
- [DESCRIPTION](#description)
- [SYNOPSIS](#synopsis)
- [USAGE](#usage)
  - [Connecting to the Server](#connecting-to-the-server)
    - [Using multiple connections](#using-multiple-connections)
  - [Working with Jamf Objects](#working-with-jamf-objects)
    - [Listing Objects](#listing-objects)
    - [Retrieving Objects](#retrieving-objects)
    - [Creating Objects](#creating-objects)
    - [Updating Objects](#updating-objects)
    - [Deleting Objects](#deleting-objects)
- [OBJECTS IMPLEMENTED](#objects-implemented)
    - [Other useful classes & modules:](#other-useful-classes--modules)
- [Object-related API endpoints](#object-related-api-endpoints)
- [CONFIGURATION](#configuration)
  - [Passwords](#passwords)
- [BEYOND THE API](#beyond-the-api)
- [INSTALL](#install)
- [REQUIREMENTS](#requirements)
  - [Contact](#contact)
- [HELP & CONTACT INFO](#help--contact-info)
- [LICENSE](#license)

<!-- /TOC -->

## DESCRIPTION

ruby-jss defines a Ruby module called `Jamf`, which is used for accessing the 'Classic' and 
'Jamf Pro' APIs of a Jamf Pro server. Jamf Pro is an enterprise-level management tool for Apple
devices from [Jamf.com](http://www.jamf.com/).  It is available as a[ruby gem](https://rubygems.org/gems/ruby-jss), and the
[source is on github](https://github.com/PixarAnimationStudios/ruby-jss).

The Jamf module maintains connections to both APIs simultaneously, and uses which ever is appropriate as needed.
Details like authentication tokens, token refreshing, JSON and XML parsing, and even knowing which resources use 
which API are all handled under-the-hood.

The Jamf module abstracts many API resources as Ruby objects, and provides methods for interacting with those
resources. It also provides some features that aren't a part of the API itself, but come with other
Jamf-related tools, such as uploading {Jamf::Package} files to the master distribution
point, and the installation of those objects on client machines. (See [BEYOND THE API](#beyond-the-api))

The Jamf module is not a complete implementation of the Jamf Pro APIs. Only some objects are modeled, 
some only minimally. Of those, some are read-only, some partially writable, some fully read-write. 
We've implemented the things we need in our environment, and as our needs grow, we'll add more.
Hopefully others will find it useful, and add more to it as well.

[Full technical documentation can be found here.](http://www.rubydoc.info/gems/ruby-jss/)

## SYNOPSIS

Here are some simple examples of using ruby-jss

```ruby
require 'ruby-jss'

# Connect to the API
Jamf.cnx.connect "https://#{jamf_user}:#{jamf_pw}@my.jamf.server.com/"

# get an array of basic data about all Jamf::Package objects in Jamf Pro:
pkgs = Jamf::Package.all

# get an array of names of all Jamf::Package objects in the Jamf Pro:
pkg_names = Jamf::Package.all_names

# Get a static computer group. This creates a new Ruby object
# representing the existing Jamf computer group.
mac_group = Jamf::ComputerGroup.fetch name: "Macs of interest"

# Add a computer to the group
mac_group.add_member "pricklepants"

# save changes back to the server
mac_group.save

# Create a new network segment to store on the server.
# This makes a new Ruby Object that doesn't yet exist in Jamf Pro.
ns = Jamf::NetworkSegment.create(
  name: 'Private Class C',
  starting_address: '192.168.0.0',
  ending_address: '192.168.0.255'
)

# Associate this network segment with a specific building,
# which must exist in Jamf Pro, and be listed in Jamf::Building.all_names
ns.building = "Main Office"

# Associate this network segment with a specific software update server,
# which must exist in Jamf Pro, and be listed in Jamf::SoftwareUpdateServer.all_names
ns.swu_server = "Main SWU Server"

# save the new network segment to the server
ns.save
```

## USAGE

### Connecting to the Server

Before you can work with Jamf Pros Objects via the APIs, you have to connect to the server.

The method `Jamf.cnx` returns the 'default' connection object (an instance of a {Jamf::APIConnection}, q.v.). 
A connection object holds all the data needed to communicate with the server to which it's connected, as well as
any data cached from that server. 
The default connection object is used for all communication unless a different one is explicitly passed to methods
that can accept one. See 'Using multiple connections' below.

When the Jamf Module is first loaded, the default connection isn't connected a server. To remedy that, use `Jamf.cnx.connect`,
passing it parameters for the connection. In this example, those parameters are stored in the local variables jss_user, 
jss_user_pw, and jss_server_hostname, and others are left as default.

```ruby
Jamf.cnx.connect user: jss_user, pw: jss_user_pw, server: jss_server_hostname
```

You can also provide a URL, optionally including the credentials, and port number. Any value not available in the URL can be passed as a normal parameter.

```ruby
Jamf.cnx.connect "https://#{jamf_user}@my.jamf.server.com/", pw: jamf_user_pw, port: 8443
```

Make sure the user has privileges in the Jamf to do things with desired objects. Note that these might be more than you think, since some objects refer to other objects, like Sites and Categories.

If the server name given ends with 'jamfcloud.com' the port number will default to 443 via SSL.  Otherwise, it defaults to 8443 with SSL (the default port for on-prem. servers). In other situations, you can specify it with the `port:` and `use_ssl:` parameters.

The connect method also accepts the symbols :stdin and :prompt as values for pw:, which will cause it to read the
password from stdin, or prompt for it in the shell. See the {Jamf::Connection} class for more connection options and details about its methods.

Also see Jamf::Configuration, and the [CONFIGURATION](#configuration) section below, for how to store
server connection parameters in a simple config file.

#### Using multiple connections

Most of the time, you'll only need a single connection to a single server, and the default connection will be sufficient. However 
you can also create multiple Connection objects, to different servers, or perhaps the same server with different credentials and 
access, and pass those connection objects into methods using the `cnx:` parameter as appropriate.

```ruby
# Make connections to 2 different Jamf servers.
# The .new class method accepts the same parameters as the #connect instance method,
# and will automatically pass them to the #connect method when instantiating
# the new connection object.
connection_1 = Jamf::Connection.new user: jss_user, pw: jss_user_pw, server: jss_server_hostname
connection_2 = Jamf::Connection.new user: jss_user2, pw: jss_user_pw2, server: jss_server_hostname2

# Get an array of the serialNumbers from all InventoryPreloadRecords in server 1
ipr_sns_1 = Jamf::InventoryPreloadRecord.all_serialNumbers cnx: connection_1

# Get an array of the serialNumbers from all InventoryPreloadRecords in server 2
ipr_sns_2 = Jamf::InventoryPreloadRecord.all_serialNumbers cnx: connection_2

# Find the SNs that appear in both
common_ipr_sns = ipr_sns_1 & ipr_sns_2
```

### Working with Jamf Objects

All of the ruby classes representing objects in Jamf Pro have common methods for creating, listing, retrieving, updating, and deleting via the API. 
All supported objects can be listed, retrieved and deleted, but only some can be updated or created, mostly becase we haven't needed to do that ourselves
yet and haven't implemented that functionality.  If you need additional features implemented, please get in touch (see 'Contact' above) or feel free to
try implementing it yourself and send us a merge request.

Some of the implemented objects also provide access to more 'functional' API resources. For example, the API resources for 
sending MDM commands to computers and mobile devices are available as class and instance methods of Jamf::Computer and Jamf::MobileDevice, 
as are the API resources for accessing management history.

--------

#### Listing Objects

To get an Array with a summary of every object in the Jamf of some Class, call that Class's .all method:

```ruby
Jamf::Computer.all # => [{:name=>"cephei", :id=>1122},{:name=>"peterparker", :id=>1218}, {:name=>"rowdy", :id=>931}, ...]
```

The Array will contain a Hash for each item, with at least a :name and an :id.  Some classes provide more summary data for each item.
To get just the names or just the ids in an Array, use the .all\_names or .all\_ids Class method

```ruby
Jamf::Computer.all_names # =>  ["cephei", "peterparker", "rowdy", ...]
Jamf::Computer.all_ids # =>  [1122, 1218, 931, ...]
```

Some Classes provide other ways to list objects, or subsets of them, depending on the data available, e.g. Jamf::MobileDevice.all\_udids or Jamf::Computer.all\_laptops

You can also perform simple searches for Jamf::Computer, Jamf::MobileDevice and Jamf::User with the `.match` class method. This is the API equivalent of using the simple search field at the top of the Computers, Devices, or Users pages in the Jamf Pro Web interface. This method will return an Array of Hashes for the matching items. Each Hash is a summary of info about a matching item, similar to the summaries returned by the `.all` methods for those items.

To create, modify, or perform advanced searches, use the classes Jamf::AdvancedComputerSearch, Jamf::AdvancedMobileDeviceSearch, and Jamf::AdvancedUserSearch.

--------

#### Retrieving Objects

To retrieve a single object call the class's `.fetch` method and provide a name:,  id:, or other valid identifier.


```ruby
a_dept = Jamf::Department.fetch name: 'Payroll'# =>  #<Jamf::Department:0x10b4c0818...
```

Some classes can use more than just the :id and name: keys for lookups, e.g. computers can be looked up with udid:, serial_number:, or mac_address:.

You can even fetch objects without specifying the kind of identifier, e.g. `Jamf::Computer.fetch 'VM3X9483HD78'`, but this will be slower, since ruby-jss searches by matching the given value with all available identifiers, returning the first match.

--------

#### Creating Objects

Some Objects can be created anew in the Jamf via ruby. To do so, first make a Ruby object using the class's `.create` method and providing a unique :name:, e.g.

```ruby
new_pkg = Jamf::Package.create name: "transmogrifier-2.3-1.pkg"
```
*NOTE*: some classes require more data than just a name: when created with .create

Then set the attributes of the new object as needed

```ruby
new_pkg.reboot_required = false
new_pkg.category = "CoolTools"
# etc..
```

Then use the #save method to send the data to the API, creating it in Jamf Pro.

```ruby
new_pkg.save # returns 453, the id number of the object just created
```

--------

#### Updating Objects

Some objects can be modified.

```ruby
existing_script = Jamf::Script.fetch id: 321
existing_script.name = "transmogrifier-2.3-1.post-install"
```

After changing any attributes, use the #save method to push the changes to the sever.

```ruby
existing_script.save #  => returns the id number of the object just saved
```

--------

#### Deleting Objects

To delete an object, just call its #delete method

```ruby
existing_script = Jamf::Script.fetch id: 321
existing_script.delete # => true # the delete was successful
```
To delete an object without fetching it, use the class's .delete method and provide the id, or an array of ids.

```ruby
Jamf::Script.delete [321, 543, 374]
```

For more details see the docs for:
- [Jamf::APIObject](http://www.rubydoc.info/gems/ruby-jss/Jamf/APIObject), the parent class of all Classic API resources
- [Jamf::OAPIObject](http://www.rubydoc.info/gems/ruby-jss/Jamf/OAPIObject), the parent class of all Jamf Pro API objects
- [Jamf::CollectionResource](http://www.rubydoc.info/gems/ruby-jss/Jamf/CollectionResource), the parent class of all Jamf Pro API collection resources

See the individual subclasses for any details specific to them.

## OBJECTS IMPLEMENTED

While the API itself supports nearly full CRUD (Create,Read,Update,Delete) for all objects, ruby-jss doesn't yet do so. Why? Because implementing the data validation and other parts needed for creating & updating can be time-consuming and we've focused on what we needed. As we keep developing ruby-jss, this list changes. If you'd like to help implement some of these objects more fully, please fork the github project and reach out to us at ruby-jss@pixar.com.

Here's some of what we've implemented so far. See each Class's [documentation(http://www.rubydoc.info/gems/ruby-jss)] for details.


* {Jamf::AdvancedComputerSearch}
* {Jamf::AdvancedMobileDeviceSearch}
* {Jamf::AdvancedUserSearch}
* {Jamf::Building}
* {Jamf::Category}
* {Jamf::Computer}
* {Jamf::ComputerExtensionAttribute}
* {Jamf::ComputerGroup}
* {Jamf::ComputerInvitation}
* {Jamf::Department}
* {Jamf::DistributionPoint}
* {Jamf::DockItem}
* {Jamf::EBook}
* {Jamf::IBeacon}
* {Jamf::LdapServer}
* {Jamf::MobileDevice}
* {Jamf::MobileDeviceApplication}
* {Jamf::MobileDeviceConfigurationProfile}
* {Jamf::MobileDeviceExtensionAttribute}
* {Jamf::MobileDeviceGroup}
* {Jamf::NetBootServer}
* {Jamf::NetworkSegment}
* {Jamf::OSXConfigurationProfile}
* {Jamf::Package}
* {Jamf::PatchTitle}
* {Jamf::PatchTitle::Version}
* {Jamf::PatchExternalSource}
* {Jamf::PatchInternalSource}
* {Jamf::PatchPolicy}
* {Jamf::Peripheral}
* {Jamf::PeripheralType}
* {Jamf::Policy} (not fully implemented)
* {Jamf::RemovableMacAddress}
* {Jamf::RestrictedSoftware}
* {Jamf::Script}
* {Jamf::Site}
* {Jamf::SoftwareUpdateServer}
* {Jamf::User}
* {Jamf::UserExtensionAttribute}
* {Jamf::UserGroup}
* {Jamf::WebHook}

**NOTE** Most Computer and MobileDevice data gathered by an Inventory Upate (a.k.a. 'recon') is not editable.

#### Other useful classes & modules:

These modules either provide stand-alone methods, or are mixed in to other classes to extend their functionality. See their documentation for details

* {Jamf::Client} - An object representing the local machine as a Jamf-managed client, and provifing Jamf-related info and methods

* {Jamf::ManagementHistory} - a module for handing the management history for Computers and Mobile Devices. It defines many read-only classes representing events in a machine's history. It is accessed via the Computer and MobileDevice classes and their instances.

* {Jamf::Scopable} - a module that handles Scope for those objects that can be scoped. It defines the Scope class used in those objects. Instances of Scope are where you change targets, limitations, and exclusions.

* {Jamf::MDM} - a module that handles sending MDM commands. It is accessed via the Computer and MobileDevice classes and their instances.

## Object-related API endpoints

The classic API provides many endpoints not just for objects stored in Jamf Pro, but also for accessing data *about* those  objects or interacting with the machines they represent. ruby-jss embeds access to those endpoints into their related classes.

For example:

* /computerapplications, /computerapplicationusage, /computerhardwaresoftwarereports, /computerhistory, etc.
  - The data provided by these endpoints are accessible via class and instance methods for {Jamf::Computer}
* /computercheckin, /computerinventorycollection
  - These endpoints deal with server-wide settings regarding computer management, and are available via {Jamf::Computer} class methods
* /computercommands, /mobiledevicecommands, /commandflush, etc.
  - These endpoints provide access to the MDM infrastructure, and can be used to send MDM commands. Ruby-jss provides these as class and instance methods in {Jamf::Computer}, {Jamf::ComputerGroup}, {Jamf::MobileDevice}, and {Jamf::MobileDeviceGroup}

## CONFIGURATION

The {Jamf::Configuration} singleton class is used to read, write, and use site-specific defaults for the Jamf module. When ruby-jss is required, the single instance of {Jamf::Configuration} is created and accessible via the `Jamf.config` method. At that time the system-wide file /etc/ruby-jss.conf is examined if it exists, and the items in it are loaded into the attributes of Configuration instance. The user-specific file ~/.ruby-jss.conf then is examined if it exists, and any items defined there will override those values from the system-wide file.

The values defined in those files are used as defaults throughout the module. Currently, those values are only related to establishing the API connection. For example, if a server name is defined, then a server: does not have to be specified when calling {Jamf::Connection#connect}. Values provided explicitly when calling Jamf::Connection#connect will override the config values.

While the {Jamf::Configuration} class provides methods for changing the values, saving the files, and re-reading them, or reading an arbitrary file, the files are text files with a simple format, and can be created by any means desired. The file format is one attribute per line, thus:

    attr_name: value

Lines that don’t start with a known attribute name followed by a colon are ignored. If an attribute is defined more than once, the last one wins.

The currently known attributes are:

* api_server_name [String] the hostname of the Jamf API server
* api_server_port [Integer] the port number for the API connection
* api_verify_cert [Boolean] 'true' or 'false' - if SSL is used, should the certificate be verified? (usually false for a self-signed cert)
* api_username [String] the Jamf username for connecting to the API
* api_timeout_open [Integer] the number of seconds for the open-connection timeout
* api_timeout [Integer] the number of seconds for the response timeout

To put a standard server & username on all client machines, and auto-accept the Jamf's self-signed https certificate, create the file /etc/ruby-jss.conf containing three lines like this:

```
api_server_name: jamfpro.myschool.edu
api_username: readonly-api-user
api_timeout: 90
```

and then any calls to Jamf.cnx.connect will assume that server and username, and use a timeout of 90 seconds.

### Passwords

The config files don't store passwords and the {Jamf::Configuration} instance doesn't work with them. You'll have to use your own methods for acquiring the password for the Jamf.cnx.connect call.

The {Jamf::APIConnection.connect} method also accepts the symbols :stdin# and :prompt as values for the :pw argument, which will cause it to read the password from a line of stdin, or prompt for it in the shell.

If you must store a password in a file, or retrieve it from the network, make sure it's stored securely, and that the Jamf user has limited permissions.

Here's an example of how to use a password stored in a file:

```ruby
password = File.read "/path/to/secure/password/file" # read the password from a file
Jamf.cnx.connect pw: password   # other arguments used from the config settings
```

And here's an example of how to read a password from a web server and use it.

```ruby
require 'open-uri'
password =  URI.parse('https://server.org.org/path/to/password').read
Jamf.cnx.connect pw: password   # other arguments used from the config settings
```

## BEYOND THE API

While the Jamf Pro APIs provide access to object data in the Jamf, ruby-jss tries to use that data to provide more than just information exchange. Here are some examples of how ruby-jss uses the API to provide functionality found in various Jamf tools:

* Client Machine Access
  * The {Jamf::Client} module provides the ability to run jamf binary commands, and access the local cache of package receipts
* Package Installation
  * {Jamf::Package} objects can be installed on the local machine, from the appropriate distribution point
* Script Execution
  * {Jamf::Script} objects can be executed locally on demand
* Package Creation
  * The {Jamf::Composer} module provides creation of very simple .pkg and .dmg packages
  * {Jamf::Package} objects can upload their .pkg or .dmg files to the master distribution point
* Reporting/AdvancedSearch exporting
  * {Jamf::AdvancedSearch} subclasses can export their results to csv, tab, and xml files.
* MDM Commands
  * {Jamf::MobileDevice}s and {Jamf::Computer}s can be sent MDM commands
* Extension Attributes
  * {Jamf::ExtensionAttribute} work with {Jamf::AdvancedSearch} subclasses to provide extra reporting about Extension Attribute values.

## INSTALL

In general, you can install ruby-jss with this command:

`gem install ruby-jss`

## REQUIREMENTS

ruby-jss 2.0.0 requires:

* Ruby 2.6.3 or higher (the OS-installed ruby version for macOS 10.15 Catalina)
* Jamf Pro server version 10.35 or higher

It also requires other ruby gems, which will be installed automatically if you install with `gem install ruby-jss`
See the .gemspec file for details


### Contact

If you have questions or feedback about ruby-jss, please reach out  to us via:
- The [#ruby-jss channel of Macadmins Slack](https://macadmins.slack.com/archives/C03C7F563MK)
- Open an issue on GitHub
- Email ruby-jss@pixar.com


## HELP & CONTACT INFO

Full documentation is available at [rubydoc.info](http://www.rubydoc.info/gems/ruby-jss/).

There's a [wiki on the github page](https://github.com/PixarAnimationStudios/ruby-jss/wiki), feel free to contribute examples and tidbits.

You can report issues in several ways:
- [Open an issue on github](https://github.com/PixarAnimationStudios/ruby-jss/issues)
- [Email the developers at ruby-jss@pixar.com](mailto:ruby-jss@pixar.com)
- Join the conversation in the [#ruby-jss Macadmins Slack Channel](https://macadmins.slack.com/archives/C03C7F563MK)

## LICENSE

Copyright 2022 Pixar

Licensed under a modified Apache License, Version 2.0. See LICENSE.txt for details
