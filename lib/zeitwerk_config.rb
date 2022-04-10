# Copyright 2022 Pixar

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


# Configure the Zeitwerk loader, See https://github.com/fxn/zeitwerk
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
  loader.collapse("#{__dir__}/jamf/api/jamf_pro/api_objects")
  loader.collapse("#{__dir__}/jamf/api/jamf_pro/mixins")
  loader.collapse("#{__dir__}/jamf/api/jamf_pro/base_classes")
  loader.collapse("#{__dir__}/jamf/api/jamf_pro/other_classes")

  # filenames => Constants, which don't adhere to zeitwerk's parsing standards
  # Mostly because the a filename like 'oapi_object' would be
  # loaded by zeitwerk expecting it to define 'OapiObject', but it really
  # defines 'OAPIObject'
  ###############################################

  # Connections
  loader.inflector.inflect 'classic_api' => 'ClassicAPI'
  loader.inflector.inflect 'jamf_pro_api' => 'JamfProAPI'
  loader.inflector.inflect 'jamf_pro_api_error' => 'JamfProAPIError'
  loader.inflector.inflect 'db_connection' => 'DBConnection'

  # API objects, resources, and mixins
  loader.inflector.inflect 'oapi_schemas' => 'OAPISchemas'
  loader.inflector.inflect 'oapi_object' => 'OAPIObject'
  loader.inflector.inflect 'oapi_validate' => 'OAPIValidate'

  loader.inflector.inflect 'jpapi_resource' => 'JPAPIResource'

  loader.inflector.inflect 'api_object' => 'APIObject'
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
  loader.inflector.inflect 'vpp_account' => 'VPPAccount'
  loader.inflector.inflect 'removable_macaddr' => 'RemovableMacAddress'
  loader.inflector.inflect 'md_prestage_name' => 'MobileDevicePrestageName'
  loader.inflector.inflect 'md_prestage_names' => 'MobileDevicePrestageNames'
  loader.inflector.inflect 'md_prestage_skip_setup_items' => 'MobileDevicePrestageSkipSetupItems'

  # These should be ignored, some will be required directly
  #####################################

  loader.ignore "#{__dir__}/jamf/api/jamf_pro/pre_oapi"

  loader.ignore "#{__dir__}/jamf/ruby_extensions.rb"
  loader.ignore "#{__dir__}/jamf/ruby_extensions"
  loader.ignore "#{__dir__}/jamf/exceptions.rb"
  loader.ignore "#{__dir__}/jss-api.rb"
  loader.ignore "#{__dir__}/jss.rb"
  loader.ignore "#{__dir__}/ruby-jss.rb"

  # callback for when a specific file/constant loads
  #####################################
  loader.on_load("Jamf::SomeClass") do |klass, abspath|
    puts "I just loaded #{klass} from #{abspath}" # if ZEITWERK_TEST_FILE.file?
  end

  # callback for when anything loads
  #  - const_path is like "Jamf::SomeClass" or "Jamf::SomeClass::SOME_CONST_ARRY"
  #  - value is the value that constant contains after loading,
  #    e.g. a the class Jamf::SomeClass for 'Jamf::SomeClass' or
  #    and Array for the constant  "Jamf::SomeClass::SOME_CONST_ARRY"
  #  - abspath is the full path to the file where the constant was loaded from.
  #####################################
  loader.on_load do |const_path, value, abspath|
    puts "Just Loaded #{const_path}, which is a #{value.class}" if ZEITWERK_VERBOSE_FILE.file?

    # The class we just loaded must have this method and constant
    # and the constant must be defined directly in the file we just loaded.
    # This prevents running parse_oapi_properties again in subclasses that
    # don't need to do that
    if value.respond_to?(:parse_oapi_properties) && \
       defined?(value::OAPI_PROPERTIES) && \
       abspath == value.const_source_location(:OAPI_PROPERTIES).first

       parsed = value.parse_oapi_properties
       puts "..Parsed OAPI_PROPERTIES for #{value}" if parsed && ZEITWERK_VERBOSE_FILE.file?
    end
  end

  loader.setup
end # setup_zeitwerk_loader

# for testing the Zeitwrk Loader
# normally we want autoloading on demand,
# eager loading loads everything so we can see it
def eager_load_for_testing
  @loader.eager_load(force: true)
  puts :loaded
rescue Zeitwerk::NameError => e
  puts e.message
end
