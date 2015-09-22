# The JSS API Ruby Gem - access to the Casper Suite from Ruby

## DESCRIPTION

The jss-api gem provides a Ruby module called JSS, which is used for accessing the REST API of the JAMF Software Server (JSS), the core of the Casper Suite, an enterprise-level management tool for Apple devices from [JAMF Software, LLC](http://www.jamfsoftware.com/).

The module abstracts API resources as Ruby objects, and provides methods for interacting with those resources. It also provides some features that aren't a part of the API itself, but come with other Casper-related tools, such as uploading .pkg and .dmg {JSS::Package} data to the master distribution point, and the installation of {JSS::Package} objects on client machines. (See BEYOND THE API) 

The module is not a complete implementation of the Casper API. Only some API objects are modeled, some only minimally. Of
those, some are read-only, some partially writable, some fully read-write (all implemented objects can be deleted)
See OBJECTS IMPLEMENTED for a list. 

We've implemented the things we need in our environment, and as our needs grow, we'll add more. 
Hopefully others will find it useful, and add more to it as well.

[Full technical documentation can be found here.](http://www.rubydoc.info/gems/jss-api/)


## SYNOPSIS

```ruby
# you may need to require 'rubygems' first if you're using Ruby 1.8
require 'jss-api'   

JSS::API.connect(
  :user => jss_user, 
  :pw => jss_user_pw, 
  :server => jss_server_hostname
)

# get an array of data about all JSS::Package objects in the JSS:
JSS::Package.all

# get an array of names of all JSS::Package objects in the JSS:
JSS::Package.all_names 

# Get a static computer group
mg = JSS::ComputerGroup.new :name => "Macs of interest"

# Add a computer to the group
mg.add_member "pricklepants"

# save my changes
mg.update

# Create a new network segment to store in the JSS
ns = JSS::NetworkSegment.new(
  :id => :new, 
  :name => 'Private Class C', 
  :starting_address => '192.168.0.0', 
  :ending_address => '192.168.0.255'
)

# Associate this network segment with a specific building,
# which must exist in the JSS, and be listed in JSS::Building.all_names
ns.building = "Main Office" 

# Associate this network segment with a specific software update server,
#  which must exist in the JSS, and be listed in JSS::SoftwareUpdateServer.all_names
ns.swu_server = "Main SWU Server" 

# Create the new network segment in the JSS
ns.create 
```

## USAGE

### Connecting to the API

Before you can work with JSS Objects via the API, you have to connect to it. 

The constant {JSS::API} contains the connection to the API (a singleton instance of {JSS::APIConnection}). When the JSS Module is first loaded, it isn't 
connected.  To remedy that, use JSS::API.connect, passing it values for :user, :pw, and :server:

```ruby
JSS::API.connect :user => jss_user, :pw => jss_user_pw, :server => jss_server_hostname
```

Make sure the user has privileges in the JSS to do things with API Objects. 

The {JSS::API#connect} method also accepts the symbols :stdin and :prompt as values for :pw, which will cause it to read the
password from stdin, or prompt for it in the shell. See the JSS::APIConnection class for more connection options and details about its methods. 

Also see {JSS::Configuration}, and the CONFIGURATION section below, for how to store
server connection parameters in a simple config file.

### Working with JSS Objects (a.k.a REST Resources)

All API Object classes are subclasses of JSS::APIObject and share methods for listing, retrieving, and deleting from the JSS. All supported objects can be listed, retrieved and deleted, but only some can be updated or created. Those classes do so by mixing in the JSS::Creatable and/or JSS::Updateable modules. See below for the level of implementation of each class. 

--------

#### Listing Objects

To get an Array of every object in the JSS of some Class, call that Class's .all method:

```ruby
JSS::Computer.all # => [{:name=>"cephei", :id=>1122},{:name=>"peterparker", :id=>1218}, {:name=>"rowdy", :id=>931}, ...]
```

The Array will contain a Hash for each item, with at least a :name and an :id.  Some classes provide more data for each item.
To get just the names or just the ids in an Array, use the .all\_names or .all\_ids Class method

```ruby
JSS::Computer.all_names # =>  ["cephei", "peterparker", "rowdy", ...]
JSS::Computer.all_ids # =>  [1122, 1218, 931, ...]
```    

Some Classes provide other ways to list objects, depending on the data available, e.g. JSS::MobileDevice.all\_udids

--------

#### Retrieving Objects

To retrieve a single object call the object's constructor (.new) and provide either :name or :id or :data.

* :name or :id will be looked up via the API

```ruby
a_dept = JSS::Department.new :name => "Payroll" # =>  #<JSS::Department:0x10b4c0818...
```

* :data must be the parsed JSON output of a separate API query (a hash with symbolized keys)

```ruby
dept_data = JSS::API.get_rsrc("departments/name/Payroll")[:department] # => {:name=>"Payroll", :id=>42}
a_dept = JSS::Department.new :data => dept_data  # =>  #<JSS::Department:0x10b4a83f8...
```

Some subclasses can use more than just the :id and :name keys for lookups, e.g. computers can be looked up with :udid, :serial_number, or :mac_address.

--------

#### Creating Objects

Some Objects can be created anew in the JSS. To make a new object, first instantiate one using :id => :new, and provide a unique :name.

```ruby
new_pkg = JSS::Package.new :id => :new, :name => "transmogrifier-2.3-1.pkg"
```

Then set the attributes of the new object as needed

```ruby
new_pkg.reboot_required = false
new_pkg.category = "CoolTools"
# etc..
```

Then use the #create method to create it in the JSS.

```ruby
new_pkg.create # => 453 # the id number of the object just created
```

*NOTE* some subclasses require more data than just a :name when instantiating with :id => :new.

--------

#### Updating Objects

Some objects can be modified in the JSS.

```ruby
existing_script = JSS::Script.new :id => 321
existing_script.name = "transmogrifier-2.3-1.post-install"
```

After changing any attributes, use the #update method (also aliased to #save) to push the changes to the JSS.

```ruby
existing_script.update # or existing_script.save  => true # the update was successful
```

--------

#### Deleting Objects

To delete an object, just call its #delete method

```ruby
existing_script = JSS::Script.new :id => 321
existing_script.delete # => true # the delete was successful
```

See JSS::APIObject, the parent class of all API resources, for general information about creating, reading, updating/saving, and deleting resources.

See the individual subclasses for any details specific to them.

## OBJECTS IMPLEMENTED

See each Class's documentation for details.

### Creatable and Updatable

* {JSS::AdvancedComputerSearch}
* {JSS::AdvancedMobileDeviceSearch}
* {JSS::AdvancedUserSearch}
* {JSS::Building}
* {JSS::Category}
* {JSS::ComputerExtensionAttribute}
* {JSS::ComputerGroup}
* {JSS::Department}
* {JSS::MobileDeviceExtensionAttribute}
* {JSS::MobileDeviceGroup}
* {JSS::NetworkSegment}
* {JSS::Package}
* {JSS::Peripheral}
* {JSS::PeripheralType}
* {JSS::RemovableMacAddress}
* {JSS::Script}
* {JSS::User}
* {JSS::UserExtensionAttribute}
* {JSS::UserGroup}

### Updatable but not Creatable

* {JSS::Computer} - limited to modifying
  * name
  * barcodes
  * asset tag
  * ip address
  * location data
  * purchasing data
  * editable extension attributes
* {JSS::MobileDevice} - limited to modifying
  * asset tag
  * location data
  * purchasing data
  * editable extension attributes
* {JSS::Policy} - limited  to modifying
  * scope (see {JSS::Scopable::Scope})
  * name
  * enabled
  * category
  * triggers
  * file & process actions
  
**NOTE** Even in the API and the WebApp, Computer and Mobile Device data gathered by an Inventory Upate (a.k.a. 'recon') is not editable.

### Read-Only

These must be created and edited via the JSS WebApp

* {JSS::DistributionPoint}
* {JSS::LDAPServer}
* {JSS::NetBootServer}
* {JSS::SoftwareUpdateServer}

### Deletable

All supported API Objects can be deleted

Other useful classes:

* {JSS::Server} - An encapsulation of some info about the server, such as the JSS version and license. An instance is available as an attribute of the {JSS::APIConnection} singleton.
* {JSS::Client} - An object representing the local machine as a Casper-managed client, and JAMF-related info and methods

## CONFIGURATION

The {JSS::Configuration} singleton class is used to read, write, and use site-specific defaults for the JSS module. When the Module is required, the single instance of {JSS::Configuration} is created and stored in the constant {JSS::CONFIG}. At that time the system-wide file /etc/jss_gem.conf is examined if it exists, and the items in it are loaded into the attributes of {JSS::CONFIG}. The user-specific file ~/.jss_gem.conf then is examined if it exists, and any items defined there will override those values from the system-wide file.

The values defined in those files are used as defaults throughout the module. Currently, those values are only related to establishing the API connection. For example, if a server name is defined, then a :server does not have to be specified when calling {JSS::API#connect}. Values provided explicitly when calling JSS::API.connect will override the config values.

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

To put a standard server & username on all client machines, and auto-accept the JSS's self-signed https certificate, create the file /etc/jss_gem.conf containing three lines like this:

```
api_server_name: casper.myschool.edu
api_username: readonly-api-user
api_verify_cert: false
```

and then any calls to {JSS::API.connect} will assume that server and username, and won't complain about the self-signed certificate.

### Passwords

The config files don't store passwords and the {JSS::Configuration} instance doesn't work with them. You'll have to use your own methods for acquiring the password for the JSS::API.connect call. 

The {JSS::API#connect} method also accepts the symbols :stdin# and :prompt as values for the :pw argument, which will cause it to read the password from a line of stdin, or prompt for it in the shell. 

If you must store a password in a file, or retrieve it from the network, make sure it's stored securely, and that the JSS user has limited permissions.  

Here's an example of how to use a password stored in a file:

```ruby
password = File.read "/path/to/secure/password/file" # read the password from a file
JSS::API.connect :pw => password   # other arguments used from the config settings
```

And here's an example of how to read a password from a web server and use it.

```ruby
require 'open-uri'
password =  open('http://server.org.org/path/to/password').read
JSS::API.connect :pw => password   # other arguments used from the config settings
```

## BEYOND THE API

While the Casper API provides access to object data in the JSS, this gem tries to use that data to provide more than just information exchange. Here are some examples of how we use the API data to provide functionality found in various Casper tools:

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
* LDAP Access
  * {JSS::LDAPServer} objects can query the LDAP servers for user, group, and membership data.
* MDM Commands
  * {JSS::MobileDevice}s (and eventually {JSS::Computer}s) can be sent MDM commands
* Extension Attributes
  * {JSS::ExtensionAttribute} work with {JSS::AdvancedSearch} subclasses to provide extra reporting about Ext. Attrib. values.

## REQUIREMENTS

the JSS gem was written for:

* Mac OS X 10.8 and higher
* Casper Suite version 9.4 or higher
* Casper 9.4 - 9.6 require Ruby 1.8.7 and higher
* Casper >= 9.61 require Ruby 1.9.3 and higher

It also requires these gems, which will be installed automatically if you install JSS with `gem install jss`

* rest-client >=1.6.7  ( >= 1.7.0 with Casper >= 9.6.1) http://rubygems.org/gems/rest-client 
* json or json\_pure >= 1.6.5 http://rubygems.org/gems/json or http://rubygems.org/gems/json_pure
  * (only in ruby 1.8.7.  Ruby >= 1.9 has json in its standard library)
* ruby-mysql >= 2.9.12 http://rubygems.org/gems/ruby-mysql
  * (only for a few things that still require direct SQL access to the JSS database)
* plist =3.1.0 http://rubygems.org/gems/plist
  * for the {JSS::Composer} module and {JSS::Client} class
* net-ldap >= 0.3.1 http://rubygems.org/gems/net-ldap
  * for accessing the LDAP servers defined in the JSS, to check for user and group info.

## INSTALL

NOTE: You may need to install XCode, and it's CLI tools, in order to install the required gems.

In general, you can install the JSS Gem with this command: 

`gem install jss-api`

If you're using Ruby 1.8.7 (Casper 9.4 - 9.6 only), install the following gems manually first, since the JSS gem will try to install newer, incompatible versions if they aren't pre-installed.

`gem install json -v 1.6.5`

`gem install mime-types -v 1.25.1`

`gem install rest-client -v 1.6.8`

## LICENSE

Copyright 2015 Pixar

Licensed under the Apache License, Version 2.0 (the "Apache License")
with the following modification; you may not use this file except in
compliance with the Apache License and the following modification to it:

Section 6. Trademarks. is deleted and replaced with:

  6\. Trademarks. This License does not grant permission to use the trade
  names, trademarks, service marks, or product names of the Licensor
  and its affiliates, except as required to comply with Section 4(c) of
  the License and to reproduce the content of the NOTICE file.

You may obtain a copy of the Apache License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the Apache License with the above modification is
distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the Apache License for the specific
language governing permissions and limitations under the Apache License.