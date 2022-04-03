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

# This method
def setup_zeitwerk_loader(loader)
  @loader = loader

  # Ignore this file (more ignores below)
  loader.ignore __FILE__

  # these paths all define classes & modules directly below 'Jamf'
  # If we didn't collaps them, then e.g.
  #   /jamf/api/base_classes/classic/group.rb
  # would be expected to define
  #   Jamf::Api::BaseClasses::Classic::Group
  # rather than what we want:
  #  Jamf::Group
  ###################################################

  loader.collapse("#{__dir__}/jamf/api")

  loader.collapse("#{__dir__}/jamf/api/classic")
  loader.collapse("#{__dir__}/jamf/api/classic/api_objects")
  loader.collapse("#{__dir__}/jamf/api/classic/base_classes")

  loader.collapse("#{__dir__}/jamf/api/jamf_pro")
  loader.collapse("#{__dir__}/jamf/api/jamf_pro/attribute_classes")
  loader.collapse("#{__dir__}/jamf/api/jamf_pro/base_classes")
  loader.collapse("#{__dir__}/jamf/api/jamf_pro/resources")
  loader.collapse("#{__dir__}/jamf/api/jamf_pro/collections")
  loader.collapse("#{__dir__}/jamf/api/jamf_pro/singletons")

  loader.collapse("#{__dir__}/jamf/api/mixins")

  # filenames => Constants, which don't adhere to zeitwerk's parsing standards
  # Mostly because the a filename like 'json_object' would be
  # loaded by zeitwerk expecting it to define 'JsonObject', but it really
  # defines 'JSONObject'
  ###############################################

  # Connections
  loader.inflector.inflect 'classic_api' => 'ClassicAPI'
  loader.inflector.inflect 'jamf_pro_api' => 'JamfProAPI'
  loader.inflector.inflect 'jamf_pro_api_error' => 'JamfProAPIError'
  loader.inflector.inflect 'db_connection' => 'DBConnection'

  # API objects, resources, and mixins
  loader.inflector.inflect 'oapi_object' => 'OAPIObject'
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
  #####################################

  loader.ignore "#{__dir__}/jamf/ruby_extensions.rb"
  loader.ignore "#{__dir__}/jamf/ruby_extensions"
  loader.ignore "#{__dir__}/jamf/exceptions.rb"
  loader.ignore "#{__dir__}/jss-api.rb"
  loader.ignore "#{__dir__}/jss.rb"
  loader.ignore "#{__dir__}/ruby-jss.rb"

  # callback for when a specific file/constant loads
  #####################################
  loader.on_load("Jamf::SomeClass") do |klass, abspath|
    puts "I just loaded #{klass} from #{abspath}"
  end

  # callback for when anything loads
  #  - const_path is like "Jamf::SomeClass" or "Jamf::SomeClass::SOME_CONST_ARRY"
  #  - value is the value that constant contains after loading,
  #    e.g. a the class Jamf::SomeClass for 'Jamf::SomeClass' or
  #    and Array for the constant  "Jamf::SomeClass::SOME_CONST_ARRY"
  #  - abspath is the full path to the file where the constant was loaded from.
  #####################################
  loader.on_load do |const_path, value, _abspath|
    puts "Just Loaded #{const_path}, which is a #{value.class}"
    next unless value.respond_to?(:parse_oapi_properties) && defined?(value::OAPI_PROPERTIES)

    puts "..Parsing OAPI_PROPERTIES for #{value}"
    value.parse_oapi_properties
  end

  loader.setup
end # setup_zeitwerk_loader

# for testing the Zeitwrk L... normally we want autoloading on demand,
# eager loading loads everything
def eager_load_for_testing
  @loader.eager_load(force: true)
  puts :loaded
rescue Zeitwerk::NameError => e
  puts e.message
end
