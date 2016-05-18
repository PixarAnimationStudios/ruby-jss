### Copyright 2016 Pixar
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
### JSS, A Ruby module for interacting with the JAMF Software Server via it's REST API.
###
module JSS

  ### The minimum Ruby version that works with this gem
  MINIMUM_RUBY_VERSION = "2.0.0"

  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new(MINIMUM_RUBY_VERSION)
    raise "Can't use the JSS module, ruby itself must be version #{MINIMUM_RUBY_VERSION} or greater."
  end

  #####################################
  ### Required Libraries, etc
  #####################################

  ###################
  ### Standard Libraries
  require 'date'
  require 'singleton'
  require 'pathname'
  require 'fileutils'
  require 'uri'
  require "ipaddr"
  require "rexml/document"
  require "base64"
  require "shellwords"
  require "digest"
  require 'yaml'

  ###################
  ### Gems
  require 'rest-client'
  require 'json'
  require 'plist'



  #####################################
  ### Constants
  #####################################

  ### The minimum JSS version that works with this gem, as returned by the API
  ### in the deprecated 'jssuser' resource
  MINIMUM_SERVER_VERSION = "9.4"



  ### The current local UTC offset as a fraction of a day  (Time.now.utc_offset is the offset in seconds,
  ### 60*60*24 is the seconds in a day)
  TIME_ZONE_OFFSET =  Rational(Time.now.utc_offset, 60*60*24)

  ### These are handy for testing values without making new arrays, strings, etc every time.
  TRUE_FALSE = [true, false]

  ### When parsing a date/time data into a Time object, these will return nil
  NIL_DATES = [0, nil, '', '0']


  #####################################
  ### Module Variables
  #####################################

  ### The contents of anything piped to stdin, split into lines. See {JSS.stdin}
  @@stdin_lines = nil

  #####################################
  ### Module Methods
  #####################################


  ###
  ### Define classes and submodules here so that they don't
  ### generate errors when referenced during the loading of
  ### the library.
  ###

  #####################################
  ### Sub Modules
  #####################################

  module Composer ; end

  ### Mix-in Sub Modules

  module Creatable ; end
  module FileUpload ; end
  module Locatable ; end
  module Matchable ; end
  module Purchasable ; end
  module Updatable ; end
  module Extendable ; end

  ### Mix-in Sub Modules with Classes

  module Criteriable ; end
  class Criteriable::Criteria ; end
  class Criteriable::Criterion ; end

  module Scopable ; end
  class Scopable::Scope ; end

  #####################################
  ### Classes
  #####################################

  class APIObject ; end
  class APIConnection ; end
  class Client ; end
  class DBConnection ; end
  class Server ; end
  class Preferences ; end

  #####################################
  ### SubClasses
  #####################################

  ### APIObject Classes with SubClasses

  class AdvancedSearch < JSS::APIObject ; end
  class AdvancedComputerSearch < JSS::AdvancedSearch ; end
  class AdvancedMobileDeviceSearch < JSS::AdvancedSearch ; end
  class AdvancedUserSearch <  JSS::AdvancedSearch ; end


  class ExtensionAttribute < JSS::APIObject ; end
  class ComputerExtensionAttribute < JSS::ExtensionAttribute ; end
  class MobileDeviceExtensionAttribute < JSS::ExtensionAttribute ; end
  class UserExtensionAttribute < JSS::ExtensionAttribute ; end

  class Group < JSS::APIObject ; end
  class ComputerGroup < JSS::Group ; end
  class MobileDeviceGroup < JSS::Group ; end
  class UserGroup < JSS::Group ; end

  ### APIObject Classes without SubClasses

  class Building < JSS::APIObject ; end
  class Category < JSS::APIObject ; end
  class Computer < JSS::APIObject ; end
  class Department < JSS::APIObject ; end
  class DistributionPoint < JSS::APIObject ; end
  class LDAPServer < JSS::APIObject ; end
  class MobileDevice < JSS::APIObject ; end
  class NetBootServer < JSS::APIObject ; end
  class NetworkSegment < JSS::APIObject ; end
  class OSXConfigurationProfile < JSS::APIObject ; end
  class Package < JSS::APIObject ; end
  class PeripheralType < JSS::APIObject ; end
  class Peripheral < JSS::APIObject ; end
  class Policy < JSS::APIObject ; end
  class RemovableMacAddress < JSS::APIObject ; end
  class Script < JSS::APIObject ; end
  class Site < JSS::APIObject ; end
  class SoftwareUpdateServer < JSS::APIObject ; end
  class User < JSS::APIObject ; end


end # module JSS


##################
### Load the rest of the module

require "jss/utility"
require "jss/composer"
require "jss/compatibility"
require "jss/ruby_extensions"
require "jss/exceptions"
require "jss/api_connection"
require "jss/api_object"
require "jss/server"
require "jss/client"
require "jss/configuration"
require "jss/db_connection"
require "jss/version"
