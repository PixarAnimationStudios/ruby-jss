# Change History

## v0.7.0 2017-02-01

- JSS::NetworkSegment - many bugfixes and cleanup. I didn't really have a proper grasp of IP CIDR masks before and how the (don't) related to the IP ranges used by Network Segments in the JSS. They CIDRs and full netmasks can still be used to set the ending addresses of NetworkSegment objects, but the #cidr method is gone, since it was meaningless for segments that didn't match subnet-ranges.
- subnect-update, the example command in the bin directory, has been renamed to negseg-update. It's also been cleaned up and uses the new functionality of JSS::NetworkSegment.
- JSS::DBConnection - fixed a bug where meaningless IO 'stream closed' errors would appear when closing the DB connection.

## v0.6.7 2017-01-03

- Added class JSS::WebHook, which requires Jamf Pro 9.97 or higher.
  - NOTE: This is access to the WebHooks themselves as defined in Jamf Pro, and is separate from the  WebHook-handling framework included in the previous release for testing.

## v0.6.6 2016-11-30

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

## v0.6.5 2016-08-10

- Cleanup of redundant constants (Thanks @aurica!)

- Added JSS::ComputerInvitation class (Thanks @tostart-pickagreatname!)

- Added JSS::Account class (Thanks @JonPulsifer!)

- Added JSS::OSXConfigurationProfile class (Thanks @tostart-pickagreatname!)

- JSS::Computer: added methods #boot_drive, #filevault2_enabled?, and #filevault1_accounts

- Various small bugfixes & improvements

## v0.6.4 2016-03-24

- JSS::Package#dlete can optionally delete the master file at the same time

- Added an example ruby-jss.conf file with internal documentation

- Various small bugfixes & improvements

- Updated the config file name to match the new gem name, maintaining backwards compatibility

- Improved error messages

## v0.6.3 2016-03-09

Maintenence version bump to fix an issue uploading to rubygems.org

## v0.6.2 2016-03-08

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

## v0.6.1 2016-03-01

#### additions & features

- JSS::Package#install now takes :alt_download_url argument.Can be used to specify a custom URL from which to download a pkg/dmg for installation with 'jamf install'. This allows the use of cloud distribution points.
- JSS::DistributionPoint: Added reachability methods, improved assessment of mount-success. #reachable_for_download? and #reachable_for_upload? will now return a boolean indicating if the DistPoint is reachable.

## v0.6.0 2016-01-06

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


## v0.5.8 2015-09-22

#### bugfixes & cleanup

- location.rb: location value setters are now properly converted to strings
- api_connection.rb: #connect now takes :use_ssl option (defaults to true)
- api_connection.rb: #connect will accept arbitrary ports when :use_ssl is true

#### additions & features

- client.rb: looks for the new ElCap+ location for the jamf binary, falls back to old location if not found.
- Locatable#clear_location public instance method added
- TimeoutError and AuthenticationError have been added to exceptions
- Policy objects now have a #run method - attempts to execute the policy locally.

## v0.5.7 2015-05-26

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

## v0.5.6 2014-11-04

- now requires Ruby >= 1.9.3 and rest-client >= 1.7.0. Needed for Casper >= 9.61's lack of support for SSLv3.
- APIConnection now accepts :ssl_version option in the argument hash. Defaults to 'TLSv1'
- Configuration now supports the api_ssl_version key, used for the :ssl_version option of the APIConnection.
- the example programs have been moved to the bin directory, and are now included in the gem installation.
- many documentation updates as we adjust to being live
- minor bugfixes

## v0.5.0 2014-10-23

- first opensource release
