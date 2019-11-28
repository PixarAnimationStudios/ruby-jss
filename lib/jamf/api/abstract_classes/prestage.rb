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

# The Module
module Jamf

  # Classes
  #####################################

  # A building defined in the JSS
  class Prestage < Jamf::CollectionResource

    extend Jamf::Abstract

    # for now, subclasses are not creatable
    extend Jamf::UnCreatable

    include Jamf::Lockable

    # Constants
    #####################################

    # Object Model / Attributes
    # See APIObject class documentation for details
    # of how the OBJECT_MODEL hash works.
    #####################################
    OBJECT_MODEL = {

      # @!attribute [r] id
      #   @return [Integer]
      id: {
        class: :integer,
        identifier: :primary,
        readonly: true
      },

      # @!attribute displayName
      #   @return [String]
      displayName: {
        class: :string,
        identifier: true,
        validator: :non_empty_string,
        required: true,
        aliases: %i[name]
      },

      # @!attribute isMandatory
      #   @return [Boolean]
      isMandatory: {
        class: :boolean
      },

      # @!attribute isMdmRemovable
      #   @return [Boolean]
      isMdmRemovable: {
        class: :boolean
      },

      # @!attribute supportPhoneNumber
      #   @return [String]
      supportPhoneNumber: {
        class: :string
      },

      # @!attribute supportEmailAddress
      #   @return [String]
      supportEmailAddress: {
        class: :string
      },

      # @!attribute department
      #   @return [String]
      department: {
        class: :string
      },

      # @!attribute isDefaultPrestage
      #   @return [Boolean]
      isDefaultPrestage: {
        class: :boolean,
        aliases: [:default?]
      },

      # @!attribute enrollmentSiteId
      #   @return [Integer]
      enrollmentSiteId: {
        class: :integer
      },

      # @!attribute isKeepExistingSiteMembership
      #   @return [Boolean]
      isKeepExistingSiteMembership: {
        class: :boolean
      },

      # @!attribute isKeepExistingLocationInformation
      #   @return [Boolean]
      isKeepExistingLocationInformation: {
        class: :boolean
      },

      # @!attribute isRequireAuthentication
      #   @return [Boolean]
      isRequireAuthentication: {
        class: :boolean
      },

      # @!attribute authenticationPrompt
      #   @return [String]
      authenticationPrompt: {
        class: :string
      },

      # @!attribute isEnableDeviceBasedActivationLock
      #   @return [Boolean]
      isEnableDeviceBasedActivationLock: {
        class: :boolean
      },

      # @!attribute deviceEnrollmentProgramInstanceId
      #   @return [Integer]
      deviceEnrollmentProgramInstanceId: {
        class: :integer
      },

      # @!attribute locationInformation
      #   @return [Jamf::ComputerPrestageSkipSetupItems]
      locationInformation: {
        class: Jamf::PrestageLocation,
        aliases: %i[location]
      },

      # @!attribute skipSetupItems
      #   @return [Jamf::ComputerPrestageSkipSetupItems]
      purchasingInformation: {
        class: Jamf::PrestagePurchasingData,
        aliases: %i[purchasing]
      },

      # @!attribute anchorCertificates
      #   @return [Array<String>]
      anchorCertificates: {
        class: :string,
        multi: true
      },

      # @!attribute enrollmentCustomizationId
      #   @return [Integer]
      enrollmentCustomizationId: {
        class: :integer
      },

      # @!attribute profileUUID
      #   @return [String]
      profileUUID: {
        class: :string
      },

      # @!attribute siteId
      #   @return [Integer]
      siteId: {
        class: :integer
      }

    }.freeze

    SCOPE_RSRC = 'scope'.freeze

    SERIALS_KEY = :serialsByPrestageId

    SYNC_RSRC = 'sync'.freeze

    # Class Methods
    #####################################

    # Return the Prestage subclass that is marked as default,
    # i.e. the one that new SNs are assigned to when first added.
    # Nil if no default is defined
    # @return [Jamf::Prestage, nil]
    #
    def self.default
      id = self.all.select{ |ps| ps[:isDefaultPrestage] }.first.dig :id
      return nil unless id

      fetch id: id
    end

    # Return all scoped computer serial numbers and the id of the prestage
    # they are assigned to
    #
    # @param cnx[Jamf::Connection] the API connection to use
    #
    # @return [Hash {String => Integer}] The Serials and prestage IDs
    #
    def self.serials_by_prestage_id(cnx: Jamf.cnx)
      @serials_by_prestage_rsrc ||= "#{self::RSRC_VERSION}/#{self::RSRC_PATH}/#{SCOPE_RSRC}"
      cnx.get(@serials_by_prestage_rsrc)[SERIALS_KEY].transform_keys!(&:to_s)
    end

    # Instance Methods
    #####################################

    def scope(refresh = false)
      @scope = nil if refresh
      return @scope if @scope

      @scope_rsrc ||= "#{self.class::RSRC_VERSION}/#{self.class::RSRC_PATH}/#{@id}/#{SCOPE_RSRC}"

      @scope = Jamf::PrestageScope.new @cnx.get @scope_rsrc
    end

  end # class

end # module
