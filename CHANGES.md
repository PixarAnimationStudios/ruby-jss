# Change History

v0.5.8 2015-09-22

bugfixes & cleanup
- location.rb: location value setters are now properly converted to strings
- api_connection.rb: #connect now takes :use_ssl option (defaults to true)

additions & features
- client.rb: looks for the new ElCap+ location for the jamf binary, falls back to old location if not found.
- Locatable#clear_location public instance method added
- TimeoutError and AuthenticationError have been added to exceptions
- Policy objects now have a #run method - attempts to execute the policy locally.

v0.5.7 2015-05-26

bugfixes & cleanup
- JSS.to_s_and_a now properly converts nils to "" and []
- DBConnection.connect gracefully handle reconnecting if the old connection went away
- DBConnection.connect, and APIConnection.connect: include server name when prompting for password
- Configuration: handle lack of ENV['HOME'] when trying to expand ~ to locate user-level config file.
- MobileDevice#unmanage_device: send_mdm_command is a class method, not an instance method
- APIObject: auto-set @site and @category if applicable
- Package: os_requirements default to empty array if unset in JSS
- Package#required_processor: remove buggy line of ancient, deprecated code
- Package#upload_master_file: move autoupdate to appropriate location

v0.5.6 2014-11-04

- now requires Ruby >= 1.9.3 and rest-client >= 1.7.0. Needed for Casper >= 9.61's lack of support for SSLv3.
- APIConnection now accepts :ssl_version option in the argument hash. Defaults to 'TLSv1'
- Configuration now supports the api_ssl_version key, used for the :ssl_version option of the APIConnection.
- the example programs have been moved to the bin directory, and are now included in the gem installation.
- many documentation updates as we adjust to being live
- minor bugfixes

v0.5.0 2014-10-23 

- first opensource release
