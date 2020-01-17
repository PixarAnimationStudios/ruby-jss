# ruby-jss: Working with the Jamf Pro Classic API in Ruby
[![Gem Version](https://badge.fury.io/rb/ruby-jss.svg)](http://badge.fury.io/rb/ruby-jss)

### Table of contents
* [DESCRIPTION](#description)
* [SYNOPSIS](#synopsis)
* [USAGE](#usage)
  * [Connecting to the API](#connecting-to-the-api)
  * [Working with JSS Objects (a.k.a REST Resources)](#working-with-jss-objects-aka-rest-resources)
  * [Listing Objects](#listing-objects)
  * [Retrieving Objects](#retrieving-objects)
  * [Updating Objects](#updating-objects)
  * [Deleting Objects](#deleting-objects)
* [OBJECTS IMPLEMENTED](#objects-implemented)
  * [Creatable and Updatable](#creatable-and-updatable)
  * [Updatable but not Creatable](#updatable-but-not-creatable)
  * [Read-Only](#read-only)
  * [Creatable and Updatable](#creatable-and-updatable)
  * [Deletable](#deletable)
* [CONFIGURATION](#configuration)
  * [Passwords](#passwords)
* [BEYOND THE API](#beyond-the-api)
* [REQUIREMENTS](#requirements)
* [INSTALL](#install)
* [HELP](#help)
* [LICENSE](#license)

## DESCRIPTION

ruby-jss defines a Ruby module called JSS, which is used for accessing the 'classic' REST API of
the JAMF Software Server (JSS), the core of Jamf Pro, an enterprise-level management tool for Apple
devices from [Jamf.com](http://www.jamf.com/). It is available as a
[ruby gem](https://rubygems.org/gems/ruby-jss), and the
[source is on github](https://github.com/PixarAnimationStudios/ruby-jss).

The module abstracts many API resources as Ruby objects, and provides methods for interacting with those
resources. It also provides some features that aren't a part of the API itself, but come with other
Jamf-related tools, such as uploading .pkg and .dmg {JSS::Package} data to the master distribution
point, and the installation of {JSS::Package} objects on client machines. (See [BEYOND THE API](#beyond-the-api))

The module is not a complete implementation of the Jamf Pro Classic API. Only some API objects are modeled, some only minimally. Of those, some are read-only, some partially writable, some fully read-write (all implemented objects can be deleted) See [OBJECTS IMPLEMENTED](#objects-implemented) for a list.

We've implemented the things we need in our environment, and as our needs grow, we'll add more.
Hopefully others will find it useful, and add more to it as well.

[Full technical documentation can be found here.](http://www.rubydoc.info/gems/ruby-jss/)

NOTE: ruby-jss 1.2.4 will introduce beta-level support for the Jamf Pro API in a ruby module called 'Jamf', See  README-JP-API.md in /lib/jamf, or in the 'Files' section of the YARD docs file for details.

## SYNOPSIS

Here are some simple examples of using ruby-jss

```ruby
require 'ruby-jss'

# Connect to the API
JSS.api.connect user: jss_user, pw: jss_user_pw, server: jss_server_hostname

# get an array of basic data about all JSS::Package objects in the JSS:
pkgs = JSS::Package.all

# get an array of names of all JSS::Package objects in the JSS:
pkg_names = JSS::Package.all_names

# Get a static computer group. This creates a new Ruby object
# representing the existing JSS computer group.
mg = JSS::ComputerGroup.fetch name: "Macs of interest"

# Add a computer to the group
mg.add_member "pricklepants"

# save changes back to the JSS, mg.update works also
mg.save

# Create a new network segment to store in the JSS.
# This makes a new Ruby Object that doesn't yet exist in the JSS.
ns = JSS::NetworkSegment.make(
  name: 'Private Class C',
  starting_address: '192.168.0.0',
  ending_address: '192.168.0.255'
)

# Associate this network segment with a specific building,
# which must exist in the JSS, and be listed in JSS::Building.all_names
ns.building = "Main Office"

# Associate this network segment with a specific software update server,
#  which must exist in the JSS, and be listed in JSS::SoftwareUpdateServer.all_names
ns.swu_server = "Main SWU Server"

# save the new network segment in the JSS, ns.create works as well
ns.save
```

## USAGE

### Connecting to the API

Before you can work with JSS Objects via the API, you have to connect to it.

The method `JSS.api` returns the currently active connection to the API (an instance of a {JSS::APIConnection}, q.v.).

When the JSS Module is first loaded, that connection object isn't connected to anything. To remedy that, use `JSS.api.connect`, passing it parameters for the connection. In this example, those parameters are stored in the local variables jss_user, jss_user_pw, and jss_server_hostname, and others are left as default.

```ruby
JSS.api.connect user: jss_user, pw: jss_user_pw, server: jss_server_hostname
```

Make sure the user has privileges in the JSS to do things with desired objects. Note that these might be more than you think, since some objects refer to other objects, like Sites and Categories.

If the server name given ends with 'jamfcloud.com' the port number will default to 443 via SSL.  Otherwise, it defaults to 8443 with SSL (the default port for locally-hosted servers). In other situations, you can specify it with the `port:` and `use_ssl:` parameters.

The connect method also accepts the symbols :stdin and :prompt as values for pw:, which will cause it to read the
password from stdin, or prompt for it in the shell. See the {JSS::APIConnection} class for more connection options and details about its methods.

Also see JSS::Configuration, and the [CONFIGURATION](#configuration) section below, for how to store
server connection parameters in a simple config file.

### Working with JSS Objects

All of the ruby classes representing objects in Jamf Pro are subclasse of, or modules within, JSS::APIObject and share methods for creating, listing, retrieving, updating, and deleting via the API. All supported objects can be listed, retrieved and deleted, but only some can be updated or created. See below for the level of implementation of each class.

Some of those objects also provide access to more 'functional' API resources. For example, the API resources for sending MDM commands to computers and mobile devices are available as class and instance methods of JSS::Computer and JSS::MobileDevice, as are the API resources for accessing management history.

--------

#### Listing Objects

To get an Array with a summary of every object in the JSS of some Class, call that Class's .all method:

```ruby
JSS::Computer.all # => [{:name=>"cephei", :id=>1122},{:name=>"peterparker", :id=>1218}, {:name=>"rowdy", :id=>931}, ...]
```

The Array will contain a Hash for each item, with at least a :name and an :id.  Some classes provide more summary data for each item.
To get just the names or just the ids in an Array, use the .all\_names or .all\_ids Class method

```ruby
JSS::Computer.all_names # =>  ["cephei", "peterparker", "rowdy", ...]
JSS::Computer.all_ids # =>  [1122, 1218, 931, ...]
```

Some Classes provide other ways to list objects, or subsets of them, depending on the data available, e.g. JSS::MobileDevice.all\_udids or JSS::Computer.all\_laptops

You can also perform simple searches for JSS::Computer, JSS::MobileDevice and JSS::User with the `.match` class method. This is the API equivalent of using the simple search field at the top of the Computers, Devices, or Users pages in the Jamf Pro Web interface. This method will return an Array of Hashes for the matching items. Each Hash is a summary of info about a matching item, similar to the summaries returned by the `.all` methods for those items.

To create, modify, or perform advanced searches, use the classes JSS::AdvancedComputerSearch, JSS::AdvancedMobileDeviceSearch, and JSS::AdvancedUserSearch.

--------

#### Retrieving Objects

To retrieve a single object call the class's `.fetch` method and provide a name:,  id:, or other valid identifier.


```ruby
a_dept = JSS::Department.fetch name: 'Payroll'# =>  #<JSS::Department:0x10b4c0818...
```

Some classes can use more than just the :id and name: keys for lookups, e.g. computers can be looked up with udid:, serial_number:, or mac_address:.

You can even fetch objects without specifying the kind of identifier, e.g. `JSS::Computer.fetch 'VM3X9483HD78'`, but this will be slower, since ruby-jss searches by matching the given value with all available identifiers, returning the first match.

--------

#### Creating Objects

Some Objects can be created anew in the JSS via ruby. To do so, first make a Ruby object using the class's `.make` method and providing a unique :name:, e.g.

```ruby
new_pkg = JSS::Package.make name: "transmogrifier-2.3-1.pkg"
```
*NOTE*: some classes require more data than just a name: when created with .make

Then set the attributes of the new object as needed

```ruby
new_pkg.reboot_required = false
new_pkg.category = "CoolTools"
# etc..
```

Then use the #save method to create it in the JSS. The #create method is the same

```ruby
new_pkg.save # returns 453, the id number of the object just created
```

--------

#### Updating Objects

Some objects can be modified in the JSS.

```ruby
existing_script = JSS::Script.fetch id: 321
existing_script.name = "transmogrifier-2.3-1.post-install"
```

After changing any attributes, use the #save method (also aliased to #update) to push the changes to the JSS.

```ruby
existing_script.save #  => returns the id number of the object just saved
```

--------

#### Deleting Objects

To delete an object, just call its #delete method

```ruby
existing_script = JSS::Script.fetch id: 321
existing_script.delete # => true # the delete was successful
```
To delete an object without fetching it, use the class's .delete method and provide the id, or an array of ids.

```ruby
JSS::Script.delete [321, 543, 374]
```

See [JSS::APIObject](http://www.rubydoc.info/gems/ruby-jss/JSS/APIObject), the parent class of all API resources, for general information about creating, reading, updating/saving, and deleting resources.

See the individual subclasses for any details specific to them.

## OBJECTS IMPLEMENTED

While the API itself supports nearly full CRUD (Create,Read,Update,Delete) for all objects, ruby-jss doesn't yet do so. Why? Because implementing the data validation and other parts needed for creating & updating can be time-consuming and we've focused on what we needed. As we keep developing ruby-jss, this list changes. If you'd like to help implement some of these objects more fully, please fork the github project and reach out to us at ruby-jss@pixar.com.

Here's what we've implemented so far. See each Class's [documentation(http://www.rubydoc.info/gems/ruby-jss)] for details.

### Creatable and Updatable

* {JSS::AdvancedComputerSearch}
* {JSS::AdvancedMobileDeviceSearch}
* {JSS::AdvancedUserSearch}
* {JSS::Building}
* {JSS::Category}
* {JSS::Computer}
* {JSS::ComputerExtensionAttribute}
* {JSS::ComputerGroup}
* {JSS::Department}
* {JSS::DistributionPoint}
* {JSS::MobileDevice}
* {JSS::MobileDeviceApplication}
* {JSS::MobileDeviceExtensionAttribute}
* {JSS::MobileDeviceGroup}
* {JSS::NetworkSegment}
* {JSS::Package}
* {JSS::PatchTitle}
* {JSS::PatchTitle::Version}
* {JSS::PatchExternalSource}
* {JSS::PatchPolicy}
* {JSS::Peripheral}
* {JSS::PeripheralType}
* {JSS::Policy} (not fully implemented)
* {JSS::RemovableMacAddress}
* {JSS::RestrictedSoftware}
* {JSS::Script}
* {JSS::Site}
* {JSS::User}
* {JSS::UserExtensionAttribute}
* {JSS::UserGroup}
* {JSS::WebHook}


**NOTE** Most Computer and MobileDevice data gathered by an Inventory Upate (a.k.a. 'recon') is not editable.

### Updatable, but must be created in the Web UI

* {JSS::OSXConfigurationProfile}
* {JSS::MobileDeviceConfigurationProfile}
* {JSS::PatchInternalSource}

### Creatable only

* {JSS::ComputerInvitation}

### Read-Only

These must be created and edited via the JSS WebApp

* {JSS::DistributionPoint}
* {JSS::LDAPServer}
* {JSS::NetBootServer}
* {JSS::SoftwareUpdateServer}

### Deletable

All supported API Objects can be deleted

#### Other useful classes & modules:

* {JSS::APIConnection} - An object representing a connection to the Classic API on some server. The 'default' connection object is available via `JSS.api` but you can create others, and pass them into calls like `.fetch` as needed. This is useful when working with multiple servers at a time, such as a production and a test server. Objects retrieved from a connection know which connection they came from, and will only send changes via that connection.
* {JSS::DBConnection} - An object representing the connection to MySQL database, if used.
* {JSS::Server} - An object representing the Jamf Pro server being used by a connection. An instance is available in the #server attribute of a {JSS::APIConnection}.
* {JSS::Client} - An object representing the local machine as a Jamf-managed client, and provifing Jamf-related info and methods
* {JSS::ManagementHistory} - a module for handing the management history for Computers and Mobile Devices. It defines many read-only classes representing events in a machine's history. It is accessed via the Computer and MobileDevice classes and their instances.
* {JSS::Scopable} - a module that handles Scope for those objects that can be scoped. It defines the Scope class used in those objects.
* {JSS::MDM} - a module that handles sending MDM commands. It is accessed via the Computer and MobileDevice classes and their instances.

## Object-related API endpoints

The classic API provides many endpoints not just for objects stored in Jamf Pro, but also for accessing data *about* those  objects or interacting with the machines they represent. ruby-jss embeds access to those endpoints into their related classes.

For example:

* /computerapplications, /computerapplicationusage, /computerhardwaresoftwarereports, /computerhistory, etc.
  - The data provided by these endpoints are accessible via class and instance methods for {JSS::Computer}
* /computercheckin, /computerinventorycollection
  - These endpoints deal with server-wide settings regarding computer management, and are available via {JSS::Computer} class methods
* /computercommands, /mobiledevicecommands, /commandflush, etc.
  - These endpoints provide access to the MDM infrastructure, and can be used to send MDM commands. Ruby-jss provides these as class and instance methods in {JSS::Computer}, {JSS::ComputerGroup}, {JSS::MobileDevice}, and {JSS::MobileDeviceGroup}

## CONFIGURATION

The {JSS::Configuration} singleton class is used to read, write, and use site-specific defaults for the JSS module. When ruby-jss is required, the single instance of {JSS::Configuration} is created and stored in the constant {JSS::CONFIG}. At that time the system-wide file /etc/ruby-jss.conf is examined if it exists, and the items in it are loaded into the attributes of {JSS::CONFIG}. The user-specific file ~/.ruby-hss.conf then is examined if it exists, and any items defined there will override those values from the system-wide file.

The values defined in those files are used as defaults throughout the module. Currently, those values are only related to establishing the API connection. For example, if a server name is defined, then a :server does not have to be specified when calling {JSS::APIConnection#connect}. Values provided explicitly when calling JSS::APIConnection#connect will override the config values.

While the {JSS::Configuration} class provides methods for changing the values, saving the files, and re-reading them, or reading an arbitrary file, the files are text files with a simple format, and can be created by any means desired. The file format is one attribute per line, thus:

    attr_name: value

Lines that don’t start with a known attribute name followed by a colon are ignored. If an attribute is defined more than once, the last one wins.

The currently known attributes are:

* api_server_name [String] the hostname of the JSS API server
* api_server_port [Integer] the port number for the API connection
* api_verify_cert [Boolean] 'true' or 'false' - if SSL is used, should the certificate be verified? (usually false for a self-signed cert)
* api_username [String] the JSS username for connecting to the API
* api_timeout_open [Integer] the number of seconds for the open-connection timeout
* api_timeout [Integer] the number of seconds for the response timeout

To put a standard server & username on all client machines, and auto-accept the JSS's self-signed https certificate, create the file /etc/ruby-jss.conf containing three lines like this:

```
api_server_name: jamfpro.myschool.edu
api_username: readonly-api-user
api_verify_cert: false
```

and then any calls to JSS.api.connect will assume that server and username, and won't complain about the self-signed certificate.

### Passwords

The config files don't store passwords and the {JSS::Configuration} instance doesn't work with them. You'll have to use your own methods for acquiring the password for the JSS.api.connect call.

The {JSS::APIConnection.connect} method also accepts the symbols :stdin# and :prompt as values for the :pw argument, which will cause it to read the password from a line of stdin, or prompt for it in the shell.

If you must store a password in a file, or retrieve it from the network, make sure it's stored securely, and that the JSS user has limited permissions.

Here's an example of how to use a password stored in a file:

```ruby
password = File.read "/path/to/secure/password/file" # read the password from a file
JSS.api.connect pw: password   # other arguments used from the config settings
```

And here's an example of how to read a password from a web server and use it.

```ruby
require 'open-uri'
password =  URI.parse('https://server.org.org/path/to/password').read
JSS.api.connect pw: password   # other arguments used from the config settings
```

## BEYOND THE API

While the Jamf Pro Classic API provides access to object data in the JSS, ruby-jss tries to use that data to provide more than just information exchange. Here are some examples of how ruby-jss uses the API to provide functionality found in various Jamf tools:

* Client Machine Access
  * The {JSS::Client} module provides the ability to run jamf binary commands, and access the local cache of package receipts
* Package Installation
  * {JSS::Package} objects can be installed on the local machine, from the appropriate distribution point
* Script Execution
  * {JSS::Script} objects can be executed locally on demand
* Package Creation
  * The {JSS::Composer} module provides creation of very simple .pkg and .dmg packages
  * {JSS::Package} objects can upload their .pkg or .dmg files to the master distribution point ({JSS::Script} objects can also if you store them there.)
* Reporting/AdvancedSearch exporting
  * {JSS::AdvancedSearch} subclasses can export their results to csv, tab, and xml files.
* MDM Commands
  * {JSS::MobileDevice}s (and eventually {JSS::Computer}s) can be sent MDM commands
* Extension Attributes
  * {JSS::ExtensionAttribute} work with {JSS::AdvancedSearch} subclasses to provide extra reporting about Ext. Attrib. values.

## INSTALL

NOTE: You may need to install XCode, or it's CLI tools, in order to install the required gems.

In general, you can install ruby-jss with this command:

`gem install ruby-jss`

## REQUIREMENTS

ruby-jss was written for:

* Mac OS X 10.9 or higher
* Ruby 2.0 or higher
* Casper Suite version 10.4 or higher

It also requires other ruby gems, which will be installed automatically if you install with `gem install ruby-jss`
See the .gemspec file for details


## HELP

Full documentation is available at [rubydoc.info](http://www.rubydoc.info/gems/ruby-jss/).

There's a [wiki on the github page](https://github.com/PixarAnimationStudios/ruby-jss/wiki), feel free to contribute examples and tidbits.

[Email the developers](mailto:ruby-jss@pixar.com)

[Macadmins Slack Channel](https://macadmins.slack.com/messages/#jss-api/)

## LICENSE

Copyright 2019 Pixar

Licensed under the Apache License, Version 2.0 (the "Apache License") with modifications. See LICENSE.txt for details
