# Copyright 2020 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.

# Required Libraries, etc
#####################################

# Standard Libraries
# TODO: Move some of these to where they are first needed so they aren't
# loaded unnecessarily
require 'English'
require 'json'
require 'yaml'
require 'pathname'
require 'fileutils'
require 'time'
require 'date'
require 'singleton'
require 'open-uri'
require 'ipaddr'
require 'rexml/document'
require 'base64'
require 'shellwords'
require 'digest'
require 'open3'

# Gems
require 'immutable-struct'
require 'recursive-open-struct'
require 'zeitwerk'

# Configure the Zeitwerk loader, https://github.com/fxn/zeitwerk
loader = Zeitwerk::Loader.for_gem

# these paths all define classes & modules directly below 'Jamf'
loader.collapse("#{__dir__}/jamf/api")
loader.collapse("#{__dir__}/jamf/api/base_classes")
loader.collapse("#{__dir__}/jamf/api/base_classes/classic")
loader.collapse("#{__dir__}/jamf/api/base_classes/jamf_pro")
loader.collapse("#{__dir__}/jamf/api/classic_api_objects")
loader.collapse("#{__dir__}/jamf/api/jamf_pro_attributes")
loader.collapse("#{__dir__}/jamf/api/jamf_pro_json_objects")
loader.collapse("#{__dir__}/jamf/api/jamf_pro_resources")
loader.collapse("#{__dir__}/jamf/api/jamf_pro_resources/collections")
loader.collapse("#{__dir__}/jamf/api/jamf_pro_resources/singletons")
loader.collapse("#{__dir__}/jamf/api/mixins")

# filenames => Constants, which don't adhere to zeitwerk's parsing standards

# Connections
loader.inflector.inflect 'classic_api' => 'ClassicAPI'
loader.inflector.inflect 'jamf_pro_api' => 'JamfProAPI'
loader.inflector.inflect 'jamf_pro_api_error' => 'JamfProAPIError'
loader.inflector.inflect 'db_connection' => 'DBConnection'

# API objects, resources, and mixins
loader.inflector.inflect 'api_object' => 'APIObject'
loader.inflector.inflect 'ebook' => 'EBook'
loader.inflector.inflect 'mdm_command' => 'MDMCommand'
loader.inflector.inflect 'xml_workaround' => 'XMLWorkaround'
loader.inflector.inflect 'json_object' => 'JSONObject'
loader.inflector.inflect 'vppable' => 'VPPable'
loader.inflector.inflect 'osx_configuration_profile' => 'OSXConfigurationProfile'
loader.inflector.inflect 'jp_extendable' => 'JPExtendable'
loader.inflector.inflect 'mdm' => 'MDM'
loader.inflector.inflect 'ibeacon' => 'IBeacon'
loader.inflector.inflect 'powerbroker_identity_services' => 'PowerBroker'
loader.inflector.inflect 'admitmac' => 'ADmitMac'
loader.inflector.inflect 'ip_address' => 'IPAddress'
loader.inflector.inflect 'netboot_server' => 'NetBootServer'
loader.inflector.inflect 'ldap_server' => 'LDAPServer'
loader.inflector.inflect 'vpp_account' => 'VPPAccount'
loader.inflector.inflect 'removable_macaddr' => 'RemovableMacAddress'
loader.inflector.inflect 'md_prestage_name' => 'MobileDevicePrestageName'
loader.inflector.inflect 'md_prestage_names' => 'MobileDevicePrestageNames'
loader.inflector.inflect 'md_prestage_skip_setup_items' => 'MobileDevicePrestageSkipSetupItems'

# These should be ignored, some will be required directly
loader.ignore "#{__dir__}/jamf/ruby_extensions.rb"
loader.ignore "#{__dir__}/jamf/ruby_extensions"
loader.ignore "#{__dir__}/jamf/exceptions.rb"
loader.ignore "#{__dir__}/jss-api.rb"
loader.ignore "#{__dir__}/jss.rb"
loader.ignore "#{__dir__}/ruby-jss.rb"


# callback for when a specific class loads
#
# loader.on_load("Jamf::SomeClass") do |klass, _abspath|
#   klass.endpoint = "https://api.prod"
# end

# callback for when anything loads
#  - const_path is like "Jamf::SomeClass" or "Jamf::SomeClass::SOME_CONST_ARRY"
#  - value is the value that constant contains after loading,
#    e.g. a the class Jamf::SomeClass for 'Jamf::SomeClass' or
#    and Array for the constant  "Jamf::SomeClass::SOME_CONST_ARRY"
#  - abspath is the full path to the file where the constant was loaded from.
loader.on_load do |const_path, value, abspath|
  puts "Just Loaded #{const_path}, which is a #{value.class}"
  next unless value.respond_to?(:parse_object_model) && defined?(value::OBJECT_MODEL)

  puts "Parsing Object Model for #{value}"
  value.parse_object_model
end

loader.setup

# Jamf, A Ruby module for interacting with the JAMF Pro Server via both of its REST APIs
module Jamf

  include Jamf::Constants
  extend Jamf::Utility

  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new(MINIMUM_RUBY_VERSION)
    raise "Can't use the JSS module, ruby itself must be version #{MINIMUM_RUBY_VERSION} or greater."
  end

end # module Jamf

# Load things not loaded by zeitwerk
require 'jamf/ruby_extensions'
require 'jamf/exceptions'

# backward compatibility, JSS module is the same as Jamf module
JSS = Jamf

# for testing... normally we want autoloading on demand,
# eager loading loads everything
begin
  loader.eager_load(force: true)
rescue Zeitwerk::NameError => e
  puts e.message
else
  puts :loaded
end
