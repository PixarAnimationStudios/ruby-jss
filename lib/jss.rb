### Copyright 2020 Pixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

###
### JSS, A Ruby module for interacting with the JAMF Pro Server via it's REST API.
###
module JSS

  ### The minimum Ruby version that works with this gem
  MINIMUM_RUBY_VERSION = '2.0.0'.freeze

  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new(MINIMUM_RUBY_VERSION)
    raise "Can't use the JSS module, ruby itself must be version #{MINIMUM_RUBY_VERSION} or greater."
  end

  ### Required Libraries, etc
  #####################################

  ###################
  ### Standard Libraries
  require 'date'
  require 'singleton'
  require 'pathname'
  require 'fileutils'
  require 'open-uri'
  require 'ipaddr'
  require 'rexml/document'
  require 'base64'
  require 'shellwords'
  require 'digest'
  require 'yaml'
  require 'open3'
  require 'English'
  require 'json'
  require 'digest'

  ###################
  ### Gems
  require 'rest-client'
  require 'plist'
  require 'immutable-struct'
  require 'recursive-open-struct'

  ### Constants
  #####################################

  ### The minimum JSS version that works with this module, as returned by the API
  ### in the deprecated 'jssuser' resource
  MINIMUM_SERVER_VERSION = '10.4.0'.freeze

  ### The current local UTC offset as a fraction of a day  (Time.now.utc_offset is the offset in seconds,
  ### 60*60*24 is the seconds in a day)
  TIME_ZONE_OFFSET =  Rational(Time.now.utc_offset, 60 * 60 * 24)

  ### These are handy for testing values without making new arrays, strings, etc every time.
  TRUE_FALSE = [true, false].freeze

  ### When parsing a date/time data into a Time object, these will return nil
  NIL_DATES = [0, nil, '', '0'].freeze

  ### Empty strings are used in various places
  BLANK = ''.freeze

  ### Module Variables
  #####################################

  ### The contents of anything piped to stdin, split into lines. See {JSS.stdin}
  @@stdin_lines = nil

  ### Module Methods
  #####################################

  # TODO: Find a better way to do all this - possibly with
  # autoloading.

  ### Define classes and submodules here so that they don't
  ### generate errors when referenced during the loading of
  ### the library.
  ###

  ### Sub Modules
  #####################################

  module Composer; end

  ### Mix-in Sub Modules

  module Creatable; end
  module FileUpload; end
  module Locatable; end
  module Matchable; end
  module Purchasable; end
  module Updatable; end
  module Extendable; end
  module SelfServable; end
  module Categorizable; end
  module VPPable; end
  module Sitable; end
  module MDM; end
  module ManagementHistory; end

  ### Mix-in Sub Modules with Classes

  module Criteriable

    class Criteria; end
    class Criterion; end

  end

  module Scopable

    class Scope; end

  end

  ### Classes
  #####################################

  class APIConnection; end
  class DBConnection; end
  class Server; end
  class Icon; end
  class Preferences; end
  # TODO: see if this can be made into a module:
  class Client; end

  # Parent of all fetchable objects.
  #
  class APIObject

    # Builtin ruby callback, whenver a subclass is created.
    #
    # Just store the subclass name, at the end of all the requires, we'll
    # call define_identifier_list_methods on everything we stored here.
    #
    def self.inherited(subclass)
      @subclasses ||= []
      @subclasses << subclass
    end

  end # class APIObject

  ### APIObject SubClasses
  #####################################

  ### APIObject SubClasses with SubClasses

  class AdvancedSearch < JSS::APIObject; end
  class AdvancedComputerSearch < JSS::AdvancedSearch; end
  class AdvancedMobileDeviceSearch < JSS::AdvancedSearch; end
  class AdvancedUserSearch < JSS::AdvancedSearch; end

  class ExtensionAttribute < JSS::APIObject; end
  class ComputerExtensionAttribute < JSS::ExtensionAttribute; end
  class MobileDeviceExtensionAttribute < JSS::ExtensionAttribute; end
  class UserExtensionAttribute < JSS::ExtensionAttribute; end

  class Group < JSS::APIObject; end
  class ComputerGroup < JSS::Group; end
  class MobileDeviceGroup < JSS::Group; end
  class UserGroup < JSS::Group; end

  class ConfigurationProfile < JSS::APIObject; end
  class OSXConfigurationProfile < JSS::ConfigurationProfile; end
  class MobileDeviceConfigurationProfile < JSS::ConfigurationProfile; end

  ### APIObject SubClasses without SubClasses

  class Account < JSS::APIObject; end
  class Building < JSS::APIObject; end
  class Category < JSS::APIObject; end
  class Computer < JSS::APIObject; end
  class Department < JSS::APIObject; end
  class DistributionPoint < JSS::APIObject; end
  class EBook < JSS::APIObject; end
  class IBeacon < JSS::APIObject; end
  class LDAPServer < JSS::APIObject; end
  class MacApplication < JSS::APIObject; end
  class MobileDevice < JSS::APIObject; end
  class MobileDeviceApplication < JSS::APIObject; end
  class NetBootServer < JSS::APIObject; end
  class NetworkSegment < JSS::APIObject; end
  class Package < JSS::APIObject; end
  class PatchPolicy < JSS::APIObject; end
  class PeripheralType < JSS::APIObject; end
  class Peripheral < JSS::APIObject; end
  class Policy < JSS::APIObject; end
  class RemovableMacAddress < JSS::APIObject; end
  class RestrictedSoftware < JSS::APIObject; end
  class Script < JSS::APIObject; end
  class Site < JSS::APIObject; end
  class SoftwareUpdateServer < JSS::APIObject; end
  class User < JSS::APIObject; end
  class WebHook < JSS::APIObject; end

end # module JSS

### Load the rest of the module

require 'jss/utility'
require 'jss/composer'
require 'jss/compatibility'
require 'jss/ruby_extensions'
require 'jss/exceptions'
require 'jss/api_connection'
require 'jss/api_object'
require 'jss/server'
require 'jss/client'
require 'jss/configuration'
require 'jss/db_connection'
require 'jss/validate'
require 'jss/version'
require 'jss/xml_workaround'
