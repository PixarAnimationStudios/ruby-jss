# JSS 

## DESCRIPTION

JSS is a Ruby gem providing access to the REST API of JAMF Software's Casper Suite. It abstracts API resources 
as Ruby objects, and provides methods for interacting with those resources. It also provides some features that 
aren't a part of the API, but come with other Casper-related tools, such as uploading .pkg and .dmg JSS::Package 
data to the master distribution point, and the installation of JSS::Package objects on client machines.

The gem is not a complete implementation of the Casper API. Only some API objects are modeled, and some of 
those are read-only, some partially writable, some fully read-write. See OBJECTS IMPLEMENTED for a list.



## SYNOPSIS

```ruby
require 'jss'

JSS::API.connect :user => jss_user, :pw => jss_user_pw, :server => jss_server_hostname

JSS::Package.all # returns an array of data about all JSS::Package objects in the JSS
JSS::Package.all_names # returns an array of names of all JSS::Package objects in the JSS

# Get a static computer group
mg = JSS::ComputerGroup.new :name => "Macs of interest"

# Add a computer to the group
mg.add_member "pricklepants"

# save my changes
mg.update

# Create a new network segment to store in the JSS
ns = JSS::NetworkSegment.new :id => :new, :name => 'Private Class C', :starting_address => '192.168.0.0', :ending_address => '192.168.0.255'

# Associate this network segment with a specific building, which must exist in the JSS, and be listed in JSS::Building.all_names
ns.building = "Main Office" 

# Associate this network segment with a specific software update server, which must exist in the JSS, 
# and be listed in JSS::SoftwareUpdateServer.all_names
ns.swu_server = "Main SWU Server" 

# Store the new network segment in the JSS
ns.create 
```

## USAGE

### Connecting to the API

Before you can work with JSS Objects via the API, you have to connect to it. 

The constant JSS::API contains the connection to the API (a singleton instance of JSS::APIConnection). When the JSS Module is first loaded, it isn't 
connected.  To remedy that, use JSS::API.connect, passing it values for :user, :pw, and :server:

```ruby
JSS::API.connect :user => jss_user, :pw => jss_user_pw, :server => jss_server_hostname
```

Make sure the user has privileges to do things with JSS Objects. See the JSS::APIConnection class for more details about its methods.

### Working with JSS Objects (a.k.a REST Resources)

All API Object classes are subclasses of JSS::APIObject and share methods for listing, retrieving, and deleting from the JSS. All supported objects can be listed, retrieved and deleted, but only some can be updated or created. Those classes do so by mixing in the JSS::Creatable and/or JSS::Updateable modules. See below for the level of implementation of each class. 

--------

#### Listing Objects

To get an Array of every object in the JSS of some Class, call that Class's .all method:

```ruby
JSS::Computer.all # => [{:name=>"cephei", :id=>62},{:name=>"peterparker", :id=>218}, {:name=>"rowdy", :id=>901}, ...]
```

The Array will contain a Hash for each item, with at least a :name and an :id.  Some classes provide more data for each item.
To get just the names or just the ids in an Array, use the .all\_names or .all\_ids Class method

```ruby
JSS::Computer.all_names # =>  ["cephei", "peterparker", "rowdy", ...]
JSS::Computer.all_ids # =>  [62, 218, 901, ...]
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

Other useful classes:

* JSS::Server - An encapsulation of some info about the server, such as the JSS version and license. An instance is available as an attribute of the JSS::APIConnection singleton.
* JSS::Client - An object representing the local machine as a Casper-managed client, and JAMF-related info and methods

## OBJECTS IMPLEMENTED

See each Class's documentation for details.

### Creatable and Updatable

* AdvancedComputerSearch
* AdvancedMobileDeviceSearch
* AdvancedUserSearch
* Building
* Category
* ComputerExtensionAttribute
* ComputerGroup
* Department
* MobileDeviceExtensionAttribute
* MobileDeviceGroup
* NetworkSegment
* Package
* Peripheral
* PeripheralType
* RemovableMacAddress
* Script
* User
* UserExtensionAttribute
* UserGroup

### Updatable but not Creatable

* Computer - limited to modifying
  * name
  * mac addresses
  * barcodes
  * asset tag
  * ip address
  * udid
  * location data
  * purchasing data
* MobileDevice - limited to modifying
  * asset tag
  * location data
  * purchasing data
* Policy - limited  to modifying
  * Scope (see JSS::Scopable::Scope)
  * name
  * enabled
  * category
  * triggers
  * file & process actions
  
**NOTE** Even in the API and the WebApp, Computer and Mobile Device data gathered by an Inventory Upate (a.k.a. 'recon') is not editable.

### Read-Only

These must be created and edited via the JSS WebApp

* DistribuitionPoint
* NetbootServer
* SoftwareUpdateServer

* ComputerReport - these are defined by their matching AdvancedComputerSearch

### Deletable

All supported API Objects can be deleted


## REQUIREMENTS

JSS was written for ruby 1.8.7 and 2.0.0, the two versions that come with OS X 10.9.

It also requires these gems, which will be installed automatically if you install JSS with `gem install`

* rest-client >=1.6.7 http://rubygems.org/gems/rest-client
* json or json\_pure >= 1.6.5 http://rubygems.org/gems/json or http://rubygems.org/gems/json_pure
  * (only in ruby 1.8.7.  Ruby 2.0.0 has json in its standard library)
* ruby-mysql >= 2.9.12
  * (only for a few things that still require direct SQL access to the JSS database)

## INSTALL

`gem install jss`

## RUNNING TESTS

Totally automated tests are not really an option since you must connect to a JSS API, and once connected, it's impossible to assume what might be 
defined there.

There is a tiny stub of test that only check the ability to connect and to basic REST transactions. Eventually I may try to write more that are generally 
runnable, interactively, on any JSS


## LICENSE

I have yet to chat with Legal about getting this thing opensourced.