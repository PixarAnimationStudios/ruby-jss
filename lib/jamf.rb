# Copyright 2019 Pixar

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
#
#

#
# JAMF, A Ruby module for interacting with a JAMF Pro Server via the JAMF API
#

### Standard Libraries
require 'English'
require 'json'
require 'yaml'
require 'pathname'
require 'time'
require 'singleton'
require 'open-uri'
require 'ipaddr'
require 'base64'
require 'shellwords'
require 'digest'
require 'open3'


### Gems
require 'rest-client'
require 'plist'

# Used, among other places, in the Connection::APIError class
require 'immutable-struct'

# TODO: needed?
# require 'recursive-open-struct'

# non-api parts of Jamf module
require 'jamf/configuration'
require 'jamf/exceptions'
require 'jamf/utility'
require 'jamf/validate'
require 'jamf/version'

# backports and extensions to existing Ruby classes
require 'jamf/compatibility'
require 'jamf/ruby_extensions'

# API connection
require 'jamf/api/connection'


# The main module.
# See README.md
#
module Jamf

  # The minimum Ruby version that works with this gem
  # 2.3 allows us to start using some nice features like the safe-navigation
  # operator and Array#dig & Hash#dig, and such.
  #
  # For a list of features, see https://github.com/ruby/ruby/blob/v2_3_0/NEWS
  # and http://nithinbekal.com/posts/ruby-2-3-features/
  #
  MINIMUM_RUBY_VERSION = '2.3'.freeze

  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new(MINIMUM_RUBY_VERSION)
    raise "Can't use the JAMF module, ruby itself must be version #{MINIMUM_RUBY_VERSION} or greater."
  end

  # AUTOLOADING
  ##################################

  # Top-level API Abstract Classes
  autoload :JSONObject, 'jamf/api/abstract_classes/json_object'
  autoload :Resource, 'jamf/api/abstract_classes/resource'
  autoload :SingletonResource, 'jamf/api/abstract_classes/singleton_resource'
  autoload :CollectionResource, 'jamf/api/abstract_classes/collection_resource'

  # Abstract Classes used for JSONObject subclasses
  autoload :Prestage, 'jamf/api/abstract_classes/prestage'
  autoload :PrestageSkipSetupItems, 'jamf/api/abstract_classes/prestage_skip_setup_items'

  # Abstract Classes not used for JSONObject subclasses
  autoload :GenericReference, 'jamf/api/abstract_classes/generic_reference'

  # MixIn Modules
  autoload :ChangeLog, 'jamf/api/mixins/change_log'
  autoload :Extendable, 'jamf/api/mixins/extendable'
  autoload :Locatable, 'jamf/api/mixins/locatable'
  autoload :Referable, 'jamf/api/mixins/referable'
  autoload :Searchable, 'jamf/api/mixins/searchable'
  autoload :Lockable, 'jamf/api/mixins/lockable'
  autoload :UnCreatable, 'jamf/api/mixins/uncreatable'
  autoload :Immutable, 'jamf/api/mixins/immutable'
  autoload :UnDeletable, 'jamf/api/mixins/undeletable'
  autoload :Abstract, 'jamf/api/mixins/abstract'

  # Utility modules
  autoload :Validate, 'jamf/validate'

  # Subclasses of JSONObject, but not Resource
  autoload :AndroidDetails, 'jamf/api/json_objects/android_details'
  autoload :AppleTVDetails, 'jamf/api/json_objects/appletv_details'
  autoload :CellularNetwork, 'jamf/api/json_objects/cellular_network'
  autoload :ChangeLogEntry, 'jamf/api/json_objects/change_log_entry'
  autoload :ComputerPrestageSkipSetupItems, 'jamf/api/json_objects/computer_prestage_skip_setup_items'
  autoload :Country, 'jamf/api/json_objects/country'
  autoload :ExtensionAttributeValue, 'jamf/api/json_objects/extension_attribute_value'
  autoload :InstalledApplication, 'jamf/api/json_objects/installed_application'
  autoload :InstalledCertificate, 'jamf/api/json_objects/installed_certificate'
  autoload :InstalledConfigurationProfile, 'jamf/api/json_objects/installed_configuration_profile'
  autoload :InstalledEBook, 'jamf/api/json_objects/installed_ebook'
  autoload :InstalledProvisioningProfile, 'jamf/api/json_objects/installed_provisioning_profile'
  autoload :InventoryPreloadExtensionAttribute, 'jamf/api/json_objects/inventory_preload_extension_attribute'
  autoload :IosDetails, 'jamf/api/json_objects/ios_details'
  autoload :Location, 'jamf/api/json_objects/location'
  autoload :PrestageLocation, 'jamf/api/json_objects/prestage_location'
  autoload :PrestageSyncStatus, 'jamf/api/json_objects/prestage_sync_status'
  autoload :MobileDeviceDetails, 'jamf/api/json_objects/mobile_device_details'
  autoload :MobileDeviceSecurity, 'jamf/api/json_objects/mobile_device_security'
  autoload :MobileDevicePrestageName, 'jamf/api/json_objects/md_prestage_name'
  autoload :MobileDevicePrestageNames, 'jamf/api/json_objects/md_prestage_names'
  autoload :MobileDevicePrestageSkipSetupItems, 'jamf/api/json_objects/md_prestage_skip_setup_items'
  autoload :PurchasingData, 'jamf/api/json_objects/purchasing_data'
  autoload :PrestagePurchasingData, 'jamf/api/json_objects/prestage_purchasing_data'
  autoload :PrestageScope, 'jamf/api/json_objects/prestage_scope'
  autoload :PrestageAssignment, 'jamf/api/json_objects/prestage_assignment'

  # Subclasses of SingletonResource
  autoload :ClientCheckInSettings, 'jamf/api/resources/singleton_resources/client_checkin_settings'
  autoload :ReEnrollmentSettings, 'jamf/api/resources/singleton_resources/reenrollment_settings'
  autoload :AppStoreCountryCodes, 'jamf/api/resources/singleton_resources/app_store_country_codes'

  # Subclasses of CollectionResource
  autoload :Attachment, 'jamf/api/resources/collection_resources/attachment'
  autoload :Building, 'jamf/api/resources/collection_resources/building'
  autoload :Computer, 'jamf/api/resources/collection_resources/computer'
  autoload :ComputerPrestage, 'jamf/api/resources/collection_resources/computer_prestage'
  autoload :Department, 'jamf/api/resources/collection_resources/department'
  autoload :ExtensionAttribute, 'jamf/api/resources/collection_resources/extension_attribute'
  autoload :InventoryPreloadRecord, 'jamf/api/resources/collection_resources/inventory_preload_record'
  autoload :MobileDevice, 'jamf/api/resources/collection_resources/mobile_device'
  autoload :MobileDevicePrestage, 'jamf/api/resources/collection_resources/md_prestage'
  autoload :Site, 'jamf/api/resources/collection_resources/site'
  autoload :Script, 'jamf/api/resources/collection_resources/script'

  # other classes used as attributes inside the resource classes
  autoload :IPAddress, 'jamf/api/attribute_classes/ip_address'
  autoload :Timestamp, 'jamf/api/attribute_classes/timestamp'

end # module
