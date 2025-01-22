# Copyright 2025 Pixar

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

# frozen_string_literal: true

# The main Module
module Jamf

  # Classes
  #####################################

  # A Package in the Jamf Pro API
  #
  #################################
  class JPackage < Jamf::OAPISchemas::Package

    # Mix-Ins
    #####################################

    include Jamf::CollectionResource
    extend Jamf::Filterable
    include Jamf::ChangeLog

    # Constants
    #####################################

    ########### RELATED OAPI OBJECTS
    # These objects should be OAPIObjects, NOT subclasses of them and
    # not Collection or Singleton resources.

    # The OAPI object class we get back from a 'list' query to get the
    # whole collection, or a subset of it. It contains a :results key
    # which is an array of data for objects of the parent class.
    SEARCH_RESULT_OBJECT = Jamf::OAPISchemas::PackagesSearchResults

    # The OAPI object class we send with a POST request to make a new member of
    # the collection in Jamf. This is usually the same as the parent class.
    POST_OBJECT = Jamf::OAPISchemas::Package

    # The OAPI object class we send with a PUT request to change an object in
    # Jamf by specifying all its values. Most updates happen this way,
    # and this is usually the same as the parent class
    PUT_OBJECT = Jamf::OAPISchemas::Package

    # The OAPI object we send with a PATCH request to change an object in
    # Jamf by replacing only some of its values. This is never the same as the
    # parent class, and is usually used when most of the data about an
    # object cannot be changed via the API.
    # PATCH_OBJECT = Jamf::OAPISchemas::Building

    ############# API PATHS
    # TODO: See if these paths can be auto-generated from the
    # OAPI schema and baked into the parent class

    # The path for GETting the list of all objects in the collection, possibly
    # filtered, sorted, and/or paged
    # REQUIRED for all collection resources
    #
    # GET_PATH, POST_PATH, PUT_PATH, PATCH_PATH, and DELETE_PATH are automatically
    # assumed from the LIST_PATH if they follow the standards:
    # - GET_PATH = "#{LIST_PATH}/id"
    #   - fetch an object from the collection
    # - POST_PATH = LIST_PATH
    #   - create a new object in the collection
    # - PUT_PATH = "#{LIST_PATH}/id"
    #   - update an object passing all its values back.
    #     Most objects use this or PATCH but not both
    # - PATCH_PATH = "#{LIST_PATH}/id"
    #   - update an object passing some of its values back
    #     Most objects use this or PUT but not both
    # - DELETE_PATH = "#{LIST_PATH}/id"
    #   - delete an object from the collection
    #
    # If those paths differ from the standards, the constants must be defined
    # here
    #
    LIST_PATH = 'v1/packages'

    # Identifiers not marked in the superclass's OAPI_PROPERTIES constant
    # which usually only identifies ':id'
    ALT_IDENTIFIERS = %i[packageName].freeze

    # Must define this when extending Filterable
    FILTER_KEYS = %i[
      id fileName packageName categoryId info notes manifestFileName cloudTransferStatus
    ].freeze

    # the suffix for the REST resource for uploading a package
    UPLOAD_ENDPOINT = 'upload'

    # Defaults for some required values
    ############

    DEFAULT_CATEGORY_ID = '-1'
    DEFAULT_PRIORITY = 10
    DEFAULT_FUT = false
    DEFAULT_REBOOT_REQUIRED = false
    DEFAULT_OS_INSTALL = false
    DEFAULT_SUPPRESS_UPDATES = false
    DEFAULT_SUPPRESS_FROM_DOCK = false
    DEFAULT_SUPPRESS_EULA = false
    DEFAULT_SUPPRESS_REGISTRATION = false

    # The hash_type value in the API for md5
    CHECKSUM_HASH_TYPE_MD5 = 'MD5'

    # The hash_type value in the API for sha256 - IF it exists
    CHECKSUM_HASH_TYPE_SHA256 = 'SHA_256'

    # The hash_type value in the API for sha512
    CHECKSUM_HASH_TYPE_SHA512 = 'SHA_512'

    # Mapping of the hash types to the maching Digest modules
    # See {#calculate_checksum}
    CHECKSUM_HASH_TYPES = {
      CHECKSUM_HASH_TYPE_MD5 => Digest::MD5,
      CHECKSUM_HASH_TYPE_SHA256 => Digest::SHA256,
      CHECKSUM_HASH_TYPE_SHA512 => Digest::SHA512
    }.freeze

    DEFAULT_CHECKSUM_HASH_TYPE = CHECKSUM_HASH_TYPE_SHA512

    # if no manifest filename is provided, this suffix will be appended to the
    # packageName, with spaces converted to dashes.
    MANIFEST_FILENAME_DEFAULT_SUFFIX = '-manifest.plist'
    MANIFEST_CHUNK_SIZE = 1024 * 1024 * 10 # 10MB
    MANIFEST_PLIST_TEMPLATE = {
      items: [
        {
          assets: [
            {
              'kind' => 'software-package',
              'sha256-size' => MANIFEST_CHUNK_SIZE,
              'sha256s' => [],
              'url' => 'url-goes-here String'
            }
          ]
        }
      ]
    }.freeze

    # Class Methods
    #####################################

    # Given a file path, and hash type, generate the checksum for an arbitrary
    # file.
    #
    # @param filepath [String, Pathname] The file to checksum
    #
    # @param type [String ] One of the keys of CHECKSUM_HASH_TYPES, either
    #    CHECKSUM_HASH_TYPE_MD5 or CHECKSUM_HASH_TYPE_SHA512
    #
    # @return [String] The checksum of the file
    #
    def self.calculate_checksum(filepath, type = DEFAULT_CHECKSUM_HASH_TYPE)
      raise ArgumentError, 'Unknown checksum hash type' unless CHECKSUM_HASH_TYPES.key? type

      CHECKSUM_HASH_TYPES[type].file(filepath).hexdigest
    end

    # Setter for a default URL for package manifests.
    # Setting this means you don't have to provide a URL when generating
    # the manifest for a package, however you can still provide a URL at
    # that time to override this default.
    #
    # The pkgs fileName will be appended to this URL to get the full URL
    #
    # @param url[String] the default URL for building manifests
    #
    # @return [void]
    ############
    def self.default_manifest_url=(url)
      @default_manifest_url = url.to_s
    end

    # @return [URI] the default manifest URL
    ############
    class << self

      attr_reader :default_manifest_url

    end

    # Attributes
    #####################################

    # Checksums
    # Packages in Jamf Pro can have a checksum in either MD5 or SHA512, or possibly
    # SHA256 - none of our 1500 pkgs have 256, but given the existence of the sha256
    # attribute in the API data, I'm assuming it existed at some point, and behaves like
    # md5 (read on)
    #
    # In all cases, the hashType indicates the type of checksum, as a sting, one of
    # 'MD5', 'SHA_256', or 'SHA_512'.
    #
    # In the case of md5 and sha256, the actually digest value (the checksum) is in the
    # 'md5' or 'sha256' attribute. In the case of sha512, the digest is in the 'hashValue'
    # attribute.
    # In anycase, the digest value will be stored in the checksum attribute of this class
    #
    # @return [String] the checksum of the package, either an MD5, SHA256, or SHA512
    #   digest of the package file.
    attr_reader :checksum

    # The response body of the last upload of this package
    attr_reader :upload_response

    # Constructor
    #####################################

    # Make an instance. Data comes from the API
    #
    # @param data[Hash] the data for constructing a new object.
    ##############################
    def initialize(data)
      super

      # set defaults for some required values
      #
      # check for explicit nils, since if these are boolean false
      # we don't want to change them.

      self.categoryId = DEFAULT_CATEGORY_ID if categoryId.nil?
      self.priority = DEFAULT_PRIORITY if priority.nil?
      self.fillUserTemplate = DEFAULT_FUT if fillUserTemplate.nil?
      self.rebootRequired = DEFAULT_REBOOT_REQUIRED if rebootRequired.nil?
      self.osInstall = DEFAULT_OS_INSTALL if osInstall.nil?
      self.suppressUpdates = DEFAULT_SUPPRESS_UPDATES if suppressUpdates.nil?
      self.suppressFromDock = DEFAULT_SUPPRESS_FROM_DOCK if suppressFromDock.nil?
      self.suppressEula = DEFAULT_SUPPRESS_EULA if suppressEula.nil?
      self.suppressRegistration = DEFAULT_SUPPRESS_REGISTRATION if suppressRegistration.nil?

      @checksum =
        case hashType
        when CHECKSUM_HASH_TYPE_MD5
          md5 || hashValue
        when CHECKSUM_HASH_TYPE_SHA256
          sha256 || hashValue
        when CHECKSUM_HASH_TYPE_SHA512
          hashValue
        end
    end # init

    # Public Instance Methods
    #####################################

    # @return [Pathname] the local receipt when this pkg is installed
    def receipt
      # the receipt is the filename with any .zip extension removed.
      fileName ? (Jamf::Client::RECEIPTS_FOLDER + fileName.to_s.sub(/.zip$/, '')) : nil
    end

    # Generate a manifest plist (xml) for this package. The URL will be the default for the class
    # (if you have set one) or the URL passed in, with the filename appended, preceded by
    # a slash.
    #
    # @param url[String] the URL where the package will be downloaded from, defaults to the class default
    #
    # @param chunk_size[Integer] the size of each chunk in the manifest, defaults to MANIFEST_CHUNK_SIZE
    #
    # @param filepath [String, Pathname] the path to a local copy of the package file for which
    #   this manifest is being generated. This MUST match the one uploaded to the server, as it is
    #   used to calculate the checksums in the manifest.
    #
    # @return [String] the XML plist data for the manifest
    ##############################
    def generate_manifest(filepath:, url: nil, chunk_size: MANIFEST_CHUNK_SIZE)
      # make sure the file exists
      file = Pathname.new(filepath)
      raise ArgumentError, 'No locally-readable file provided' unless file.readable?

      url ||= self.class.default_manifest_url
      raise ArgumentError, 'No URL provided for manifest generation' unless url

      # append the filename to the URL and parse it to make sure it's valid
      url = url.to_s.chomp('/') + "/#{fileName}"
      url = URI.parse url

      # make the manifest
      manifest = MANIFEST_PLIST_TEMPLATE.dup
      manifest[:items][0][:assets][0]['url'] = url.to_s
      manifest[:items][0][:assets][0]['sha256-size'] = chunk_size.to_s

      file.open do |f|
        while chunk = f.read(chunk_size) # only load chunk_size bytes at a time
          manifest[:items][0][:assets][0]['sha256s'] << Digest::SHA256.hexdigest(chunk)
        end
      end

      plist = CFPropertyList::List.new
      plist.value = CFPropertyList.guess(manifest)
      self.manifest = plist.to_str CFPropertyList::List::FORMAT_XML, formatted: true
    end

    # Upload a package file to Jamf Pro
    #
    # @param file_path [String, Pathname] the path to the package file to upload
    #
    # @return [void]
    ##############################
    def upload(file_path, update_checksum: true)
      raise Jamf::NoSuchItemError, 'This package has no id, it must be saved in Jamf Pro before uploading' unless id
      raise Jamf::MissingDataError, 'No file path provided for upload' unless file_path

      file = Pathname.new(file_path)
      raise Jamf::MissingDataError, 'No file at the provided path' unless file.readable?

      # upload the file
      @upload_response = cnx.jp_upload("#{get_path}/#{UPLOAD_ENDPOINT}", file)

      return unless update_checksum

      # update the checksum
      @checksum = self.class.calculate_checksum(file)
      self.hashType = CHECKSUM_HASH_TYPE_SHA512
      self.hashValue = @checksum
      self.sha256 = nil
      self.md5 = nil
    end

    # Save this object to the JSS
    #
    # @return [void]
    ##############################
    def save
      self.manifestFileName ||= "#{packageName.gsub(' ', '-')}-manifest.plist" if manifest
      super
    end

  end # class

end # module
