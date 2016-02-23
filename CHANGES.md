# Change History

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
