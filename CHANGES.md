# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## \[1.1.0] - 2019-09-19
### Added
- MobileDeviceExtensionAttribute now has a `.history` class method matching that of ComputerExtensionAttribute. Requires direct MySQL database access. Thanks @aurica!
- JSS::AmbiguousError exception class
- More caching of API data to improve general speed
  - The hashes created by `APIObject.map_all_ids_to(blah)`
  - ExtensionAttribute definitions when used by extendable classes
- APIObject.fetch can take the search term `:random` and you'll get a randomly selected object. Example: `a_random_computer = JSS::Computer.fetch :random`
- Keys of the hash returned by `Computer#hardware` are now available as instance methods on Computer objects. So as well as `a_computer.hardware[:total_ram]` you can also do `a_computer.total_ram`
- Policy now recognizes the frequency Symbol `:once_per_user_per_computer`
- Attribute reader :management_status added to Computer class
- Implemented some useful String methods from newer versions of Ruby into older Rubies: `casecmp?`, `delete_prefix`, & `delete_suffix`


### Fixed
- Can't Modify Frozen Hash error when instantiating JSS::Scopbable::Scope. Thanks to @shahn for reporting this one.
- MobileDeviceExtensionAttribute now handles empty `as_of` timestamp. Thanks @aurica!
- A few typos. Thanks to @cybertunnel for finding some.
- A bug when parsing the `server_path` parameter to `API::Connection.new`
- Bugs in handling blank values in Policy#search_by_path and Policy#printer_ids. Thanks @cybertunnel
- Computer.management_data with a specified subset returned one level too high in the data structure
- NetworkSegment.my_network_segment: error in number of params passed to other methods
- Script#name= now works again, no longer uses a constant from an ancient version. Thanks @shahn
- Computer#asset_tag= now accepts nil to erase the value
- APIConnection.my_distribution_point & DistributionPoint.my_distribution_point now return the master_distribution_point object if there isn't one assigned to the current network segment.
- RestClient no longer warns about calling 'to_i' on Responses when calling APIConnection#put_rsrc & #post_rsrc

### Changed
- Monkey Patches are being moved to a better, more traceable technique, see https://www.justinweiss.com/articles/3-ways-to-monkey-patch-without-making-a-mess/
- MobileDevices and Computers now raise JSS::AmbiguousError when being fetched by explicitly by name, e.g. `JSS::Computer.fetch name: 'foo'` and that name is not unique in the JSS. Previously, you'd get an object back, but no guarantee as to which one it was. You'll still get an undefined object if you use a bare searchterm, e.g. `JSS::Computer.fetch 'foo'`
- Documentation for subclassing APIObject is updated & expanded. See the comments above the class definition in api_object.rb
- `APIObject.valid_id` is now case-insensitive
- Removed deprecated VALID_DATA_KEYS constants from APIObject subclasses
- Various changes in APIObject and its subclasses to try making `.fetch` and other lookup-methods faster.
- All of the NetworkSegment-related methods in APIConnection have been moved back to NetworkSegment. The methods in APIConnection still work, but are marked deprecated and will go away eventually.
- Removed last call to deprecated `URI.encode`, replaced with `CGI.escape`


## \[1.0.4] - 2019-05-06
### Added
- JSS::Group (and its subclasses) now have a `change_membership` class and instance method for static groups.
  - The class method allows adding and removing members without fetching an instance of the group.
  - The instance method adds and/or removes members immediately, without needing to call #update or #save

- LDAPServer.server_for_user and .server_for_group class methods, return the id of the first LDAP server containing the given user or group

- Client.homedir(user) and Client.do_not_disturb?(user)

- Package.all_filenames, .orphaned_files, and .missing_files class methods. WARNING - these are very slow since they must instantiate every package.

- The JSS::APIConnection.connect method, used for making all classic API connections, now takes a `server_path:` parameter.
  If your JSS is not at the root of the server, e.g. if it's at
    `https://myjss.myserver.edu:8443/dev_mgmt/jssweb/`
  rather than
    `https://myjss.myserver.edu:8443/`
  then use this parameter to specify the path below the root e.g:
    `JSS.api.connect server: 'myjss.myserver.edu', server_path: 'dev_mgmt/jssweb', port: 8443 [...]`
  (Thanks @christopher.kemp!)

- Packages in Jamf Pro 10.10 and higher now include checksum data (`hash_type` and `hash_value` in the raw data) via the classic API. This has been integrated into JSS::Package via the following methods:
  - New Class Method
    - `JSS::Package.calculate_checksum(filepath, type)` calcuates an MD5 or SHA_512 hash for an arbtrary file.
  - New Instance Attributes:
    - `JSS::Package#checksum`  the checksum value, read-write
    - `JSS::Package#checksum_type` the string 'MD5' or 'SHA_512' ('SHA_512' if no checksum is set), read-write
  - New Instance Methods:
    - `JSS::Package#caluclate_checksum(type: nil, local_file: nil, rw_pw: nil, ro_pw: nil, unmount: true )` recalculates and returns the checksum from a local file or the master dist. point. Doesn't change the Package instance
    - `JSS::Package#checksum_valid?(local_file: nil, rw_pw: nil, ro_pw: nil, unmount: true)` recalculates the checksum from a local file or the master dist. point, and returns Boolean true if it matches the stored one, false if not. Always false if there is no stored checksum. Doesn't change the Package instance
    - `JSS::Package#reset_checksum(type: nil, local_file: nil,  rw_pw: nil, ro_pw: nil, unmount: true)` recalculates and resets the checksum from a local file or the master dist. point. The instance must be saved back to the server for the new checksum to stick,
  - Modified Instance Method
    - `JSS::Package#upload_master_file` now takes a `cksum:` parameter, the String 'MD5' or 'SHA_512'. Any other value means 'don't use a checksum on this package' Defaults to 'SHA_512' and a checksum will be calculated. Be sure to set `cksum:` to some other value if you don't want a checksum.

  NOTE: Checksum calculation can be slow, especially for large packages on a network server.

  _WARNING_: when using a local file to calculate checksums, BE 100% SURE it is identical to the file on the distribution point, or you will get an invalid checksum.


### Fixed
- JSS::MobileDevice.update now returns the device's jss id, as advertised.

- default port number choice for on-prem vs. JamfCloud connections

- Client.primary_console_user returns nil when at the loginwindow

- Computer#certificates attribute is now readable (Thanks to @Nick Taylor and @Lulu-sheng)

- error when SelfService icon is not available where expected, returns nil instead. (Thanks to @cybertunnel for finding this)

- JSS::Script.category now returns category name, not nil. (Thanks @cybertunnel for this one too!)

### Changed
- This file reformatted based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),

- use new(er) API resources for LDAP lookups, don't go directly to LDAP via net/ldap

- Scopable::Scope objects now accept any valid identifier, not just names, when adding or removing items from scope.
  Also, item keys don't need to be plural (e.g. `:network_segment` works as well as `:network_segments`)
  (Thanks to @cybertunnel for pointing out that this was still not modernized)

## [1.0.2] - 2018-10-16
### Added
- Support for parentheses (opening_paren and closing_paren) in JSS::Criteriable::Criterion objects

- Support for patch-related criterion comparisons "greater than", "less than",  "greater than or equal",  "less than or equal"

### Fixed
- a couple lingering calls to `.new` on APIObject classes, now `.fetch`

## [1.0.1] - 2018-08-27
### Added
- `JSS::MobileDeviceApplication#version=` and `#bundle_id=` These two attributes are now settable and will be saved to the server if the application is hosted externally. Thanks to [ctaintor](https://github.com/ctaintor) for providing this patch.

## [1.0.0] - 2018-08-10

Finally we're going to version 1.0, which we should have done when we went opensource. Future releases will try to adhere to [Semantic Versioning](https://semver.org/) as described in the [rubygems.org guidelines](https://guides.rubygems.org/patterns/#semantic-versioning)

**IMPORTANT** This version is not backward compatible with 0.x version. Please read the details below and test your code before deploying widely.

### Changed
- Jamf Pro API version must be 10.4 or higher

- Better handling of http error responses

- JSS::Policy objects now have setters for the 'Maintenence' subset, e.g. recons ('update inventory'), reset_name, fix_byhost, etc.

- defaults to using TLSv1.2 for API connections.

  As of Jamf Pro 10.5. the server requires TLSv1.2 and will not accept connections using TLSv1.

  **COMPATIBILITY:**

  MacOS 10.12 and lower have an old version of the openssl library which used by the built-in ruby (/usr/bin/ruby), which does not support TLSv1.2.

  If you are using macOS 10.12 or lower to connect to Jamf Pro 10.4 (the lowest Jamf server supported by this version of ruby-jss), you must specify the older TLS when using APIConnection#connect, e.g.

  `JSS.api.connect server: 'myjss.myschool.edu', user: 'username', pw: :prompt, ssl_version: :TLSv1`

  Machines running macOS 10.12 or lower will not be able to connect to Jamf Pro > v10.4 with the built-in ruby openssl library. If you specify `ssl_version: :TLSv1` you will get an error because the server won't accept it. If you leave the default :TLSv1_2, ruby's openssl library will complain that it doesn't know about that.

  If you have 10.12 or older machines that must connect to newer Jamf Pro servers with ruby-jss, there are a few options.

  - upgade the machines to 10.13 or higher
  - install a newer openssl, then install a your own ruby using that openssl (both can be done with homebrew)
  - do the above, then extract the openssl library and modify it to work with the built-in ruby.

  If you have questions about this, feel free to reach out to ruby-jss@pixar.com, or in the #ruby or #jss-api channels in MacAdmins slack space, for some advice.

### Added
- JSS::PatchSource metaclass and the subclassses JSS::PatchInternalSource, and JSS::PatchExternalSource. These provide acecss to the patchavailabletitles enpoint, which is needed to acquire name_id's for creating/activating JSS::PatchTitles

- JSS::PatchTitle, which also gives access to the patchreports endpoint. Also uses the JSS::PatchTitle::Version class to handle patch versions within a title, and assign packages to them. **WARNING**: ruby-jss will not allow duplicate 'display names' (the #name of the JSS::PatchTitle instance) - but the Jamf Web UI will allow duplicates. If you have duplicates, and retrieve PatchTitles by name, which one gets returned to you is undefined.

  - The 'source_id' and 'name_id' of a patch title are, when combined, a unique identifier in the JSS (i.e. name_id's are unique within sources) As such, the PatchTitle.all list provides a :source_name_id key, which is a String made by joining the two values with a '-', e.g. '1-GoogleChrome'.  This value can be used as a lookup for .fetch, e.g. `JSS::PatchTitle.fetch source_name_id: '1-GoogleChrome'`. There is also a matching .all_source_name_ids method, and the .map_all_ids_to() method takes :source_name_id as a mapping parameter. You can also use .fetch and .make with both source: (id or name) and  name_id: specified.

- JSS::PatchPolicy. PatchPolicies are creatable when providing an active PatchTitle and an appropriate PatchTitle::Version that has a package assigned to it.

- the Group metaclass now has a calculate_members option (bool) to the #create method. When true, the membership of the group will be updated in the existing ruby instance immediately after the group is created in the JSS. Doesn't do much for static groups, but is useful for smart groups. Defaults to true. If you don't care about the membership immediately, or don't want to wait for the membership to be calculated on the server, set this to false.

- more generic data validation methods in JSS::Validate module, and more use of them throughout the code.

- 'support' in SelfServable for notifications - note that there are API bugs limiting the usefulness of this.

- regex options to JSS::Criteriable::Criterion objects

- there is now a, sort-of, spec/testing framework. While based on ruby's minitest specifications, it's wrapped in a very custom executable with a helper module. See the README in the test directory for details.  Specs will be added slowly over time.

- JSS::Client now has a .management_action class method, which wraps around the 'Management Action.app' tool that comes with Jamf Pro and creates Notification Center notifications. At the moment support is minimal, and the notification type (alert vs. banner) is up to the User.

### Removed
- the .new class method on APIObject subclasses no longer works. Even though it's the standard ruby way to create instances of a class, `.new` for APIObjects was confusing, since it implied creating new objects in the JSS.  Instead you must now use the `.fetch` class method to instantiate existing objects and the `.make` class method to instantiate local instances of objects to be created in the JSS. Both .fetch and .make have existed for some time.

  **COMPATIBILITY:**

  `existingcomp = JSS::Computer.new id: 1234` and `new_pol = JSS::Policy.new id: :new, name: 'mypolicy'` will now raise an error.

  Instead you must use `existingcomp = JSS::Computer.fetch id: 1234` and `new_pol = JSS::Policy.make name: 'mypolicy'`

  Note that the instance methods `#create` (create the current instance as a new object in the JSS) and `#update` (send changes in the current instance to the JSS) remain unchanged, and both continue handled by `#save`

### Fixed
- as Apple says: various bugfixes and improvements.

## [0.14.0] - 2018-05-30
### Fixed
- RestClient no longer uses RestClient::Request::Unauthorized, only RestClient::Unauthorized

- RestClient 2.0x doesn't seem to play nicely with the version of openssl on macOS 10.10 and JamfPro 10.3 (at least in our environment). So the rest-client gem can be any version >= 1.8.0 and < 2.1. You may have to separately install the correct RestClient version as needed.

## [0.13.0] - 2018-05-30
### Changed
- Now requires rest-client gem v2.0 and up, and ruby v 2.0.0 and up. Thanks to HIMANSHU-ELIGIBLE @ github for catching & fixing this one.

### Fixed
- a few minor bugs in JSS::Criteriable::Criterion

## [0.12.0] - 2018-04-16
### Changed
- when building .pkg's with JSS::Composer.mk_pkg, only two params are related to Package Signing: 'signing_identity:' the name of the signing identity to use, and and 'signing_options:' a string of all other signing-related CLI options that will be passed to the pkgbuild command, e.g. keychain locations, timestamps, certs, etc. For details, see `man pkgbuild`

- Now augmenting ruby Hashes with an embeded 'recursive-open-struct' version of themselves. This simplifies accessing values from deeply-nested Hash structures, e.g. JSS::Computer#hardware instead of `computer_instance.hardware[:storage].first[:partition][:percentage_full]` you can do `computer_instance.hardware.jss_ros.storage.first.partition.percentage_full`.  See http://www.rubydoc.info/gems/ruby-jss/Hash for details. Uses the [recursive-open-struct gem](https://github.com/aetherknight/recursive-open-struct).

- the JSS::Computer class is now defined in multiple files.  The single computer.rb file was getting far to unwieldy.

- JSS::MobileDeviceConfigurationProfile and JSS::OSXConfigurationProfile now share an abstract parent class, JSS::ConfigurationProfile, containing common code.

### Added
- The computerapplications/application endpoint is now implemented as the JSS::Computer.application_installs class method so you can query lists of computers that have certain apps installed.

- JSS::MobileDeviceConfigurationProfile is now more fleshed-out and is Updatable.

### Fixed
- Setting the first icon of a newly-created JSS::Policy now works. Thanks @christopher.kemp for reporting this one

- the SelfServable module was mis-handling 'user-removability' data for config profiles.

- Typo and missing method alias, caught by csfjeff @ github, issue #23

## [0.11.0] - 2018-03-12
### Changed
- Updated general attributes for computers and mobile devices

- Computers and MobileDevices are now Creatable. Use the .make class method to create an unsaved instance, then .create/.save instance method to create the JSS record. Note: Mobile Devices need both a unique serial number and unique udid to be accepted by the API.

- Handling of 'site' data is now done via the JSS::Sitable mixin module

- When the JSS server's hostname ends with 'jamfcloud.com' default to SSL port 443 (vs 8443 for locally hosted JSSs)

- now requires net-ldap v 0.16, for security fixes

- All handling of MDM commands is in the JSS::MDM module, which is mixed in to Computer, ComputerGroup, MobileDevice, and MobileDeviceGroup

  *WARNING* Due to the expanded functionality of MDM commands overall, the syntax for calling .send_mdm_command may have changed, depening on how you used it. Please test your code before updating.

- 'devmode', use `JSS.devmode \[:on|:off]`` to set, and `JSS.devmode?`` to query.  Useful for developers, esp. in `irb` who want, e.g. to have a method output some state when in devmode, instead of/as well as behaving normally. This is currently the case for `JSS::MDM.send_mdm_command`.  When devmode? is true, the XML sent to the API for the command is printed to stdout before the command is sent to the target machine.

- Computer app usage & mgmt data methods are now class methods, so can be used without instantiating the computer. The instance methods remain, and they now just use the class methods.

- All handling of management history for Computers and MobileDevices is in the new ManagementHistory module. The module
  is mixed into JSS::Computer and JSS::MobileDevice, so its methods are available to those classes and their instances. Note that some
  history events are only available in Computers or MobileDevices, and some are available in both.

  The primary query method (.management_history) returns the raw JSON data from the API, possibly for a subset of the data, as a Ruby Hash
  with symbolized keys. This data is somewhat inconsistent in its structure and content across the different types of history events,
  but you're welcome to use it if needed.

  All other methods now return Arrays of various instances of classes defined in the module.

  For example, the {JSS::MobileDevice.audit_history} method returns an Array of JSS::ManagementHistory::AuditEvent instances,  and the
  {JSS::Computer.completed_policies} gives an Array of JSS::ManagementHistory::PolicyLog objects. These objects are read-only and
  provide access to their values via attribute-style methods, and hash-like keys, similar to how OpenStruct objects do.

  As with MDM command handling, and computer app usage and mgmt data, the work is done by class methods, so that the data is available without creating instances of the Computers or MobileDevices, and the instance methods just
  call the class methods.

  *WARNING* these changes mean that the methods returning Arrays of ManagementHistory class instances are not backward compatible,
  since the earlier versions returned Hashes

### Added
- ruby-jss now has a code of conduct for contributors.

- All APIObject subclasses can be deleted without instantiating, via the .delete class method, providing an array of ids

### Fixed
- NoMethod error when saving JSS::Policy was due to a typo in a method call.

- Initialization of Creatable objects using certain mixins (Extendable, Sitable, Categorizable) either failed, or errored when trying to set their values. Now fixed. Thanks @mylescarrick for reporting this one.

- Scope objects use the api connection of their container

### Deprecated

- The JSS::APIConnection convenience class methods .computer_history, .send_computer_mdm_command, and .send_computer_mdm_command.

  These methods have been updated to work with the new methods in the MDM and ManagementHistory modules, but will be removed from JSS::APIConnection in a future release. Instead, call them directly from the JSS::Computer or JSS::MobileDevice classes, passing in the desired APIConnection if needed. Given the expansion of MDM commands and history details, maintaining the convenience methods in APIConnection is too prone to errors.

## [0.10.2] - 2018-02-16
### Fixed
-  *IMPORTANT*: Updating JSS::Extendable objects with no changes to ext. attribs will no longer erase all ext attrib values. (!)

## [0.10.1] - 2017-11-08
### Added
- Extension Attribute values that are populated by Script or LDAP can now be modified via Extendable#set_ext_attr.

  Previously, attempts to set the value would raise an exception, because those values aren't modifiable in the WebUI.
  However, the API itself allows such modification, so now ruby-jss does too.

- If you have access to the JSS MySQL database, ruby-jss now provides acces to the 'object history' of all APIObject subclasses.

  Unfortunately there is no way to get at this data via the API, but if you can connect to the MySQL database (JSS::DB_CNX.connect)
  then you can call `#object_history` and `#add_object_history_entry` for individual object instances.

### Fixed
- Error when no storage device on a Computer is marked as the boot drive (Thanks @christopher.kemp!)

- A few lingering methods that weren't multi-APIConnection aware, are now aware

## [0.10.0] - 2017-10-09
### Changed
- Working with multiple APIConnections is now far more flexible!
  There are three ways to work with multiple simultaneous APIConnection instances:
    1. Making a connection 'active', after which API calls go thru it (introduced in 0.9.0)
    2. Passing an APIConnection instance to methods that use the API
    3. Using an APIConnection instance itself to make API calls.

  The default/active connection continues to work as always, so your existing code will be fine.
  See the [documentation for the JSS::APIConnection class](http://www.rubydoc.info/gems/ruby-jss/JSS/APIConnection) for details.

- Improvement: Extendable module: only push changed EAs when `update` is called.

### Fixed
- Specifying port 443, as well as 8443, when connecting an APIConnection will default to using SSL. To force such a connection to NOT use SSL, provide the parameter `use_ssl: false`

- require 'English', rather than require 'english'. Thanks to HIMANSHU-ELIGIBLE @ github for catching & fixing this one.

- Popup extension attributes can always take a blank value.

- UserGroup members have a 'username' value, not 'name'

- APIConnection.map_all_ids wasn't honoring :refresh

### Added
- Two case-insentive string methods added to Array:
  - Array#jss_ci_include_string? Takes a string, returns true if the Array contains the string without regard to case.
        E.g. `['ThrAsHer'].jss_ci_include_string? 'thrasher' # => true`
  - Array#jss_ci_fetch_string Takes a string and fetches it from the array, regardless of case. Nil if not found.
        E.g. `['thrasher'].jss_ci_fetch_string 'ThrAsHer'  # => 'thrasher'`

- Computer objects now have a `last_enrolled` attribute

## [0.9.3] - 2017-08-08
### Added
- JSS::Computer instance now allow you to modify mac_address, alt_mac_address, udid, and serial_number.
  Note: even tho the WebUI doesn't allow editing of the serial_number, the API does and doing so can be useful
  for dealing with duplicate SN's when a new logic board with a new udid creates a new computer entry.

- JSS::Validate module, to consoliday generic data-validation methods. Methods will be moved to it from
  other places over time.

## [0.9.2] - 2017-07-25
### Fixed
- parsing of JSS versions > 9.99

## [0.9.0] - 2017-07-17
### Changed
- JSS::RestrictedSoftware class is now Creatable and Updatable.

- APIObject.fetch can be given a single value, which will be compared to the subclass's .all_ids,
  .all_names, and other list methods for the various lookup keys, and if a match is found, the object is returned. E.g. instead of
  JSS::Computer.fetch name: 'foo'  you can just use JSS::Computer.fetch 'foo'.
  Note that specifying the lookup key is always faster.

- the OTHER_LOOKUP_KEYS constants of APIObject subclasses can now reconize variations on a key, e.g. :serialnumber and
    :serial_number, or :macaddress and :mac_address

- Support for multiple APIConnection instances - you can connect to more than one server at a time and switch between them.

- APIConnection connection settings come first from the #connect params, then from Configuration,
  then from the Client setting (if the machine is a client), then from the module defaults

- APIConnection can now take an xml payload with #delete_rsrc

- JSS::Policy instances can now flush their logs

- JSS::Policy now has setters for server_side_activation and server_side_expriation.

### Added
- JSS::MobileDevice.all_apple_tvs class method

- JSS::MobileDevice.management_history method, and related methods in instances

- JSS::MobileDevice.send_mdm_command has been expanded to handle all MDM commands supported by the API *except* Wallpaper and PasscodeLockGracePeriod (some day soon hopefully)

- JSS::Server instances (as found in the JSS::APIConnection.server attribute) now have methods #activation_code and
  #organization

- JSS::Computer now can send MDM commands to instances via #blank_push #device_lock #erase_device and #remove_mdm_profile, or to
  arrays of computer identifiers using the JSS::Computer.send_mdm_command method.

- JSS::Computer now has class methods to retrieve the server-wide .inventory_collection_settings and
  .checkin_settings

- JSS::Computer instances now have access to the data in the History tab of the computer details page in
  the WebUI. Subset-specific methods are #usage_logs, #audits, #policy_logs, #completed_policies, #failed_policies, #casper_remote_logs, #screen_sharing_logs, #casper_imaging_logs, #user_location_history, and #app_store_history

- JSS::Computer instances now have an #application_usage method which takes a date range and returns an
  array of usage data.

- JSS::Computer instances now have access to their 'management data' (the stuff in the Management tab of
  the Computer details in the WebUI).  As well as the #management_data method, there are shortcut methods for the subsets: #smart_groups, #static_groups, & #patch_titles and in-scope items like:  #policies, #configuration_profiles, #ebooks, #app_store_apps, #restricted_software

### Fixed
- issue with handling of params to APIObject.make

## [0.8.3] - 2017-06-07
### Fixed
- Version parsing: empty version parts default to 0, e.g. 10.2 parses as 10.2.0

## [0.8.2] - 2017-06-07
### Fixed
- Some objects failed to locate their 'main subset' (the chunk of API data that contains the object name and id) correctly.

- Some versions of Gem::Version don't like dashes (which are part of SemVers).

## [0.8.1] - 2017-06-05
### Changed
- Support for the new semantic versioning of Jamf products starting with Jamf Pro 9.99

- The alpha 'Webhooks framework' has been removed from ruby-jss and will reappear soon as it's own project with a new name.

- JSS::APIObject and subclasses now have .fetch and .make class methods which are wrappers for .new. .fetch is the preferred way to retrieve instances of existing API objects, and .make for making not-yet-existing objects to be created in the JSS. The .new class method still works as before, but is considered deprecated.
- JSS::APIConnection now has a #rest_url attribute that returns the base of the url for the current REST connection, e.g. "https://jamf.company.com:8443/JSSResource", or nil if not connected.

### Fixed
- JSS::Package uploading and zipping wasn't worked correctly, should be now.

## [0.8.0] - 2017-04-07
### Changed
- Lots of code cleanup to follow RuboCop guidelines (more of this comming)

- APIConnection class is no longer a singleton. The first step towards the ability to swap between multiple connections.

- Improved APIConnection's ability to figure out default connection settings

- APIObject mixin module parsing is now handled automatically by the APIObject superclass.

- APIObject subclasses have predicate methods to see if they have various mixed-in abilities, e.g. #creatable?, #locatable?

- All handling of Category data in non-Category objects is in a new Categorizable mixin module.

### Added
- #port, #protocol, and #last_http_response to APIConnection instances

- APIConnection#post_rsrc and #put_rsrc now catch and re-raise HTTP 409 Conflict errors as JSS::ConflictError with error message about what caused the conflict.

- JSS::MobileDeviceApplication class

- JSS::Icon class, handled by the improved SelfServable mixin module

- JSS::Client.jamf_helper method now takes arg_string:, output_file: and abandon_process: parameters.

- executable bin/jamfHelperBackgrounder, wrapper to run jamfHelper as a stand-alone process, allowing polcies to continue while a window is displayed

- explicitly require the standard library 'English', and start using it rather than cryptic globals like $! and $@

- first attempts at adding SSL/TLS support to the Webhooks framework.
  - NOTE: the Webhooks framework is still 'alpha' code, and will be moved into a separate git repo eventually. It doesn't rely on ruby-jss.

### Fixed
- sometimes the port would default to 80 rather than 8443

- sometimes DB connections would double-disconnect, causing superfluous exceptions.

## [0.7.0] - 2017-02-01
### Changed
- subnet-update, the example command in the bin directory, has been renamed to negseg-update. It's also been cleaned up and uses the new functionality of JSS::NetworkSegment.

### Fixed
- JSS::NetworkSegment - many bugfixes and cleanup. I didn't really have a proper grasp of IP CIDR masks before and how they (don't) relate to the IP ranges used by Network Segments in the JSS. The CIDRs and full netmasks can still be used to set the ending addresses of NetworkSegment objects, but the #cidr method is gone, since it was meaningless for segments that didn't match subnet-ranges.

- JSS::DBConnection - fixed a bug where meaningless IO 'stream closed' errors would appear when closing the DB connection.

## [0.6.7] - 2017-01-03
### Added
- class JSS::WebHook, which requires Jamf Pro 9.97 or higher.
  - NOTE: This is access to the WebHooks themselves as defined in Jamf Pro, and is separate from the  WebHook-handling framework included in the previous release for testing.

## [0.6.6] - 2016-11-30
### Changed
- Change the mountpoint directory for JSS::DistributionPoint#mount to /tmp, because Sierra doesn't allow mounting in /Volumes except by root. (Thanks @LM2807! )

- Starting cleaning up code to better adhere to [RuboCop](http://rubocop.readthedocs.io/en/latest/) standards

- JSS::Policy, now creatable, and self-servable, and more attributes are updatable

- JSS::DBConnection#connect now returns the server hostname, to match the behavior of JSS::APIConnection#connect

### Added
- String#jss_to_pathname to convert Strings to Pathname instances in JSS::Configuration.

- JSS::Client: added .console_user method

- JSS::SelfServable, finally getting this module functional, at least for policies

- JSS::Creatable, added #clone method - all creatable objects can be cloned easily.

- JSS::APIObject, added .exist? and .valid_id class methods and #to_s instance method

- alpha version of a JSS WebHooks framwork

## [0.6.5] - 2016-08-10
### Changed
- Cleanup of redundant constants (Thanks @aurica!)

### Added
- JSS::ComputerInvitation class (Thanks @tostart-pickagreatname!)
- JSS::Account class (Thanks @JonPulsifer!)
- JSS::OSXConfigurationProfile class (Thanks @tostart-pickagreatname!)
- JSS::Computer: added methods #boot_drive, #filevault2_enabled?, and #filevault1_accounts

### Fixed
- Various small bugfixes & improvements

## [0.6.4] - 2016-03-24
### Changed
- JSS::Package#dlete can optionally delete the master file at the same time

- Updated the config file name to match the new gem name, maintaining backwards compatibility

- Improved error messages

### Added
- example ruby-jss.conf file with internal documentation

### Fixed
- Various small bugfixes & improvements

## [0.6.3] - 2016-03-09
Maintenence version bump to fix an issue uploading to rubygems.org

## [0.6.2] - 2016-03-08
As of v0.6.2, the github project, and rubygem have been renamed to 'ruby-jss'. The 'require' name is now 'jss'.

In part this was to make the name more in-line with other ruby gems, and also to get in line with Shea Craig's [python-jss](https://github.com/sheagcraig/python-jss) and Charles Edge's [swift-jss](https://github.com/krypted/swift-jss)

Yes we now have native API access in 3 languages!

The 'jss-api' gem has been updated one last time, also to v0.6.2. That gem has a dependency on ruby-jss v0.6.2 or greater, and if you require 'jss-api' with it, it merely requires 'jss' for you.  While that will provide backward-compatibility, please update your code to require 'jss' directly, since the jss-api wrapper gem won't be around forever.

### Changed
- Project & gem name are now 'ruby-jss'

### Added
- JSS::Package#os_ok? and JSS::Package#processor_ok? methods can now check those things against the package settings, and not attempt to install if the machine isn't up to snuff.

- JSS::ExtensionAttribute#latest_values always now includes :username in the returned data.

#### Fixed
- JSS::stdin_lines no longer uses a constant to store incoming stdin data at load time, which causes hangs when there's no terminal on stdin. Now stdin is only read when the method is called, and data stored in a module variable.

- JSS::Composer::mk_dmg fix for building/indexing dmg's, no longer creates an unreadable .Trashes folder.

- Several small typos and other tiny bugs.

## [0.6.1] - 2016-03-01
### Added
- JSS::Package#install now takes :alt_download_url argument.Can be used to specify a custom URL from which to download a pkg/dmg for installation with 'jamf install'. This allows the use of cloud distribution points.

- JSS::DistributionPoint: Added reachability methods, improved assessment of mount-success. #reachable_for_download? and #reachable_for_upload? will now return a boolean indicating if the DistPoint is reachable.

## [0.6.0] - 2016-01-06
This version of the jss-api gem incorporates changes needed for the upcoming release of d3 (a.k.a. depot3),
a package/patch management system for Casper, which was the reason for the jss-api gem to begin with.

As such, while the JSS module will continue to be a separate git repo, specific commits of it will be
submodules of the depot3 git repo, starting with this one, or one shortly hereafter.

### Changed
- JSS::DistributionPoint: #mount now defaults to read-only unless :rw is passed

- lots of code cleanup

- JSS::Package#install now returns a boolean indicating success of installation.
   The previous return value (the Process::Status of the 'jamf install' proceess) usually returned 0 exitstatus even if the pkg install failed.
   Now the actual install command is examined, and if its exitstatus is zero, Package#install returns true, else false.

- JSS::Package: better handling of API values like "None" and "No category assigned"

#### Added
- String: added #jss_to_time to convertion strings to Time objects using JSS::parse_time

- JSS::Package: added #type to return :pkg or :dmg

- JSS::APIConnection and JSS::DBConnection determines server hostname via several means if not yet connected

- JSS::APIConnection and JSS::DBConnection can test validitiy of a server

- JSS::DBConnection now has a DEFAULT_PORT constant

### Fixed
- new path to the jamf binary was corrected

- fixed the logic in using the :use_ssl arg to JSS::APIConnection::connect

- Composer module no longer adds redundant .pkg extensions

- JSS::DistributionPoint, bug fix when initializing with :id=>:master

- As of casper 9.72, the argument requirements have changed for 'jamf install' with http downloads. This is now handled correctly

## [0.5.8] - 2015-09-22
### Added
- client.rb: looks for the new ElCap+ location for the jamf binary, falls back to old location if not found.

- Locatable#clear_location public instance method added

- TimeoutError and AuthenticationError have been added to exceptions

- Policy objects now have a #run method - attempts to execute the policy locally.

### Fixed
- location.rb: location value setters are now properly converted to strings

- api_connection.rb: #connect now takes :use_ssl option (defaults to true)

- api_connection.rb: #connect will accept arbitrary ports when :use_ssl is true

## [0.5.7] - 2015-05-26
### Changed
- DBConnection.connect, and APIConnection.connect: include server name when prompting for password

- APIObject: auto-set @site and @category if applicable

- Package#upload_master_file: move autoupdate to appropriate location

### Fixed
- JSS.to_s_and_a now properly converts nils to "" and []

- DBConnection.connect gracefully handle reconnecting if the old connection went away

- Configuration: handle lack of ENV['HOME'] when trying to expand ~ to locate user-level config file.

- MobileDevice#unmanage_device: send_mdm_command is a class method, not an instance method

- Package: os_requirements default to empty array if unset in JSS

- Package#required_processor: remove buggy line of ancient, deprecated code

## [0.5.6] - 2014-11-04
### Changed
- now requires Ruby >= 1.9.3 and rest-client >= 1.7.0. Needed for Casper >= 9.61's lack of support for SSLv3.

- APIConnection now accepts :ssl_version option in the argument hash. Defaults to 'TLSv1'

- Configuration now supports the api_ssl_version key, used for the :ssl_version option of the APIConnection.

- the example programs have been moved to the bin directory, and are now included in the gem installation.

- many documentation updates as we adjust to being live

### Fixed
- minor bugfixes

## [0.5.0] - 2014-10-23
### Changed
- first opensource release
