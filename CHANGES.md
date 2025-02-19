# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project attempts to adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## _IMPORTANT_: Known Security Issue in v1.5.3 and below

Versions of ruby-jss prior to 1.6.0 contain a known security issue due to how we were using the 'plist' gem.

This has been resolved in 1.6.0, which now uses the CFProperlyList gem.

__Please update all installations of ruby-jss to at least v1.6.0.__

Many many thanks to actae0n of Blacksun Hackers Club for reporting this issue and providing examples of how it could be exploited.

--------
## \[4.2.0] Unreleased

### Moving forward with the Jamf Pro API
With this release, we begin the long process of porting existing classes from the Classic API to the Jamf Pro API where possible, starting with `Jamf::Package`. So far, our implementation of classes from the Jamf Pro API has been limited to those not already implemented via the Classic API.

However, because of our stated goals for implementing things in the Jamf Pro API (see [README-2.0.0.md](README-2.0.0.md)), we can't just change the existing classes without breaking lots of code. For example, in order to eliminate various 'hidden permissions requirements' and adhere more closely to the actual API, we're [eliminating cross-object validation](README-2.0.0.md#cross-object-validation-in-setters). 

For Packages, this means that when setting the categoryId, you must provide an id, not a category name. In Jamf::Package, using the Classic API, you could provide a name, and ruby-jss would look at the categories in the API and validate/convert to an id. This required 'undocumented' permissions to see the category endpoints when working with the package endpoints. NOTE: if you have read-permissions on categories, you can still use the `Jamf::Category.valid_id` method to convert from names to ids yourself. That method is available for all collection classes in both APIs.

In order to move forward with Jamf Pro-based classes, while providing reasonable backward compatibility, here's the plan:

  - For each class being migrated, and new class, prepended with `J` will be created.  So for accessing packages via the Jamf Pro API, we are introducing the class `Jamf::JPackage`. We've had an experimental  Jamf Pro version of Jamf::JpBuilding for a while, and it has been renamed to `Jamf::JBuilding` 
  - The original Classic API-based class will be marked as deprecated when the matching J-class is released.
  - The deprecated classes will exist for at least one year (probably longer) but will get few, if any, updates, mostly limited to security-related fixes. As of this release, `Jamf::Package` and `Jamf::Building` are deprecated. 
  - During the deprecation period, please update all your code to use the new Jamf Pro API-based classes.
  - When the older Classic API-based class is actually removed, the remaning Jamf Pro API-based class will be aliased back to the original name, without the `J`. So at that point `Jamf::Package` and `Jamf::JPackage` will be the same class. At this time please start updating your code to use the non-J version of the class name.
  - After some long-ish period of time (2-5 years?), the `J` version of the class name will be removed. Or - maybe not! Aliases are cheap :-)

If you have thoughts or comments on this, please reach out:
  - [Open an issue on github](https://github.com/PixarAnimationStudios/ruby-jss/issues)
  - [Email the developers at ruby-jss@pixar.com](mailto:ruby-jss@pixar.com)
  - Join the conversation in the [#ruby-jss Macadmins Slack Channel](https://macadmins.slack.com/archives/C03C7F563MK)

### Added
  - `Jamf::JPackage`: The first major migration of a class from the Classic to the Jamf Pro API.
    - Implements the /v1/packages endpoints
    - Support for manifests
    - Support for uploads to the /v1/packages/{id}/upload endpoint via the `#upload` method
    - Implements the /v1/deploy-package endpoint via the `#deploy_via_mdm` instance method. For this to work:
      - The endpoint must be enabled - contact Jamf Support.
      - The package must have a manifest
      - The .pkg file must be a "Product Archive", e.g. it must contain a 'Distribution' file, as when created with the `productbuild` command. Component packages created with `pkgbuild` will not work.
      - The .pkg file must be signed.
  
### Changed
  - `Jamf::JpBuilding` is now known as `Jamf::JBuilding`

### Fixed
  - [Github issue #102](https://github.com/PixarAnimationStudios/ruby-jss/issues/102): Apply redundant boolean value to indicate that a MobileDeviceApplication is/is not in Self Service. Thanks @carolinebeauchamp!

  - [Github #103](https://github.com/PixarAnimationStudios/ruby-jss/pull/103) Fixed and issue where linking a mobile device application to VPP failed as the vpp_admin_account_id wasn't included in the XML. Thanks @carolinebeauchamp!

  - [Github #104](https://github.com/PixarAnimationStudios/ruby-jss/pull/104) Add allow_user_to_delete attribute. Thanks @carolinebeauchamp!

  - [Github #105](https://github.com/PixarAnimationStudios/ruby-jss/pull/105) Fix configuration preferences in MobileDeviceApplication. Thanks @carolinebeauchamp!

  - Some lingering method parameter fixes for ruby 3.x compatibility

  - Fix for `Jamf::Group#remove_member`

  - Fixes for `Jamf::Scopable::Scope#set_exclusions`, `#set_limitations` and more.

  - Fix to ensure passing correct connection object when fetching.

### Deprecated
  - `Jamf::Package` and `Jamf::Building` are now deprecated amd will be removed in a future release. Please update your code to use `Jamf::JBuilding` and `Jamf::JPackage`

  - Auto-generated OAPISchemas are no longer used _directly_. There's still too much inconsistency and other problems that arise from using them as we were. See the NOTE from the previous release. 

    For the forseeable future we'll keep the overall structure of the class/mixin hierarchy, and will probably use the auto-generated classes for reference, but as new classes are added to ruby-jss via the Jamf Pro API, the `OAPISchemas` classes will be hand-tweaked and hand-maintained as needed, just like APIObject classes always have been for objects in the Classic API. 

    To start with, we're keeping the ones currently in use (about 40 of them) where they've always lived, in the `lib/jamf/api/jamf_pro/oapi_schemas` directory, and the new bespoke ones will go there also. The other ~550 unused auto-generated classes will be removed from ruby-jss.  
    
    For details about how the've been auto-generated, see the `generate_object_models` tool in the bin directory.

--------
## \[4.1.1] 2024-06-25

### Changed
  - `expand_min_os` (used when specifying min. OS for Packages and Scripts) now expands up to macOS v30, so we have 15 years to hopefully not need to use it anymore.

  - Auto-generated base classes from OAPI3 schema updated to Jamf Pro 11.6.1.  See NOTE below.

### Fixed

  - `LdapServer.check_membership` no longer fails or gives invalid responses when you provide a connection object via `cnx:`
  
  - A bug in Jamf::PatchTitle which prevented use of non-default connection objects.
  
  - Some ObjectModel classes from the OAPI3 schema were not getting generated, causing problems when using Zeitwerk's `eager_load`. Thanks to @j-o-lantern0422 and @jcruce13 for reporting the issue, and @nick-f for providing a fix!
    
    NOTE: Given the nature of this issue, along with known inconsistencies in the data structures and naming of items in the OAPI3 schema, plus the fact that we're starting to migrate to the JP API for more complex object handling (e.g. `Jamf::MobileDevice`)  we're probably going to stop using the auto-generated `Jamf::OAPISchemas` classes - at least in the way we have been using them. Most likely we'll still generate them, but then hand-edit them to create more robust, bespoke classes for the items we implement (as we did in the Classic API), and only include those required for the objects implemented. These changes shouldn't affect compatibility. Feedback is welcome, via GitHub or The [#ruby-jss channel in Macadmins Slack](https://macadmins.slack.com/archives/C03C7F563MK) 

--------
## \[4.1.0] 2024-04-06

### Changed

  - ruby-jss now uses version 2.0 or higher of [Faraday](https://lostisland.github.io/faraday/#/). This required minor changes to how https connections are established.
  
--------
## \[4.0.0] 2024-02-05

### Changed
  - Jamf::ComputerPrestage now accesses the v3 endpoints as needed - the v1 and some v2 endpoints are deprecated and will be removed from the Jamf Pro API sometime soon
  
  - Jamf::Prestage (ComputerPrestage and MobileDevicePrestage) no longer accesses Jamf::DeviceEnrollment for pre-validation. The API itself will report these kinds of errors when prestage scope changes are saved. See the ['Cross-object valildation in setters' section of the file _README-2.0.0.md_](README-2.0.0.md#cross-object-validation-in-setters)

  - Jamf::Prestage (ComputerPrestage and MobileDevicePrestage) no longer caches any data from the server. All methods that take a `refresh` parameter (positional or named) will ignore that parameter and always fetch fresh data. This applies to mostly to the current scope (assignments) for the prestages. This is in line with the ['API data are no longer cached' section of the file _README-2.0.0.md](README-2.0.0.md#api-data-are-no-longer-cached-) (and also, the data was being cached in an inappropriate place).  If making many calls at once, consisider capturing the data in your own variable. See also the deprecations listed below.

### Added
  - Support for API Roles and API Clients (requires Jamf Pro 10.49 and up). 
    - Two new classes: `Jamf::APIRole` and `Jamf::APIClient` provide access to the definitions of these objects via the 'api-roles' and 'api-integrations' endpoints respectively. There are also methods for listing all available privileges for defining roles, and for rotating the clientSecret of clients.

    - Connections can now be made using API clients. When specifying connection parameters, just use `client_id:` instead of `user:` and `client_secret` instead of `pw:`. For example:  
      
      `Jamf.cnx.connect  client_id: "a83cb7bc-5a61-4e5f-b894-5d63dca2e355", client_secret: "seCretString", host: 'jamfpro.company.com', port: 8443`  

      NOTE that 'keep_alive' cannot be used with API Clients - the tokens generated with them will expire at the appropriate time, which is usually much shorter than the session timeout for standard connections.

### Fixed
  - Bugfix when flushing or refreshing cached data
  - Bugfix when validating data for saving newly-created objects to the Jamf Pro API

### Deprecated
  - Jamf::Prestage (ComputerPrestage and MobileDevicePrestage): the `refresh` parameter will be removed from all class and instance methods in a future version of ruby-jss. It currently is still accepted, but does nothing. See the changes listed above.

--------
## \[3.2.1] 2023-09-12

### Fixed
  - Don't look at the management_status of unmanaged computers, it doesn't exist.

--------
## \[3.2.1] 2023-09-08

### Fixed
  - Scopes are properly maintained when using #clone on Policy and PatchPolicy instances.  
    Note: the data loss issue in addressed is in the previous version still applies. If the original policy being cloned has any `jss_users` or `jss_user_groups` defined in the targets or exclusions. they will be lost when saving the clone.
    
--------
## \[3.2.0] 2023-09-05

### Added 
  - Several new attributes to Jamf::Computer instances: 
    - `#enrolled_via_ade?` Boolean
    - `#mdm_capable?` Boolean
    - `#supervised?` Boolean
    - `#user_approved_enrollment?` Boolean
    - `#user_approved_mdm?` Boolean
    - `#mdm_profile_expiration` Time


### Changed
  - Improved handling of known API bug in Jamf::Scopable::Scope.  

    There is a long-standing bug in working with 'scope' via the Classic API, which can cause data-loss when you have 'Users' and 'User Groups' (known in the api data as `jss_users` and `jss_user_groups`) defined in the targets or exclusions. Thanks to @yanniks on GitHub, I recently learned that the bug only affects a few API objects, namely Policies and PatchPolicies.  

    This release of ruby-jss will properly handle jss_users and jss_user_groups in all scopes where the API can handle them. In Policy and PatchPolicy objects, those values aren't allowed, since the API can't deal with them. If you edit any other aspect of the scope of one of those obects in ruby-jss, you'll get a warning that saving your changes may cause data-loss - deleting any defined Users and User Groups in the targets or exclusions. If the scope really doesn't use any Users or User Groups, you should be OK saving your changes. To prevent the warnings, call `Jamf::Scopable::Scope.do_not_warn_about_policy_scope_bugs` before changing any scopes.  

    For more details, see the discussion in the comments/docs for the Jamf::Scopeable::Scope class in lib/jamf/api/classic/api_objects/scopable/scope.rb or in the [rubydocs page for the Scope class](https://www.rubydoc.info/gems/ruby-jss/Jamf/Scopable/Scope).  

    Many thanks to @yanniks for bringing to my attention that the bug doesn't occur in all scopes.

  - Warn of API bug when using jss_user_groups as scope targets of OSXConfigurationProfiles

    We discovered a new (to us) isolated occurrance of the long-standing XML Array => JSON Hash bug
    (which can cause data loss). If you have more that one jss_user_groups defined as scope targets
    of a OSXConfigurationProfile, the API will only return the last of those groups in the JSON data, 
    and saving changes to the profile via ruby-jss will remove the other groups from the Profile in 
    Jamf. 
    
    This seems to only affect scope targets of OSXConfigurationProfiles - groups used in exclusions
    seem to be fine, as do other scopable objects that uses jss_user_groups anywhere in their scope.

    When you edit the scope of a scopable object and ruby-jss notices this API bug applies, you'll see a warning that saving changes to the scope may cause data loss. To disable these warnings, call `Jamf::Scopable::Scope.do_not_warn_about_array_hash_scope_bugs` before changing any scopes.  

    For more details, see the discussion in the comments/docs for the Jamf::Scopeable::Scope class in lib/jamf/api/classic/api_objects/scopable/scope.rb or in the [rubydocs page for the Scope class](https://www.rubydoc.info/gems/ruby-jss/Jamf/Scopable/Scope).  


### Fixed
  - `Jamf::DeviceEnrollment.device` no longer uses String#upcase!, which fails on frozen strings. Instead just use String#casecmp?
  - `Jamf::APIConnection::Token#account` now correctly returns an instance of `Jamf::OAPISchemas::AuthorizationV1` 

## \[3.1.0] 2023-06-06

### Added
  - Jamf::Computer.filevault_info and Jamf::Computer#filevault_info can retrieve FileVault info from v1/computer-inventory/filevault and related endpoints
  - Jamf::Computer.recovery_lock_password and Jamf::Computer#recovery_lock_password can retrieve stored recovery lock passwords
  - Jamf::Pager#last_fetched_page - Integer, the last page returned by #fetch_next_page
  - There are now several ways to set scopes to all targets.
    - The original #include_all has been renamed #set_all_targets, and #include_all is an alias to it
    - The symbol :all can be passed to the #set_targets, and #add_target methods as they 'key' parameter, and they will just call #set_all_targets
    - There is now a setter #all_targets=(bool) which calls #set_all_targets, or sets @all_targets to false
    - So All of these are identical:
      - `some_scope.set_all_targets`
      - `some_scope.include_all`
      - `some_scope.set_targets :all`
      - `some_scope.add_target :all`
      - `some_scope.all_targets = true`

### Fixed
  - Fixed a bug in Jamf::Pager#initialize when constructing the query-path of the paged resource URL
  - Fixed a bug in Jamf::Pager#initialize: The instantiate: parameter takes a class, not a boolean
  - Fixed a bug in Jamf::CollectionResource.pager: The instantiate: parameter takes a boolean, but must pass a class to Jamf::Pager#initialize
  - Jamf::OAPIObject (base-class) can now instantiate objects that hold a single value

### Changed
  - Auto-generated OAPISchemas have been refreshed from Jamf Pro 10.46.0


## \[3.0.0] - 2023-05-22
Major version bump because changes to policy log flushing are not backward compatible.

### Added
  - Jamf::Policy.flush_logs_for_computers: formerly private class method, now public and used for flushing policy logs for specific computers.

### Fixed
  - Fix bug in MDM enable_lost_mode instance method, and make the default behavior match the API
  - Specify the connection instance when validating ids in MacOSManagedUpdates
  - Send mandatory field 'name' with a MobileDeviceApplication request (Thanks @yanniks!)
  - Policy Log Flushing now reflects API limitation: You can flush logs for a policy for all computers, or for a computer for all policies, but not specific policies for specific computers. See Jamf::Policy.flush_logs and Jamf::Policy.flush_logs_for_computers
  - A validation method wasn't passing cnx param correctly.

### Changed
  - MacOSManagedUpdates.send_managed_os_update takes symbols or strings as the updateAction, a key or a value from the UPDATE_ACTIONS constant

## \[2.1.1] - 2022-11-07

### Fixed & Deprecated

  - The classic API no longer includes SHA256 hashes of various passwords - the data value is there, but only contains a string of asterisks. As such, ruby-jss can no longer use those to validate some passwords before trying to use them. The methods doing so are still present, but only return `true`. If an incorrect password is given, the underlying process that uses it will fail on its own.
  These methods will be removed in a future version of ruby-jss:
    - `Jamf::DistributionPoint#check_pw`  Used mostly by the `Jamf::DistributionPoint#mount` method
    - `Jamf::Policy.verify_management_password`


## \[2.1.0] - 2022-10-10

### Added

  - Support for the `/v1/jamf-management-framework/redeploy/{id}` Jamf Pro API endpoint in `Jamf::Computer` and
  `Jamf::ComputerGroup`. The method `redeploy_mgmt_framework` is both a Class and an Instance method for those classes
    - The instance method sends the redeployment to the single computer or all the members of the single computer group.
    - The class method accepts a single id, or an array of ids.
      - When using `Jamf::Computer.redeploy_mgmt_framework` provide computer ids
      - When using `Jamf::ComputerGroup.redeploy_mgmt_framework` provide group ids, and all members of all groups will get
        the redeployment
    - In all cases the result is a Hash of target computer ids (keys) and result value for each (Strings).
      -  The result is either the UUID of the sent MDM command, or an error message if the MDM command couldn't be sent.
    - All the code is in the `Jamf::MacOSRedeployMgmtFramework` module, q.v. in the [rubydoc documentation](https://www.rubydoc.info/gems/ruby-jss/Jamf/MacOSRedeployMgmtFramework)

### Fixed

  - A few internal rescues of a deprecated exception class
  - Removed auto-loading of deprecation files; now explicitly loaded.
  - A few Ruby 2 => Ruby 3 bugs - method params needing double-splats (Thanks to @Timelost for reporting this one)
  - Ensure resource paths don't start with a slash
  - Setting the timeouts on an existing API connection object now works.

## \[2.0.0] - 2022-09-12

Version 2.0.0 is a major refactoring of ruby-jss. While attempting to provide as much backward compatibility as possible, there are some significant changes and v2.0.0 is not fully backward compatible. **PLEASE TEST YOUR CODE EXTENSIVELY**

Here are the high-level changes and there are many many others. For more details, see [CHANGES-2.0.0.md](CHANGES-2.0.0.md)

### Added

  - Support for Ruby 3.x
    - tested in 3.0 and 3.1
  - Combined access to both the Classic and Jamf Pro APIs
    - A single namespace module
  - Connection objects talk to both APIs & automatically handle details like bearer tokens
  - Auto-generated code for Jamf Pro API objects
  - Autoloading of code using [Zeitwerk](https://github.com/fxn/zeitwerk)

### Changed

These things are notably different in v2.0.0
  - Paged queries to the Jamf Pro API
  - API data are no longer cached for the JP API, possibly eventually for the classic
  - No Attribute aliases for Jamf Pro API objects
  - Class/Mixin hierarchy for Jamf Pro API objects
  - Support for 'Sticky Sessions' in Jamf Cloud
  - The valid_id method for Classic API collection classes

### Deprecated

These things will go away in some future version of ruby-jss, please update your code sooner than later.

  - Use of the term 'api'
  - .map_all_ids_to method for Classic API collection classes
  - Using .make, #create, and #update for Classic API objects
  - JSS::CONFIG
  - Jamf::Connection instance methods #next_refresh, #secs_to_refresh, &  #time_to_refresh
  - Cross-object validation in setters
  - fetch :random


## \[1.6.7] - 2022-02-22

### Added

  - Support for the FORCE_IPA_UPLOAD parameter when uploading mobiledeviceapplicationsipa data. This makes the server upload the .ipa to cloud distribution points, as it does when uploaded via the WebUI.

## \[1.6.6] - 2022-02-06

### Added

  - Support for EnableRemoteDesktop and DisableRemoteDesktop MDM commands

## \[1.6.5] - 2021-10-14

### Fixed

  - Uplodable#upload now works with Faraday

### Added

  - Attribute 'os_type' added to JSS::MobileDeviceApplication

## \[1.6.4] - 2021-10-04

### Fixed

  - Removed erroneous call to generate self-service XML from JSS::RestrictedSoftware#rest_xml, restricted software items in Jamf Pro are not 'self servable'. Thanks to @marekluban for catching and reporting this one!

### Added

  - Attribute reader JSS::Computer#security, returning the hash of data from the 'security' subset of API computer data.

## \[1.6.3] - 2021-09-13

### Fixed

  - Fixed a bug where some Jamf Pro API CollectionResource subclasses could not be fetched twice without a '.all' scache refresh

### Changed

  - DBConnection.valid_server? connection timeout raised to 60 seconds

  - Update JSS.expand_min_os to handle the fact that OS versions from Apple now have three meaningful parts (major.minor.patch) and that the patch version might be an 'x', as well as the minor version.


## \[1.6.1] - 2021-07-27

### Fixed

  - Resolved some more typo-errors regarding display names in the SelfServable mixin module.

### Changed

  - MySQL connections via the DBConnection class now report some authentication errors more clearly.


## \[1.6.0] - 2021-05-24

### Fixed

  - Creating a JSS::User no longer requires a valid LDAP server. Many thanks to @aaron-mmt for filing and fixing this issue!

  - HTTP 409 errors are handled more appropriately, and should report the actual error message from the server, e.g. 'Duplicate Primary MAC Address'

### Changed

  - In preparation for the removal of the 'runScript' command in the jamf binary, JSS::Script no longer uses it within the 'run' instance method. Instead, it just does what the jamf binary did: It creates a private temp folder, writes the script to disk in that temp folder, executes the script with any given params, then deletes the folder, returning the exit status and output from the script.

  - Jamf::Script#run now takes parameters in the named params `p4:` through `p11:` for consistency with other parts of ruby-jss.

  - Since Jamf Scripts can no longer be stored in a distribution point, which according to Jamf has been the case for a while, all code for dealing with them that way has been removed.

  - JSS::NetworkSegment#include? now uses Range#cover? under the hood, rather than Range#include?, which can take a very very long time with large segments.

  - JSS.expand_min_os has been updated to handle Apple's new version numbers for macOS. This method takes a string like '>=10.14.3' and expands it into a large array of greater OS versions and is used by the 'os_limitations' method of Packages and Scripts.  For any range of versions that includes Big Sur, both '11.x.x' and '10.16' as included in the output, to catch machines that may have SYSTEM_VERSION_COMPAT set in their env.

### Security

  - ruby-jss no longer uses the 'plist' gem due to a remote code execution security issue when using `Plist.parse_xml`. Plists are now handled by the CFPropertyList gem.  The existing wrapper method `JSS.parse_plist` bas been updated to use the new gem, and a new wrapper method has been added to convert ruby data to XML plist: `JSS.xml_plist_from(data)`. All internal references to methods from the insecure 'plist' gem have been replaced with calls to those wrapper methods.

  Many many thanks to actae0n of Blacksun Hackers Club for reporting this security issue and providing examples of how it could be exploited.

## \[1.5.3] - 2020-12-28

### Fixed

  - Classic API connections were not setting their default timeouts properly when first connected. This was causing an error in Policy#flush_logs

## \[1.5.2] - 2020-12-21

### Added

  - JSS::Policy#flush_logs can now be called as a class method JSS::Policy.flush_logs, passing in the policy names or ids, without instantiating the policy

  - Both the class and instance 'flush_logs' methods for JSS::Policy take a named parameter 'computers:' which is an array of the computer identifiers for which the policy should be flushed.

  - JSS::Computer instances now have a 'flush_policy_logs' method which is a wrapper for calling JSS::Policy.flush_logs for just that computer

  - JSS::ConfigurationProfile: #update/#save now takes boolean param redeploy_to_all: which defaults to false. The default means redeploy only to newly assigned machines in scope. Setting this to true will push the profile out to all machines in scope, even if they already have the profile.

### Changed

  - JSS.expand_min_os, used to expand strings like '>=10.14.5' into comma-separated versions to be used in Package and Script os_limitations, has been updated to handle Big Sur being both 10.16 and 11.0, and for future OSes to be 12.x, 13.x etc.
  NOTE: If you've used this feature in the past, you might want to look at your package and script seetings and update them, since they will refer to OSes 10.17 and higher.

  - JSS::APIConnection: initialize @object_list_cache as an empty hash. This provides more useful error messages when forgetting to pass non-default connection objects, and the default one is unused.

### Fixed

  - JSS::Scopable::Scope#remove_target and #remove_limitation didn't always remove the item.

  - JSS::Scopable::Scope: when calling the API for any reason, we now pass in the .api connection of the container. Not doing so when using a non-default connection object would cause problems.


## \[1.5.1] - 2020-11-16

IMPORTANT: New minimum require ruby version is 2.3.0

Big thanks to @cybertunnel for many enhancements and fixes.

### Added

  - The .all method for subclasses of Jamf::CollectionResource now fully supports server-side paging, sorting and filtering (for endpoints that support RSQL filters). See the docs/comments for Jamf::CollectionResource.all for details

  - JSS::ConfigurationProfile subclasses now have a #payload_content=(new_content) method, which takes an Array of Hashes to replace the PayloadContent of the Payload of the profile. All converstion to an XML plist (which is then embedded into the API XML) is handled automatically. WARNING: This is experimental and can easily break your profile if you aren't careful.

- JSS::Server#update_activation_code method was added

- Group#set_static and #set_smart can convert smart groups to static and static to smart

### Changed

  - Minimum required ruby version is 2.3.0

  - The JSS Module now uses the faraday gem, rather than rest-client, as the underlying REST/HTTP engine for communicating with the Classic API. This brings it in line with the Jamf module which has always used faraday for connecting to the Jamf Pro API. Faraday has fewer dependencies, none of which need to be compiled. This means that installing ruby-jss on a Mac no longer requires the XCode command-line tools.

  - The Jamf module, for accessing the Jamf Pro API, now requires Jamf Pro 10.25 or higher. While still in 'beta', the Jamf Pro API is becoming more stable and in compliance with standards. The Jamf module continues to be updated to work with the modernized endpoints of the JP API. Some related changes:
    - The ids of JP API collection objects are Strings containing Integers.
    - Boolean property names no longer start with 'is', tho aliases ending with '?' are still automatically created.

  - Removed dependency on net-ldap, which hasn't been used in a while

  - Removed the redundant JSS::APIConnection instance methods that were just wrappers for various APIObject subclass Class methods, e.g. `Jamf.cnx.valid_id :computers, 'compName'`. Please use the class method directly, e.g. `JSS::Computer.valid_id 'compName'`

### Fixed

  - PatchSource.fetch was totally broken, now fixed

  - Category object's parse_category not properly referencing API object during execution

  - Many small bugs and typos.

## \[1.4.1] - 2020-10-01

### Added

  - Support for JP API connections to https://tryitout.jamfcloud.com/, the open API test server provided by Jamf. It uses internal tokens, so the /auth endpoint is disabled. Now as with the Classic API, `Jamf::Connection.connect`  will accpt any name & password when connecting to that host.

## \[1.4.0] - 2020-09-14

### Added

  - Class JSS::VPPAccount, implementing the 'vppacconts' endpoint.

  - Constant JSS::APP_STORE_COUNTRY_CODES, a Hash with keys being the official country names used by the App Store, and values being the two-letter codes for those names. This static Hash is derived from a Jamf Pro API end point, and will be updated as needed. These codes are used by JSS::VPPAccount

  - Module Method JSS.country_code_match(str) whic allows you to filter the JSS::APP_STORE_COUNTRY_CODES Hash to only those key-value pairs that include the given string.

  - Mixin Class Method VPPable.all_vpp_device_assignable, returns a Hash of Hashes showing the total, used, and remaining licenses for all members of the target class that are VPP-assignable by device.

  - Scopable::Scope#in_scope?(machine) Given a JSS::Computer or MobileDevice, or an identifier for one, it is in the scope? WARNING: For scopes that include Jamf Users or User Groups as targets or exclusions, this method may return an incorrect value. See the discussion in the comments/documentation for the Scopable::Scope class under `IMPORTANT - Users & User Groups in Targets and Exclusions`

  - Scopable::Scope#scoped_machines returns a Hash of ids=>names for all machines in this scope. WARNING:  This must instantiate all machines in the target class. It will still be slow, at least the first time for each target class. On the upside, the instantiated machines will be cached, so generating this list for other scopes with the same target class will be much much faster. In tests, with 1600 Computers in the JSS, it took about 7 minutes the first time, but less than 1 second after caching.
  See also the warning for #in_scope? above, which applies here as well.

  - JSS::Policy objects support 'Policy Retry' via the getter/setter methods #retry_event, #retry_attempts, and #notify_failed_retries. You can only set these values if the #frequency is :once_per_computer. To turn off policy-retry, either set the retry_event to :none, or set the retry_attempts to 0

### Changed

  - Prettier XML for JSS::APIObject#ppx

  - Improved JSS::Validate.boolean. Accepts: true, false, 'true', 'false', 'yes', 'no', 't','f', 'y', or 'n' as Strings or Symbols, case insensitive

  - The JSS::MacApplication class is more fully implemented

  - JSS::Scopable::Scope now uses the word 'targets' consistently to match the UI's 'Targets' tab.  The previous word 'inclusions' still works as before.

  - When using the Jamf module to access the Jamf Pro API, the minumum JamfPro version is now 10.23.0. WARNING: Like the Jamf Pro API itself, the Jamf module that accesses it is in beta and may have breaking changes at any time.

### Fixed

  - JSS::ExtensionAttribute: when used as a display field in an AdvancedSearch, the name of the EA in the search result Hash comes from the API as a String (turned into a Symbol) that is the EA name with colons removed and spaces & dashes turned to underscores. Previously ruby-jss didn't remove the colons

  - Used an XML workaround for the common classic API bug where an XML array comes as a single-item JSON hash. This time in the JSS::User class's user_groups method.

  - The Jamf Pro API endpoints for /v1/device-enrollment changed to /v1/device-enrollments and /v1/device-enrollment/sync/<id> changed to /v1/device-enrollments/<id>/syncs.  /v1/devive-enrollments/syncs.

  - The Jamf Pro API endpoint for bulk-deleting Departments changed from 'delete-departments' to 'delete-multiple'

## \[1.3.3] - 2020-08-07

### Fixed
  - Regression where JSS::Package#required_processor= wouldn't take 'x86'

## \[1.3.2] - 2020-07-31
Many thanks to @cybertunnel for adding a huge amount of code to get JSS::Policy fully implimented, as well as other fixes and updates!

### Added
  - new class JSS::DockItem
  - new classes JSS::DirectoryBinding and JSS::DirectoryBindingType
  - new class JSS::Printer
  - new class JSS::DiskEncryptionConfiguration
  - JSS::Policy:
    - getters and setters for `#user_message_start` and `#user_message_end`
    - `#set_management_account` and `#verify_management_password`
    - `#add_dock_item` and `#remove_dock_item`
    - `#directory_bindings`, `#add_directory_binding` and `#remove_directory_binding`
    - `#add_printer` and `#remove_printer`
    - `#reissue_key`, `#apply_encryption_configuration`, and `#remove_encryption_configuration`


### Changed
  - JSS::Package:
    - no longer issues a warning when changing the file_name of a package
    - Updated the CPU type string from 'x86' to 'Intel/x86'
    - Methods which used to always use the master distribution point now accept a parameter `dist_point: dp` where dp is the name or id of a fileshare distribution point. If not specified, it still defaults to the Master Distribution Point.  This is needed because if the Cloud Distribution Point is the master, there is no access to it via the Classic API, and any use of DistributionPoint.master_distribution_point will raise an error.

## \[1.3.1] - 2020-06-21

### Changed

  - JSS::MobileDeviceApplication when using PrettyPrint (pp) in irb, no longer shows the base64 data for the ipa file.

  - JSS::DistributionPoint.my_distribution_point and .master_distribution_point now have options for dealing with the Cloud Distribution Point (which is not available in the classic API) being the master.

### Fixed

  - JSS::NetworkSegment.distribution_point=  now takes nil or an empty string to unset the dist point.

## \[1.3.0] - 2020-06-05

### Added

  - JSS::NetworkSegment.network_ranges_as_integers method, Similar to NetworkSegment.network_ranges, but the ranges are of Integers, not IPAddr instances. This makes for *MUCH* faster range calculations, needed to implement improvements to NetworkSegment.network_segment_for_ip

  - JSS::Package.all_filenames_by, returns a Hash of all distribution point filenames for all packages, keyed by either the package id, or the package name. NOTE: as with JSS::Package.all_filenames, this method must instantiate all JSS::Package objects, so it will be slow.

### Changed

  - JSS.expand_min_os now expands to macOS 10.30.x, which should hold us for a while

  - JSS::NetworkSegment.network_segment_for_ip and .my_network_segment are no longer deprecated, but now return an integer NetSeg id (or nil). The plural forms of those methods still return an Array of ids for all the matching network segments.

  - The logic for JSS::NetworkSegment.network_segment_for_ip (and .my_network_segment) now matches how the Jamf server does it:  when you IP address is in more than one Network Segment, Jamf uses the smallest/narrowest one (the one containing fewest IP addresses). If more than one of your Network Segments are that same width, the one with the lowest starting IP address is used.

  - In some networking situations (e.g. Split-tunnel VPN with multiple active network ports) the JSS::APIObject.delete method will raise a 404 NotFound error, seemingly because the object was already deleted but a second http DELETE is sent (I think). We now just rescue and ignore that error, since the fact that it's not found means it was indeed deleted.

### Fixed

  - A copy/paste bug in Jamf::Prestage.serials_for_prestage

## \[1.2.15] - 2020-04-30

### Fixed

  - USER_CONF_FILE is always a pathname, never nil

  - issues with Array#j_ci_* methods related to removing safe navigation

## \[1.2.13] - 2020-04-29

### Fixed

  - Ruby 2.6 needs parens in more places than 2.3, apparently

## \[1.2.12] - 2020-04-29

### Added

  - Backport of `#dig` for Arrays, Hashes and OpenStructs, for compatibiliy with older rubiesd (for a while longer anyway). Gratefully borrowed from https://github.com/Invoca/ruby_dig

### Changed

  - Removed all safe navigation operators (`&.`) for compatibility with older rubies (for a while longer anyway)


## \[1.2.11] - 2020-04-26

### Fixed

  - Bug in Package#install that prevented installs from 'alt_download_url'.

## \[1.2.10] - 2020-04-25

### Added

  - Computer#reported_ip_address. This value is collected in newer versions of Jamf Pro. While the #ip_address is the client's IP address from the Jamf Server's perspective, the #reported_ip_address is the IP from the client's perspective, which may be different on a NATted network like a home network.

### Fixed

  - MobileDevice#upload now works like Computer#upload

### Changed

  - Validation of Ext. Attribute values is improved, namely for EAs with integer values, integer-strings like "12" are accepted and converted to real integers as needed.

## \[1.2.9] - 2020-04-13

### Fixed

  - Fixed a bug where passing a frozen string into some setters, e.g. `JSS::Computer.asset_tag=`, would cause an error when it tried to `#strip!` the string.

## \[1.2.8] - 2020-04-12

### Added

  - MobileDevice#update now takes the `no_mdm_rename:` boolean parameter. Prevents an MDM rename command being sent when changing the name of a supervised device with enforced names. Useful when the MDM command fails, as when there's already a pending rename command.

  - `String#jss_float?` and `String#j_float?` predicate methods.

### Changed

  - Jamf Pro API endpoints that have paging options have an undocumented max page size of 2000. The `CollectionResource#all*` methods now account for this.

  - `String#jss_integer?` and `String#j_integer?` now recognize negative integers

  - Ext. Attributes defined to have interger values will now accept integer strings, e.g. `'12345'`  as well as integers e.g. `12345`

  - Ext. Attributes defined to have date values will once again accept blanks (i.e. empty strings)

## \[1.2.7] - 2020-04-01

### Changed

  - Jamf Pro API endpoints that have paging options have an undocumented max page size of 2000. The `CollectionResource#all*` methods now account for this.


## \[1.2.6] - 2020-04-01

### Fixed

- Classic API (JSS module)
  - Sitable objects now recognize the string "None" as meaning no site is assigned. Thanks @cybertunnel for this fix!

  - Scopable::Scope now deals with some bugs in the API regarding Jamf & LDAP users & user groups in targets, limitations, & exclusions. Please see the documentation/comments for the class in the file or the online documentation. Thanks @cybertunnel again!

  - Criteriable::Criteria can now be empty - containing no criterion objects. When criteriable objects are created (such as Advanced Searches) the default JSS::Criteriable::Criteria object has no criteria.  To remove all criteria, use `criteria.clear`, `criteria = nil`, or `criteria = JSS::Criteriable::Criteria.new` and then save. Once again, thanks to @cybertunnel for finding this.

- Jamf Pro API (Jamf module)
  - More fixes for various JamfPro API (Jamf module) methods that accept a passed-in Jamf::Connection instance.


## \[1.2.5] - 2020-03-30

### Fixed

- Classic API (JSS module)
  - The Classic API now requires JSS::User objects to be passed back to the API with the `ldap_server` specified by id, name-only won't work.

- Jamf Pro API (Jamf module)
  - Fixes for various JamfPro API (Jamf module) methods that accept a passed-in Jamf::Connection instance.

## \[1.2.4] - 2020-03-16

### Added

- **'Beta' Jamf Pro API support in ruby-jss!**

The Jamf Pro API, formerly known as the 'Universal' API, aims to be a far more robust, modern, and standardized way to programmatically access a Jamf Pro server.  While its been in development for a while, it is finally starting to settle in to some standards, to the point that its worth releasing some early ruby-jss code to access it.

Because the JP-API is so fundamentally different from the Classic API, it's being implemented as a totally separate ruby module 'Jamf', and many of the underlying standards of ruby-jss's JSS module are being re-thought and modernized, much like the JP-API itself. Classic API access using the JSS module is unchanged, and will continue to get fixes and other updates as needed. However many things in the Jamf module will behave differently from the JSS module, at least in detail if not concept.

For requirements and details of using the Jamf module to access the Jamf Pro API, see [lib/jamf/README-JP-API.md](lib/jamf/README-JP-API.md).

**IMPORTANT:** As with the JP-API, The Jamf module is an early work-in-progress, and things might change drastically at any point. Please mention 'ruby-jss' in MacAdmins Slack channels #jamf-api or #ruby, or email ruby-jss@pixar.com, or open an issue on github if you have questions or want to contribute.

### Changed

- The `last_mdm_contact` class and instance method from the MDM mixin module (as used in Computer and MobileDevice classes) now returns the time of the most recent _completed_ or _failed_ mdm command. This is more accurate than just the completed commands, since a failed command still implies contact between the client and Jamf Pro.

- JSS::MobileDevice instances now have three predicate methods: `tv?` (aliased as `apple_tv?`), `ipad?` and `iphone?`

## \[1.2.3] - 2019-10-31
### Added
- the ManagementHistory mixin module used by the Computer and MobileDevice classes, now has a `last_mdm_contact` class and instance method, which returns a Time object for the timestamp of the most recent completed MDM command. This is useful for MobileDevices, which don't have anything like the `last_checkin` value for comptuers, indicating real communication between the device and Jamf Pro.
Note that the `last_inventory_update` value does NOT indicate such communication, since that timestamp is updated when values are changed via the API

- All APIObject Subclasses (Policy, Computer, MobileDevice, ComputerGroup, etc..) now have `get_raw`, `post_raw` & `put_raw` class methods, which are simpler wrappers for APIConnection#get_rsrc, #post_rsrc, and #put_rsrc.
  - `get_raw`  takes an object's id, and returns the 'raw' JSON (parsed into a ruby Hash with symbolized keys) or a REXML::Document (from which you'll probably want to use the `root` element). If you pass `as_string: true` you'll get the un-parsed JSON or XML string directly from the API
  This can be useful when you need to retrieve the full object, to get some data not available in the summary-list, but instantiating the full ruby class is too slow

  - `post_raw` & `put_raw` can send raw XML to the API without instantiating objects. In some cases, where you're making simple changes to simple XML, this can be faster than fetching a full instance and the re-saving it.
  WARNING You must create or acquire the XML to be sent, and no validation will be performed on it. It must be a String of XML, or something that returns such a string with #to_s, such as a REXML::Document, or a REXML::Element.

- APIConnection#get_rsrc now takes the boolean raw_json: parameter (defaults to false). If true, the raw JSON string is
  returned, not parsed into a Hash. When requesting XML, it already comes as a string.

- ExtensionAttribute#attribute_mapping getter & setter for EAs that have the 'LDAP Attribute Mapping' input type.

### Fixed
- DB_CNX.valid_server? now specifies utf8 charset, and catches NotSupportedAuthMode errors, needed for newer versions of mysql

### Changed
- Cleaned up and modernized ExtensionAttribute and its subclasses. Marked a few things as deprecated: recon_display, scripting_language, and platform, all in ComputerExtensionAttribute.
- Better error message when using `APIObject.fetch :random` on a subclass with no objects

## \[1.2.0] - 2019-10-17
### Added
- APIConnection#flushcache can be used to flush all cached data, or just for specific APIObject lists or ExtensionAttribute definitions. This is now used more often throughout ruby-jss.

### Fixed
- Group.all_static was returning all_smart,  now actually returns all_static

- Fix in error message raised in Group.change_membership

- APIConnection#connect now flushes all cached data, so if you use it to change which server is being used by an existing connection, you don't keep the cached data from the old server.

- PatchPolicy now overrides APIObject.fetch to still allow for fetching by name, even there's no patchpolicies/name/... endpoint

### Changed
- Group#create with `calculate_members: true`, will sometimes try to re-read the new group before the JSS knows it exists, causing a `404 Not Found` error.  This is especially common when using a clustered environment behind a load-balanced hostname (like _something.jamfcloud.com_).
Now, if a 404 happens when trying to refresh the membership using calculate_members, ruby-jss will retry every second for up to 10 seconds.
To change the number of retries, provide an integer with the `retries:` parameter. If you don't need to know the group members after creation, pass `calculate_members: false` when calling Group#create or Group#save

- Creating, Updating, or Deleting objects of the APIObject subclasses now flushes the cached `all` lists for that class, so subseqent uses of the `all` lists will refresh the data from the API. This means that `APIObject.valid_id` will work immediately upon object creation. NOTE: However, when using a clustered environment behind a load-balanced hostname (like jamfcloud.com), it may take some time for the `all` list to update on all nodes of the cluster, so you might still need to pause up to the number of seconds defined of the cluster's sync interval to ensure valid lists.

- Case-insentive lookup & validation methods in APIObject now use `String#casecmp?` for much simpler code

- Creatable#create no longer takes an `api:` parameter (it never should have) The API connection given in #make is always used for creating the object in the API.

- Added class JSS::IBeacon, implementing the .../ibeacons/... endpoints

## \[1.1.3] - 2019-09-23
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

- master_distribution_point class method in APIConnection & DistribtutionPoint now raise an error when no dist. point is 'master'
  - The error states that the cloud dist. point may be the master, and there's no classic API access to it.


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

- LdapServer.server_for_user and .server_for_group class methods, return the id of the first LDAP server containing the given user or group

- Client.homedir(user) and Client.do_not_disturb?(user)

- Package.all_filenames, .orphaned_files, and .missing_files class methods. WARNING - these are very slow since they must instantiate every package.

- The JSS::APIConnection.connect method, used for making all classic API connections, now takes a `server_path:` parameter.
  If your JSS is not at the root of the server, e.g. if it's at
    `https://myjss.myserver.edu:8443/dev_mgmt/jssweb/`
  rather than
    `https://myjss.myserver.edu:8443/`
  then use this parameter to specify the path below the root e.g:
    `Jamf.cnx.connect server: 'myjss.myserver.edu', server_path: 'dev_mgmt/jssweb', port: 8443 [...]`
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

  `Jamf.cnx.connect server: 'myjss.myschool.edu', user: 'username', pw: :prompt, ssl_version: :TLSv1`

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
