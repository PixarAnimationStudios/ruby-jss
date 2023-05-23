# Copyright 2023 Pixar

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

# Gems
######

require 'zeitwerk'

# Jamf's Zeitwerk Config and processes
module JamfZeitwerkConfig

  # touch this file to make zeitwerk and mixins send text to stderr as things load
  # or get mixed in
  VERBOSE_LOADING_FILE = Pathname.new('/tmp/ruby-jss-verbose-loading')

  # Or, set this ENV var to also make zeitverk and mixins send text to stderr
  VERBOSE_LOADING_ENV = 'RUBY_JSS_VERBOSE_LOADING'

  # touch this file to make zeitwek  eager-load everything when the gem is required.
  EAGER_LOAD_FILE = Pathname.new('/tmp/ruby-jss-zeitwerk-eager-load')

  # Only look at the filesystem once.
  def self.verbose_loading?
    return @verbose_loading unless @verbose_loading.nil?

    @verbose_loading = VERBOSE_LOADING_FILE.file?
    @verbose_loading ||= ENV.include? VERBOSE_LOADING_ENV
    @verbose_loading
  end

  # rubocop: disable Style/StderrPuts
  def self.load_msg(msg)
    $stderr.puts msg if verbose_loading?
  end
  # rubocop: enable Style/StderrPuts

  # The loader object for Xolo
  def self.loader
    @loader
  end

  # Configure the Zeitwerk loader, See https://github.com/fxn/zeitwerk
  def self.setup_zeitwerk_loader(zloader)
    @loader = zloader

    # Ignore this file (more ignores below)
    loader.ignore __FILE__

    ##### Collaped Paths

    # these paths all define classes & modules directly below 'Jamf'
    # If we didn't collapse them, then e.g.
    #   /jamf/api/base_classes/classic/group.rb
    # would be expected to define
    #   Jamf::Api::BaseClasses::Classic::Group
    # rather than what we want:
    #  Jamf::Group
    ###################################################

    loader.collapse("#{__dir__}/api")

    loader.collapse("#{__dir__}/api/classic")
    loader.collapse("#{__dir__}/api/classic/api_objects")
    loader.collapse("#{__dir__}/api/classic/base_classes")

    loader.collapse("#{__dir__}/api/jamf_pro")
    loader.collapse("#{__dir__}/api/jamf_pro/api_objects")
    loader.collapse("#{__dir__}/api/jamf_pro/mixins")
    loader.collapse("#{__dir__}/api/jamf_pro/base_classes")
    loader.collapse("#{__dir__}/api/jamf_pro/other_classes")

    ##### Inflected Paths

    # filenames => Constants, which don't adhere to zeitwerk's parsing standards.
    #
    # Mostly because the a filename like 'oapi_object' would be
    # loaded by zeitwerk expecting it to define 'OapiObject', but it really
    # defines 'OAPIObject'
    ###############################################

    # Connections
    loader.inflector.inflect 'classic_api' => 'ClassicAPI'
    loader.inflector.inflect 'jamf_pro_api' => 'JamfProAPI'
    loader.inflector.inflect 'jamf_pro_api_error' => 'JamfProAPIError'

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
    loader.inflector.inflect 'macos_managed_updates' => 'MacOSManagedUpdates'
    loader.inflector.inflect 'macos_redeploy_mgmt_framework' => 'MacOSRedeployMgmtFramework'
    loader.inflector.inflect 'filevault' => 'FileVault'

    # deprecations, separated so they load only when used.
    # When its time to get rid of them, delete the files from the
    # 'deprecations' directory, and the matching line here.
    loader.inflector.inflect('deprecated_api_constant' => 'API')
    loader.inflector.inflect('deprecated_config_constant' => 'CONFIG')
    loader.inflector.inflect('deprecated_api_connection_class' => 'APIConnection')

    ##### Ingored Paths

    # These should be ignored, some will be required directly
    #####################################

    loader.ignore "#{__dir__}/db_connection.rb"
    loader.ignore "#{__dir__}/ruby_extensions.rb"
    loader.ignore "#{__dir__}/ruby_extensions"
    loader.ignore "#{__dir__}/exceptions.rb"
    loader.ignore "#{__dir__}/deprecations"
    loader.ignore "#{__dir__}/deprecations.rb"

    lib_dir = Pathname.new(__dir__).parent.to_s
    loader.ignore "#{lib_dir}/ruby-jss.rb"
    loader.ignore "#{lib_dir}/jss.rb"
    loader.ignore "#{lib_dir}/jss-api.rb"

    ##### Callbacks

    # callback for when a specific file/constant loads
    # duplicate and uncomment this if desired to react to
    # specific things loading
    #####################################
    # loader.on_load('Jamf::SomeClass') do |klass, abspath|
    #   Jamf.load_msg "I just loaded #{klass} from #{abspath}"
    # end

    # callback for when anything loads
    #  - const_path is like "Jamf::SomeClass" or "Jamf::SomeClass::SOME_CONST_ARRY"
    #  - value is the value that constant contains after loading,
    #    e.g. the class Jamf::SomeClass for 'Jamf::SomeClass' or
    #    an Array for the constant  "Jamf::SomeClass::SOME_CONST_ARRY"
    #  - abspath is the full path to the file where the constant was loaded from.
    #####################################
    loader.on_load do |const_path, value, abspath|
      load_msg "Zeitwerk just loaded #{value.class} '#{const_path}' from:\n  #{abspath}"

      # Parse OAPI_PROPERTIES into getters and setters for subclasses of
      # OAPIObject in the JPAPI.
      #
      # The class we just loaded must have this method and constant
      # and the method must not have run already for the class or any superclass.
      # This prevents running parse_oapi_properties again in subclasses that
      # don't need to do that
      if value.respond_to?(:oapi_properties_parsed?) && \
         defined?(value::OAPI_PROPERTIES) && \
         !value.oapi_properties_parsed?

        parsed = value.parse_oapi_properties
        load_msg "Parsed OAPI_PROPERTIES for #{value}" if parsed
      end

      # Generate the identifier list methods (.all_*) for subclasses of APIObject
      # in the Classic API
      if value.is_a?(Class) && value.superclass == Jamf::APIObject

        done = value.define_identifier_list_methods
        load_msg "Defined identifier list methods for #{value}" if done
      end
    end

    loader.setup
  end # setup_zeitwerk_loader

  # For testing the Zeitwrk Loader.
  # Normally we want autoloading on demand,
  # eager loading loads everything so we can see it
  #
  # To make this happen touch the file defined in EAGER_LOAD_FILE
  def self.eager_load_for_testing
    return unless EAGER_LOAD_FILE.file?

    loader.eager_load(force: true)
    warn :loaded
    # rescue Zeitwerk::NameError => e
    #   warn e.message
  end

end # module JamfZeitwerkConfig
