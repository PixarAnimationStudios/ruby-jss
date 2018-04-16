# Change History

## v 0.12.0, 2018-04-16

- Simplification: when building .pkg's with JSS::Composer.mk_pkg, only two params are related to Package Signing: 'signing_identity:' the name of the signing identity to use, and and 'signing_options:' a string of all other signing-related CLI options that will be passed to the pkgbuild command, e.g. keychain locations, timestamps, certs, etc. For details, see `man pkgbuild`

- Improvement: Now augmenting ruby Hashes with an embeded 'recursive-open-struct' version of themselves. This simplifies accessing values from deeply-nested Hash structures, e.g. JSS::Computer#hardware instead of `computer_instance.hardware[:storage].first[:partition][:percentage_full]` you can do `computer_instance.hardware.jss_ros.storage.first.partition.percentage_full`.  See http://www.rubydoc.info/gems/ruby-jss/Hash for details. Uses the [recursive-open-struct gem](https://github.com/aetherknight/recursive-open-struct).

- Add: The computerapplications/application endpoint is now implemented as the JSS::Computer.application_installs class method so you can query lists of computers that have certain apps installed.

- Improvement: the JSS::Computer class is now defined in multiple files.  The single computer.rb file was getting far to unwieldy.

- Improvement: JSS::Client is now a module full of module methods rather than a class full of class methods. Functionally, nothing has changed, but since it is never meant to be instantiated, it logicially should not be a class.

- Fix: Setting the first icon of a newly-created JSS::Policy now works. Thanks @christopher.kemp for reporting this one

- Add: JSS::MobileDeviceConfigurationProfile is now more fleshed-out and is Updatable.

- Improvement: JSS::MobileDeviceConfigurationProfile and JSS::OSXConfigurationProfile now share an abstract parent class, JSS::ConfigurationProfile, containing common code.

- Fix: the SelfServable module was mis-handling 'user-removability' data for config profiles.

- Fix: Typo and missing method alias, caught by csfjeff @ github, issue #23

## v 0.11.0, 2018-03-12

- Fix: NoMethod error when saving JSS::Policy was due to a typo in a method call.

- Fix: Initialization of Creatable objects using certain mixins (Extendable, Sitable, Categorizable) either failed, or errored when trying to set their values. Now fixed. Thanks @mylescarrick for reporting this one.

- Improvement: Updated general attributes for computers and mobile devices
s
- Improvement: Computers and MobileDevices are now Creatable. Use the .make class method to create an unsaved instance, then .create/.save instance method to create the JSS record. Note: Mobile Devices need both a unique serial number and unique udid to be accepted by the API.

- Improvement: Handling of 'site' data is now done via the JSS::Sitable mixin module

- Improvement: When the JSS server's hostname ends with 'jamfcloud.com' default to SSL port 443 (vs 8443 for locally hosted JSSs)

- Improvement: ruby-jss now has a code of conduct for contributors.

- Improvement: now requires net-ldap v 0.16, for security fixes

- Add: All APIObject subclasses can be deleted without instantiating, via the .delete class method, providing an array of ids

- Improvement: All handling of MDM commands is in the JSS::MDM module, which is mixed in to Computer, ComputerGroup, MobileDevice, and MobileDeviceGroup

  *WARNING* Due to the expanded functionality of MDM commands overall, the syntax for calling .send_mdm_command may have changed, depening on how you used it. Please test your code before updating.

- Fix: Scope objects use the api connection of their container

- Improvement: 'devmode', use `JSS.devmode \[:on|:off]`` to set, and `JSS.devmode?`` to query.  Useful for developers, esp. in `irb` who want, e.g. to have a method output some state when in devmode, instead of/as well as behaving normally. This is currently the case for `JSS::MDM.send_mdm_command`.  When devmode? is true, the XML sent to the API for the command is printed to stdout before the command is sent to the target machine.

- Improvement: Computer app usage & mgmt data methods are now class methods, so can be used without instantiating the computer.
  The instance methods remain, and they now just use the class methods.

- Improvement/Change: All handling of management history for Computers and MobileDevices is in the new ManagementHistory module. The module
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

- Deprecated: The JSS::APIConnection convenience class methods .computer_history, .send_computer_mdm_command, and .send_computer_mdm_command.

  These methods have been updated to work with the new methods in the MDM and ManagementHistory modules, but will be removed from JSS::APIConnection in a future release. Instead, call them directly from the JSS::Computer or JSS::MobileDevice classes, passing in the desired APIConnection if needed. Given the expansion of MDM commands and history details, maintaining the convenience methods in APIConnection is too prone to errors.


## v 0.10.2, 2018-02-16

-  *IMPORTANT BUG FIX*: Updating JSS::Extendable objects with no changes to ext. attribs will no longer erase all ext attrib values. (!)

## v 0.10.1, 2017-11-08

- Add: Extension Attribute values that are populated by Script or LDAP can now be modified via Extendable#set_ext_attr.

  Previously, attempts to set the value would raise an exception, because those values aren't modifiable in the WebUI.
  However, the API itself allows such modification, so now ruby-jss does too.

- Add: If you have access to the JSS MySQL database, ruby-jss now provides acces to the 'object history' of all APIObject subclasses.

  Unfortunately there is no way to get at this data via the API, but if you can connect to the MySQL database (JSS::DB_CNX.connect)
  then you can call `#object_history` and `#add_object_history_entry` for individual object instances.

- Fix: Error when no storage device on a Computer is marked as the boot drive (Thanks @christopher.kemp!)

- Fix: A few lingering methods that weren't multi-APIConnection aware, are now aware

## v0.10.0, 2017-10-09

- Improvement: Working with multiple APIConnections is now far more flexible!

    There are three ways to work with multiple simultaneous APIConnection instances:
    1. Making a connection 'active', after which API calls go thru it (introduced in 0.9.0)
    2. Passing an APIConnection instance to methods that use the API
    3. Using an APIConnection instance itself to make API calls.

  The default/active connection continues to work as always, so your existing code will be fine.
  See the [documentation for the JSS::APIConnection class](http://www.rubydoc.info/gems/ruby-jss/JSS/APIConnection) for details.

- Fix: Specifying port 443, as well as 8443, when connecting an APIConnection will default to using SSL. To force such a connection to NOT use SSL, provide the parameter `use_ssl: false`

- Fix: require 'English', rather than require 'english'. Thanks to HIMANSHU-ELIGIBLE @ github for catching & fixing this one.

- Fix: Popup extension attributes can always take a blank value.

- Fix: UserGroup members have a 'username' value, not 'name'

- Add: Two case-insentive string methods added to Array:
  - Array#jss_ci_include_string? Takes a string, returns true if the Array contains the string without regard to case.
        E.g. `['ThrAsHer'].jss_ci_include_string? 'thrasher' # => true`
  - Array#jss_ci_fetch_string Takes a string and fetches it from the array, regardless of case. Nil if not found.
        E.g. `['thrasher'].jss_ci_fetch_string 'ThrAsHer'  # => 'thrasher'`
- Fix: APIConnection.map_all_ids wasn't honoring :refresh

- Improvement: Extendable module: only push changed EAs when `update` is called.

- Add: Computer objects now have a `last_enrolled` attribute

## v0.9.3, 2017-08-08

- Add: JSS::Computer instance now allow you to modify mac_address, alt_mac_address, udid, and serial_number.
  Note: even tho the WebUI doesn't allow editing of the serial_number, the API does and doing so can be useful
  for dealing with duplicate SN's when a new logic board with a new udid creates a new computer entry.

- Add: JSS::Validate module, to consoliday generic data-validation methods. Methods will be moved to it from
  other places over time.

## v0.9.2, 2017-07-25

- Fix: parsing of JSS versions > 9.99

## v0.9.0, 2017-07-17

- Add: JSS::MobileDevice.all_apple_tvs class method
- Add: JSS::MobileDevice.management_history method, and related methods in instances
- Add: JSS::MobileDevice.send_mdm_command has been expanded to handle all MDM commands supported by the API *except* Wallpaper and PasscodeLockGracePeriod (some day soon hopefully)
- Improvement: JSS::RestrictedSoftware class is now Creatable and Updatable.
- Add: JSS::Server instances (as found in the JSS::APIConnection.server attribute) now have methods #activation_code and
  #organization
- Add: JSS::Computer now can send MDM commands to instances via #blank_push #device_lock #erase_device and #remove_mdm_profile, or to
  arrays of computer identifiers using the JSS::Computer.send_mdm_command method.
- Add: JSS::Computer now has class methods to retrieve the server-wide .inventory_collection_settings and
  .checkin_settings
- Add: JSS::Computer instances now have access to the data in the History tab of the computer details page in
  the WebUI. Subset-specific methods are #usage_logs, #audits, #policy_logs, #completed_policies, #failed_policies, #casper_remote_logs, #screen_sharing_logs, #casper_imaging_logs, #user_location_history, and #app_store_history
- Add: JSS::Computer instances now have an #application_usage method which takes a date range and returns an
  array of usage data.
- Add: JSS::Computer instances now have access to their 'management data' (the stuff in the Management tab of
  the Computer details in the WebUI).  As well as the #management_data method, there are shortcut methods for the subsets: #smart_groups, #static_groups, & #patch_titles and in-scope items like:  #policies, #configuration_profiles, #ebooks, #app_store_apps, #restricted_software
- Fix: issue with handling of params to APIObject.make
- Improvement: APIObject.fetch can be given a single value, which will be compared to the subclass's .all_ids,
  .all_names, and other list methods for the various lookup keys, and if a match is found, the object is returned. E.g. instead of
  JSS::Computer.fetch name: 'foo'  you can just use JSS::Computer.fetch 'foo'.
  Note that specifying the lookup key is always faster.
- Improvement: the OTHER_LOOKUP_KEYS constants of APIObject subclasses can now reconize variations on a key, e.g. :serialnumber and
    :serial_number, or :macaddress and :mac_address
- Improvement: Support for multiple APIConnection instances - you can connect to more than one server at a time and switch between them.
- Improvement: APIConnection connection settings come first from the #connect params, then from Configuration,
  then from the Client setting (if the machine is a client), then from the module defaults
- Improvement: APIConnection can now take an xml payload with #delete_rsrc
- Improvement: JSS::Policy instances can now flush their logs
- Improvement: JSS::Policy now has setters for server_side_activation and server_side_expriation.

## v0.8.3, 2017-06-07

- Fix: Version parsing: empty version parts default to 0, e.g. 10.2 parses as 10.2.0

## v0.8.2, 2017-06-07

- Fix: Some objects failed to locate their 'main subset' (the chunk of API data that contains the object name and id) correctly.
- Fix: Some versions of Gem::Version don't like dashes (which are part of SemVers).


## v0.8.1, 2017-06-05

- Improvement: Support for the new semantic versioning of Jamf products starting with Jamf Pro 9.99
- The alpha 'Webhooks framework' has been removed from ruby-jss and will reappear soon as it's own project with a new name.
- Fix: JSS::Package uploading and zipping wasn't worked correctly, should be now.
- Improvement: JSS::APIObject and subclasses now have .fetch and .make class methods which are wrappers for .new. .fetch is the preferred way to retrieve instances of existing API objects, and .make for making not-yet-existing objects to be created in the JSS. The .new class method still works as before, but is considered deprecated.
- Improvement: JSS::APIConnection now has a #rest_url attribute that returns the base of the url for the current REST connection, e.g. "https://jamf.company.com:8443/JSSResource", or nil if not connected.

## v0.8.0, 2017-04-07

- Change: Lots of code cleanup to follow RuboCop guidelines (more of this comming)
- Fix: sometimes the port would default to 80 rather than 8443
- Fix?: sometimes DB connections would double-disconnect, causing superfluous exceptions.
- Change: APIConnection class is no longer a singleton. The first step towards the ability to swap between multiple connections.
- Add: #port, #protocol, and #last_http_response to APIConnection instances
- Change: Improved APIConnection's ability to figure out default connection settings
- Add: APIConnection#post_rsrc and #put_rsrc now catch and re-raise HTTP 409 Conflict errors as JSS::ConflictError with error message about what caused the conflict.
- Improvement: APIObject mixin module parsing is now handled automatically by the APIObject superclass.
- Improvement: APIObject subclasses have predicate methods to see if they have various mixed-in abilities, e.g. #creatable?, #locatable?
- Change: All handling of Category data in non-Category objects is in a new Categorizable mixin module.
- Add: JSS::MobileDeviceApplication class
- Add: JSS::Icon class, handled by the improved SelfServable mixin module
- Add: JSS::Client.jamf_helper method now takes arg_string:, output_file: and abandon_process: parameters.
- Add: executable bin/jamfHelperBackgrounder, wrapper to run jamfHelper as a stand-alone process, allowing polcies to continue while a window is displayed
- Add: explicitly require the standard library 'English', and start using it rather than cryptic globals like $! and $@
- Add: first attempts at adding SSL/TLS support to the Webhooks framework.
  - NOTE: the Webhooks framework is still 'alpha' code, and will be moved into a separate git repo eventually. It doesn't rely on ruby-jss.

## v0.7.0, 2017-02-01

- JSS::NetworkSegment - many bugfixes and cleanup. I didn't really have a proper grasp of IP CIDR masks before and how they (don't) relate to the IP ranges used by Network Segments in the JSS. The CIDRs and full netmasks can still be used to set the ending addresses of NetworkSegment objects, but the #cidr method is gone, since it was meaningless for segments that didn't match subnet-ranges.
- subnect-update, the example command in the bin directory, has been renamed to negseg-update. It's also been cleaned up and uses the new functionality of JSS::NetworkSegment.
- JSS::DBConnection - fixed a bug where meaningless IO 'stream closed' errors would appear when closing the DB connection.

## v0.6.7, 2017-01-03

- Added class JSS::WebHook, which requires Jamf Pro 9.97 or higher.
  - NOTE: This is access to the WebHooks themselves as defined in Jamf Pro, and is separate from the  WebHook-handling framework included in the previous release for testing.

## v0.6.6, 2016-11-30

- Added String#jss_to_pathname to convert Strings to Pathname instances in JSS::Configuration.
- JSS::DBConnection#connect now returns the server hostname, to match the behavior of JSS::APIConnection#connect
- JSS::Client: added .console_user method
- JSS::Policy, now creatable, and self-servable, and more attributes are updatable
- JSS::SelfServable, finally getting this module functional, at least for policies
- JSS::Creatable, added #clone method - all creatable objects can be cloned easily.
- JSS::APIObject, added .exist? and .valid_id class methods and #to_s instance method
- Change the mountpoint directory for JSS::DistributionPoint#mount to /tmp, because Sierra doesn't allow mounting in /Volumes except by root. (Thanks @LM2807! )
- Starting cleaning up code to better adhere to [RuboCop](http://rubocop.readthedocs.io/en/latest/) standards
- Added alpha version of a JSS WebHooks framwork

## v0.6.5, 2016-08-10

- Cleanup of redundant constants (Thanks @aurica!)
- Added JSS::ComputerInvitation class (Thanks @tostart-pickagreatname!)
- Added JSS::Account class (Thanks @JonPulsifer!)
- Added JSS::OSXConfigurationProfile class (Thanks @tostart-pickagreatname!)
- JSS::Computer: added methods #boot_drive, #filevault2_enabled?, and #filevault1_accounts
- Various small bugfixes & improvements

## v0.6.4, 2016-03-24

- JSS::Package#dlete can optionally delete the master file at the same time
- Added an example ruby-jss.conf file with internal documentation
- Various small bugfixes & improvements
- Updated the config file name to match the new gem name, maintaining backwards compatibility
- Improved error messages

## v0.6.3, 2016-03-09

Maintenence version bump to fix an issue uploading to rubygems.org

## v0.6.2, 2016-03-08

As of v0.6.2, the github project, and rubygem have been renamed to 'ruby-jss'. The 'require' name is now 'jss'.

In part this was to make the name more in-line with other ruby gems, and also to get in line with Shea Craig's [python-jss](https://github.com/sheagcraig/python-jss) and Charles Edge's [swift-jss](https://github.com/krypted/swift-jss)

Yes we now have native API access in 3 languages!

The 'jss-api' gem has been updated one last time, also to v0.6.2. That gem has a dependency on ruby-jss v0.6.2 or greater, and if you require 'jss-api' with it, it merely requires 'jss' for you.  While that will provide backward-compatibility, please update your code to require 'jss' directly, since the jss-api wrapper gem won't be around forever.

#### additions & features

- JSS::Package#os_ok? and JSS::Package#processor_ok? methods can now check those things against the package settings, and not attempt to install if the machine isn't up to snuff.
- JSS::ExtensionAttribute#latest_values always now includes :username in the returned data.

#### bugfixes

- JSS::stdin_lines no longer uses a constant to store incoming stdin data at load time, which causes hangs when there's no terminal on stdin. Now stdin is only read when the method is called, and data stored in a module variable.
- JSS::Composer::mk_dmg fix for building/indexing dmg's, no longer creates an unreadable .Trashes folder.
- Several small typos and other tiny bugs.

## v0.6.1, 2016-03-01

#### additions & features

- JSS::Package#install now takes :alt_download_url argument.Can be used to specify a custom URL from which to download a pkg/dmg for installation with 'jamf install'. This allows the use of cloud distribution points.
- JSS::DistributionPoint: Added reachability methods, improved assessment of mount-success. #reachable_for_download? and #reachable_for_upload? will now return a boolean indicating if the DistPoint is reachable.

## v0.6.0, 2016-01-06

This version of the jss-api gem incorporates changes needed for the upcoming release of d3 (a.k.a. depot3),
a package/patch management system for Casper, which was the reason for the jss-api gem to begin with.

As such, while the JSS module will continue to be a separate git repo, specific commits of it will be
submodules of the depot3 git repo, starting with this one, or one shortly hereafter.


#### bugfixes & cleanup

- new path to the jamf binary was corrected
- fixed the logic in using the :use_ssl arg to JSS::APIConnection::connect
- Composer module no longer adds redundant .pkg extensions
- JSS::DistributionPoint, bug fix when initializing with :id=>:master
- JSS::DistributionPoint: #mount now defaults to read-only unless :rw is passed
- String: added #jss_to_time to convertion strings to Time objects using JSS::parse_time
- JSS::Package: better handling of API values like "None" and "No category assigned"
- JSS::Package: added #type to return :pkg or :dmg
- JSS::Package: Changes to #install, including return value! See NOTES below.
- lots of code cleanup

#### additions & features

- JSS::APIConnection and JSS::DBConnection determines server hostname via several means if not yet connected
- JSS::APIConnection and JSS::DBConnection can test validitiy of a server
- JSS::DBConnection now has a DEFAULT_PORT constant


NOTES:

Important: Package#install now returns a boolean indicating success of installation.
The previous return value (the Process::Status of the 'jamf install' proceess) usually returned 0 exitstatus even if the pkg install failed.
Now the actual install command is examined, and if its exitstatus is zero, Package#install returns true, else false.

Also: As of casper 9.72, the argument requirements havechanged for 'jamf install' with http downloads. This is now handled correctly


## v0.5.8, 2015-09-22

#### bugfixes & cleanup

- location.rb: location value setters are now properly converted to strings
- api_connection.rb: #connect now takes :use_ssl option (defaults to true)
- api_connection.rb: #connect will accept arbitrary ports when :use_ssl is true

#### additions & features

- client.rb: looks for the new ElCap+ location for the jamf binary, falls back to old location if not found.
- Locatable#clear_location public instance method added
- TimeoutError and AuthenticationError have been added to exceptions
- Policy objects now have a #run method - attempts to execute the policy locally.

## v0.5.7, 2015-05-26

#### bugfixes & cleanup

- JSS.to_s_and_a now properly converts nils to "" and []
- DBConnection.connect gracefully handle reconnecting if the old connection went away
- DBConnection.connect, and APIConnection.connect: include server name when prompting for password
- Configuration: handle lack of ENV['HOME'] when trying to expand ~ to locate user-level config file.
- MobileDevice#unmanage_device: send_mdm_command is a class method, not an instance method
- APIObject: auto-set @site and @category if applicable
- Package: os_requirements default to empty array if unset in JSS
- Package#required_processor: remove buggy line of ancient, deprecated code
- Package#upload_master_file: move autoupdate to appropriate location

## v0.5.6, 2014-11-04

- now requires Ruby >= 1.9.3 and rest-client >= 1.7.0. Needed for Casper >= 9.61's lack of support for SSLv3.
- APIConnection now accepts :ssl_version option in the argument hash. Defaults to 'TLSv1'
- Configuration now supports the api_ssl_version key, used for the :ssl_version option of the APIConnection.
- the example programs have been moved to the bin directory, and are now included in the gem installation.
- many documentation updates as we adjust to being live
- minor bugfixes

## v0.5.0, 2014-10-23

- first opensource release
