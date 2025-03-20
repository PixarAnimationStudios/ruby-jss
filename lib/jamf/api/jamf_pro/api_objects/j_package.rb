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

require 'cfpropertylist'

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
    ALT_IDENTIFIERS = %i[packageName fileName].freeze

    # If the object does not have a 'name' attribute, this is the attribute
    # that holds its name. Used to allow referencing objects by 'name',
    # creates a alias of the attribute called "name" and "name=",
    # and allows the use of "name:" as an identifier in the .fetch, .valid_id and
    # similar methods.
    OBJECT_NAME_ATTR = :packageName

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

    # The hashType value in the API or manifests for md5
    CHECKSUM_HASH_TYPE_MD5 = 'MD5'

    # The hashType value in the API for sha256 - IF it exists?
    CHECKSUM_HASH_TYPE_SHA256 = 'SHA_256'

    # The hashType value in MDM deploy manifests for sha256
    CHECKSUM_HASH_TYPE_SHA256_MDM_DEPLOY = 'SHA256'

    # The hashType value in the API for sha512
    CHECKSUM_HASH_TYPE_SHA512 = 'SHA_512'

    # Mapping of the hash types to the maching Digest modules
    # See {.calculate_checksum}
    CHECKSUM_HASH_TYPES = {
      CHECKSUM_HASH_TYPE_MD5 => Digest::MD5,
      CHECKSUM_HASH_TYPE_SHA256 => Digest::SHA256,
      CHECKSUM_HASH_TYPE_SHA512 => Digest::SHA512
    }.freeze

    DEFAULT_CHECKSUM_HASH_TYPE = CHECKSUM_HASH_TYPE_SHA512

    # if no manifest filename is provided, this suffix will be appended to the
    # fileName, with spaces converted to dashes.
    MANIFEST_FILENAME_DEFAULT_SUFFIX = '-manifest.plist'

    # If no manifest bundle identifier is provided, this will be used before
    # the packageName.
    MANIFEST_BUNDLE_ID_PREFIX = 'com.pixar.ruby-jss.'

    # if no manifest bundle version is provided, this will be used.
    MANIFEST_BUNDLE_VERSION_DEFAULT = '0'

    # Not doing chunking by default in generated manifests,
    # but if we do, we'll use this
    MANIFEST_CHUNK_SIZE = 1024 * 1024 * 10 # 10MB

    MANIFEST_PLIST_TEMPLATE = {
      items: [
        {
          assets: [
            {
              'kind' => 'software-package',
              'sha256s' => [],
              'url' => 'url-goes-here'
            } # end hash
          ], # end assets array,
          metadata: {
            'kind' => 'software',
            'bundle-identifier' => "#{MANIFEST_BUNDLE_ID_PREFIX}example",
            'bundle-version' => MANIFEST_BUNDLE_VERSION_DEFAULT,
            'title' => 'title',
            'sizeInBytes' => 1,
            'sha256-whole' => 'sha256-goes-here'
          } # end metadata
        } # end hash
      ] # end items array
    }.freeze

    # The endpoint for deploying a package via MDM
    # see https://developer.jamf.com/jamf-pro/reference/post_v1-deploy-package
    DEPLOYMENT_ENDPOINT = '/v1/deploy-package?verbose=true'

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

    # Setter for a default base URL for package manifests.
    # Manifests are required for packages deployed via enrollment prestages
    # or via the InstallEnterpriseApplication MDM command.
    #
    # When generating a manifest for a package, you must provide a URL
    # from which the package can be downloaded. This is usually from your
    # Cloud Distribution Point, but can be some other https web server.
    #
    # If Jamf.config.package_manifest_base_url is defined (see {Jamf::Configuration})
    # then that will be used as the default. Otherwise, or if you wish to override
    # the config, the value set here will be used as the default for generating manifests
    # for all Jamf::JPackage objects in this ruby session.
    #
    # Setting this in the config or here means you don't have to provide a base URL
    # each time when calling #generate_manifest or #upload, however you can still provide
    # one at that time to override any default.
    #
    # Normally, the package's fileName is appended to this URL to generate the full
    # download URL. E.g. for a package with a fileName 'my-app.pkg', with the base URL of
    # 'https://my-cdp.myorg.com', the download URL in the manifest would be
    # 'https://my-cdp.myorg.com/my-app.pkg'
    #
    # See {#generate_manifest} for more info.
    #
    # @param url[String] the default base URL for building manifests, overrides any
    #   value in the config.
    #
    # @return [void]
    ############
    def self.default_manifest_base_url=(url)
      @default_manifest_url = url.to_s
    end

    # Getter for the default base URL for package manifests.
    # This will be the one set for the class for this ruby session, or the one set in the
    # Jamf.config.package_manifest_base_url
    # seealso {JPackage.default_manifest_base_url=}
    #
    # @return [String] the default base URL for building manifests
    ############
    def self.default_manifest_base_url
      @default_manifest_url || Jamf.config.package_manifest_base_url
    end

    # Attributes
    #####################################

    # Checksums
    #
    # Packages in Jamf Pro can have a checksum in either MD5 or SHA512, or possibly
    # SHA256 - none of our 1500 pkgs have 256, but given the existence of the sha256
    # attribute in the API data, I'm assuming it existed at some point, and behaves like
    # md5 (read on)
    #
    # In all cases, the hashType attribute indicates the type of checksum, as a string,
    # one of 'MD5', 'SHA_256', or 'SHA_512'.
    #
    # In the case of md5 and sha256, the actual digest value (the checksum) is in the
    # 'md5' or 'sha256' attribute. In the case of sha512, the digest is in the 'hashValue'
    # attribute.
    # In anycase, the digest value will also be stored in the checksum attribute
    #
    # NOTE: This is the checksum used when installing via a Policy.
    # The checksum(s) used when deploying via MDM is stored in the manifest.
    #
    # @return [String] the checksum of the package, either an MD5, SHA256, or SHA512
    #   digest of the package file.
    attr_reader :checksum

    # The response body of the last upload of this package, with a timestamp added.
    # Looks like:
    #  {
    #    :id=>"10392",
    #    :href=>"https://casper-int.pixar.com:8443/api/v1/packages/10392/upload/10392"
    #    :time=>2025-09-01 12:00:00 -0700
    #  }
    # see #upload
    # @return [Hash] the response body of the last upload of this package
    attr_reader :upload_response

    # The response body of the last mdm-deploy of this package. see #deploy_via_mdm
    #
    #   {
    #     "queuedCommands": [
    #       {
    #         "device": 1,
    #         "commandUuid": "aaaaaaaa-3f1e-4b3a-a5b3-ca0cd7430937"
    #       }
    #     ],
    #     "errors": [
    #       {
    #         "device": 2,
    #         "group": 3,
    #         "reason": "Device does not support the InstallEnterpriseApplication command"
    #       }
    #     ]
    #   }
    #
    # @return [Hash] the response body of the last mdm-deploy of this package
    attr_reader :deploy_response

    # Constructor
    #####################################

    # Make an instance. Data comes from the API
    #
    # @param data[Hash] the data for constructing a new object.
    ##############################
    def initialize(**data)
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

    # @return [Pathname] the local receipt when this pkg is installed by a policy
    #############################
    def receipt
      # the receipt is the filename with any .zip extension removed.
      fileName ? (Jamf::Client::RECEIPTS_FOLDER + fileName.to_s.sub(/.zip$/, '')) : nil
    end

    # Change the os_requirements field in the JSS
    # E.g. 10.5, 10.5.3, 10.6.x
    #
    # Extra feature: Minumum OS's can now be specified as a
    # string using the notation ">=10.6.7".
    #
    # @see Jamf.expand_min_os
    #
    # @param new_val [String,Array<String>] comma-separated string, or array of os versions
    #
    # @return [void]
    #############################
    def osRequirements=(new_val)
      # make sure we have an array
      new_val = [new_val].flatten.compact.uniq.map(&:to_s)
      new_val.map! do |vers|
        vers.start_with?('>=') ? Jamf.expand_min_os(vers) : vers
      end

      orig_osRequirements = osRequirements
      @osRequirements = new_val.join(', ')
      note_unsaved_change :osRequirements, orig_osRequirements
    end

    # Recalculate the checksum of the package file from a given filepath, and update the
    # object's checksum and hashValue attributes.
    #
    # NOTE: This updates the checksum used when installing via a Policy.
    # The checksum(s) used when deploying via MDM is stored in the manifest.
    #
    # You will need to call #save on the object to save the new checksum to the server.
    #
    # New checksums are always SHA512
    #
    # @param filepath [String, Pathname] the path to a local copy of the package file
    #
    # @return [String] The new checksum of the package file
    ##############################
    def recalculate_checksum(filepath)
      # update the checksum
      @checksum = self.class.calculate_checksum(filepath, DEFAULT_CHECKSUM_HASH_TYPE)
      self.hashType = DEFAULT_CHECKSUM_HASH_TYPE
      self.sha256 = nil
      self.md5 = nil
      self.hashValue = @checksum
    end

    # @param filepath [String, Pathname] the path to a local copy of the package file
    # @return [Boolean] Does the checksum of the file match the checksum in the object?
    #   nil if there is no checksum in the object.
    ##############################
    def checksum_valid?(filepath)
      return unless checksum

      self.class.calculate_checksum(filepath, hashType) == checksum
    end

    # @return [String] A default if none is set explicitly
    ##############################
    def default_manifestFileName
      "#{fileName.gsub(' ', '-')}#{MANIFEST_FILENAME_DEFAULT_SUFFIX}"
    end

    # Set the manifest from a local file or a String containing an XML plist.
    # If from a file, the manifestFileName attribute is set to the filename
    #
    # To automatically generate a manifest plist for this package from a
    # locally-readable .pkg file, use #generate_manifest
    #
    # All manifests require a valid URL for downloading the .pkg file when
    # installing on a client.
    #
    # No validation of the manifest is done here.
    #
    # DEPLOYING VIA MDM:
    #
    # When using this method, if you want to be able to deploy the package using
    # deploy_via_mdm, the manifest MUST include a metadata dictionary
    # with at least the following keys:
    #   - 'kind' = 'software'
    #   - 'bundle-identifier' that preferably matches the bundle identifier of the pkg
    #   - 'bundle-version' = that preferably matches the version of the pkg
    #   - 'title' = the name of the pkg or what it installs
    #   - 'sizeInBytes' = the size of the .pkg in bytes
    # as well as one of these non-standard keys:
    #   - 'sha256-whole' = the SHA256 digest of the whole file, regardless of chunking data in the 'assets' array
    # OR
    #   - 'md5-whole' = the MD5 digest of the whole file, regardless of chunking data in the 'assets' array
    #
    # The non-standard keys are because the Jamf Pro API endpoint for deploying via MDM requires
    # a whole-file checksum even if the file is chunked in the manifest.
    #
    # See the MANIFEST_PLIST_TEMPLATE constant for an example of the data structure (as a ruby hash, not a plist)
    #
    # @param new_manifest [String, Pathname] the manifest plist data or path to a local file
    #
    # @return [void]
    ##############################
    def manifest=(new_manifest)
      # if its a string but not an xml plist, assume its a path
      new_manifest = Pathname.new(new_manifest) if new_manifest.is_a?(String) && !new_manifest.start_with?('<?xml')
      orig_manifest = manifest

      new_xml =
        if new_manifest.is_a? Pathname
          new_manifest.read

        elsif new_manifest.is_a? String
          new_manifest

        else
          raise ArgumentError, 'Argument must be a Pathname, or a String containing a path or an XML plist'
        end

      @manifest = new_xml
      note_unsaved_change :manifest, orig_manifest
    end

    # return the manifest as a ruby hash converted from the plist
    # IMPORTANT: all hash keys are strings, not symbols
    #
    # @return [Hash] the manifest as a ruby hash
    ##############################
    def manifest_hash
      return if manifest.to_s.empty?

      CFPropertyList.native_types(CFPropertyList::List.new(data: manifest).value)
    end

    # Generate a manifest plist (xml) for this package from a local .pkg file,
    # and update the #manifest and #manifestFileName attributes
    #
    # Afterwards, you will need to call #save on the object to save the new values to
    # the server.
    #
    # See also #manifest= for setting the manifest from a file or string.
    #
    # The download URL used in the manifest will be the default for the class
    # (if you have set one) usually with the fileName appended. The
    # class default may come from the ruby-jss config, or be set directly on the class,
    # see JPackage.default_manifest_base_url=
    #
    # Unless set explicitly afterward using #manifestFileName= the manifest filename
    # will be the fileName of the Package object, with spaces converted to dashes,
    # followed by MANIFEST_FILENAME_DEFAULT_SUFFIX.
    # e.g. my-app.pkg-manifest.plist
    #
    # By default, this method is invoked when uploading the pkg file using #upload
    # and the opts will be passed from that method to this one.
    # When invoked from #upload, the new values will be saved to the Jamf Pro server automatically.
    #
    # The manifests generated by this method are suitable for use in MDM deployments.
    #
    # If you don't provide a bundle_identifier, it will be generated from the packageName,
    # prefixed with 'com.pixar.ruby-jss.' and with spaces converted to dashes.
    #
    # If you don't provide a bundle_version, it will be '0'
    #
    # @param filepath [String, Pathname] the path to a local copy of the package file for which
    #   this manifest is being generated. This MUST match the one uploaded to the server, as it is
    #   used to calculate the checksums in the manifest.
    #
    # @param opts [Hash] a hash of keyword arguments
    #
    # @options opts url [String] the URL where the package will be downloaded from,
    #   defaults to the class default
    #
    # @option opts append_filename_to_url [Boolean] should the fileName be appended to the URL,
    #   defaults to true.
    #   If false, the url given must be the full URL to download the individual package file.
    #
    # @option opts chunk_size [Integer] the size of each chunk in the manifest, in bytes.
    #   If omitted, the whole file will be checksummed at once and downloads will not be chunked.
    #   A common chunk size is 10MB, or 1024 * 1024 * 10.
    #   NOTE: Not all distribution points support chunked downloads.
    #
    # @option opts bundle_identifier [String, Symbol] The bundle identifier of the package,
    #   Should match that in the .pkg itself.
    #   Defaults to 'com.pixar.ruby-jss.packageName' where packageName is the
    #   packageName with whitespace converted to dashes.
    #
    # @option opts bundle_version [String] the version of the package.
    #   Defaults to '0'
    #
    # @option opts subtitle [String] a subtitle for the package, optional
    #
    # @option opts full_size_image_url [String] optional, used during MDM deployment
    #
    # @option opts display_image_url [String] optional, used during MDM deployment
    #
    # @return [void]
    ##############################
    def generate_manifest(filepath, **opts)
      # make sure the file exists
      file = Pathname.new(filepath)
      validate_local_file(file)

      filesize = file.size

      # make the manifest
      new_manifest = MANIFEST_PLIST_TEMPLATE.dup

      url = build_manifest_url opts[:url], append_filename: opts[:append_filename_to_url]

      new_manifest[:items][0][:assets][0]['url'] = url.to_s

      # get the checksum(s)
      calculate_manifest_checksums(file, new_manifest, chunk_size: opts[:chunk_size])

      append_manifest_image('full-size-image', opts[:full_size_image_url], new_manifest) if opts[:full_size_image_url]

      append_manifest_image('display-image', opts[:display_image_url], new_manifest) if opts[:display_image_url]

      new_manifest[:items][0][:metadata]['title'] = packageName
      new_manifest[:items][0][:metadata]['subtitle'] = opts[:subtitle] if opts[:subtitle]
      new_manifest[:items][0][:metadata]['sizeInBytes'] = filesize
      new_manifest[:items][0][:metadata]['bundle-identifier'] =
        (opts[:bundle_identifier] || "#{MANIFEST_BUNDLE_ID_PREFIX}#{packageName.gsub(/\s+/, '-')}")
      new_manifest[:items][0][:metadata]['bundle-version'] = opts[:bundle_version] if opts[:bundle_version]

      plist = CFPropertyList::List.new
      plist.value = CFPropertyList.guess(new_manifest)
      self.manifest = plist.to_str(CFPropertyList::List::FORMAT_XML, formatted: true)

      self.manifestFileName = default_manifestFileName
    end

    # validate a local file path, raising an error if it's not valid
    #
    # @param filepath [Pathname] the path to a local copy of the package file for which
    # @return [void]
    ##############################
    def validate_local_file(file)
      raise ArgumentError, 'No locally-readable file provided' unless file.readable?
    end
    private :validate_local_file

    # Figure out the url to use for a manifest, based on the class default or
    # one provided in the options.
    # Raises an error if no URL is provided directly or via the class default, or if
    # the url is not valid.
    #
    # @param given_url [String] the URL to use, if provided
    # @param append_filename [Boolean] should the filename be appended to the URL?
    #
    # @return [URI] the URI object for the URL
    ##############################
    def build_manifest_url(given_url = nil, append_filename: true)
      url = given_url || self.class.default_manifest_base_url
      unless url
        raise ArgumentError,
              'No URL for manifest. Pass one with url: or set one with Jamf::JPackage.default_manifest_base_url=, or set package_manifest_base_url in the ruby-jss.conf file.'
      end

      # append the filename to the URL if needed
      url = "#{url.to_s.chomp('/')}/#{CGI.escape fileName}" unless append_filename == false

      # check validity and return
      URI.parse url
    end
    private :build_manifest_url

    # calculate the manifest checksum[s] for a given file, and store in the manifest data.
    # We only do SHA256, but Apple supports MD5 as well.
    #
    # @param file [Pathname] the path to the file to checksum
    # @param chunk_size [Integer] the size of each chunk in the manifest, in bytes.
    #   if omitted, the whole file will be checksummed at once and downloads will not be chunked.
    #   A common chunk size is 10MB, or 1024 * 1024 * 10
    # @param new_manifest [Hash] the manifest data to update with the checksums
    #
    # @return [void]
    ##############################
    def calculate_manifest_checksums(file, new_manifest, chunk_size: nil)
      # are we chunking the download?
      if chunk_size.is_a? Integer
        new_manifest[:items][0][:assets][0]['sha256-size'] = chunk_size
        file.open do |f|
          while chunk = f.read(chunk_size) # only load chunk_size bytes at a time
            new_manifest[:items][0][:assets][0]['sha256s'] << Digest::SHA256.hexdigest(chunk)
          end
        end

      # not chunking, use the file filesize
      else
        new_manifest[:items][0][:assets][0]['sha256-size'] = file.size
        new_manifest[:items][0][:assets][0]['sha256s'] = [Digest::SHA256.hexdigest(file.read)]
      end

      # Store the whole-file checksum in
      # manifest[:items][0][:metadata]['sha256-whole']. taking it from
      # manifest[:items][0][:assets][0]['sha256s'][0], if available, or generate it if needed
      # It is used by the deploy_via_mdm method.
      # This value is required for MDM deployments, even if the file is chunked in the manifest.
      new_manifest[:items][0][:metadata]['sha256-whole'] =
        if new_manifest[:items][0][:assets][0]['sha256s'].size == 1
          new_manifest[:items][0][:assets][0]['sha256s'][0]
        else
          Digest::SHA256.hexdigest(file.read)
        end
    end
    private :calculate_manifest_checksums

    # Append an image URL to the manifest, validating it as a URI
    #
    # @param asset_kind [String] the kind of asset, either 'full-size-image' or 'display-image'
    # @param url [String] the URL to append
    # @param new_manifest [Hash] the manifest data to update with the image URL
    #
    # @return [void]
    ##############################
    def append_manifest_image(asset_kind, url, new_manifest)
      new_manifest[:items][0][:assets] << {
        'kind' => asset_kind,
        'url' => URI.parse(url).to_s
      }
    end
    private :append_manifest_image

    # Upload a package file to Jamf Pro.
    #
    # WARNING: This will automatically call #save, saving any pending changes to
    # the Jamf Pro server!
    #
    # This uses the Jamf Pro API to upload the file via the package/upload endpoint.
    # If you don't use an appropriate primary distribution point, this may not work.
    # Also, that endpoint may not upload to any other distribution points.
    #
    # The fileName attribute of the JPackage object will be updated to the local filename.
    # If that filename is in use by some other package, you'll get an error:
    #    Field: fileName, Error: DUPLICATE_FIELD duplicate name
    #
    # This will automatically call #save at least once, and possibly twice.
    # First, in order to ensure the correct fileName in Jamf based on the file being uploaded,
    # and second, in order to update the checksum and manifest in Jamf Pro, if needed.
    # *** Any other outstanding changes will also be saved!
    #
    # After uploading, the response from the server is in the #upload_response attribute,
    # with a timestamp added to the data from the API.
    #
    # @param filepath [String, Pathname] the path to the package file to upload
    #
    # @param opts[Hash] a hash of keyword arguments
    #
    # @option opts :update_checksum [Boolean] update the checksum of the package in Jamf Pro.
    #   Defaults to true. All new checksums are SHA_512.
    #   WARNING: If you set this to false, the checksum in the object will not be updated
    #   and installs may fail. Be sure to set it to the correct value yourself.
    #
    # @option opts :update_manifest [Boolean] update the manifest of the package in Jamf Pro
    #   Defaults to true.
    #   WARNING: If you set this to false, the manifest in the object will not be updated
    #   and PreStage & MDM deployments may fail. Be sure to set it to the correct value
    #   using #generate_manifest or #manifest= yourself.
    #
    # @options opts url [String] See #generate_manifest
    #
    # @option opts append_filename_to_url [Boolean] See #generate_manifest
    #
    # @option opts chunk_size [Integer] See #generate_manifest
    #
    # @option opts bundle_identifier [String] See #generate_manifest
    #
    # @option opts bundle_version [String] See #generate_manifest
    #
    # @option opts subtitle [String] See #generate_manifest
    #
    # @option opts full_size_image_url [String] See #generate_manifest
    #
    # @option opts display_image_url [String] See #generate_manifest
    #
    # @return [void]
    ##############################
    def upload(filepath, **opts)
      file = Pathname.new(filepath)
      validate_local_file(file)

      # update the filename if needed
      # must happen before the upload so it matches the file being uploaded
      self.fileName = file.basename.to_s

      # We must save the checksum and manifest to the server before uploading
      # the file, because otherwise jamf will likely overwrite the manifest
      # after it uploads to the primary distribution point.

      # recalulate the checksum unless told no to
      # NOTE: It appears that the checksum will always be recaluclated by
      # the Jamf Pro server, as MD5. If you really want our default SHA512,
      # then do this again later, manually.
      recalculate_checksum(file) unless opts[:update_checksum] == false

      # generate a manifest using the new file
      generate_manifest(file, **opts) unless opts[:update_manifest] == false

      # save the new fileName, checksum and manifest
      save

      # upload the file
      @upload_response = cnx.jp_upload("#{get_path}/#{UPLOAD_ENDPOINT}", file)
      @upload_response[:time] = Time.now
      @upload_response
    end

    # Deploy this package to computers or a group via MDM.
    #
    # REQUIREMENTS:
    # - The package must have a manifest with specific data. See #manifest=
    #   and #generate_manifest for details.
    # - The .pkg file must be a product archive (.pkg) built with Xcode or productbuild.
    #   (it must contain a 'Distribution' file, usually generated by those tools)
    #   Simple 'component' packages built with pkgbuild are not supported.
    # - The .pkg file must be signed with a trusted signing certificate
    #
    # This will send an MDM InstallEnterpriseApplication command to install the package
    # to one or more computers, and/or the members of a single computer group.
    #
    # @param computer_ids [Array<Integer>,Integer] The ids of the computers to deploy to
    #
    # @param group_id [Integer] The id of the computer group to deploy to
    #
    # @param managed [Boolean] Should the installed package be managed by Jamf Pro?
    #   Defaults to false. This seems to be for App Store apps only??
    #
    # @return [Hash] the response from the server. see #deploy_response
    ##############################
    def deploy_via_mdm(computer_ids: nil, group_id: nil, managed: false)
      raise ArgumentError, 'No computer_ids or group_id provided' unless computer_ids || group_id
      raise Jamf::MissingDataError, 'No manifest set for this package' if manifest.to_s.empty?
      raise Jamf::NoSuchItemError, 'This package has no id, it must be saved in Jamf Pro before uploading' unless exist?

      # convert the full manifest to a ruby hash
      parsed_manifest = manifest_hash

      # manifest data for the MDMDeploy command, which is a hash.
      # hopefully some day Jamf will just use the manifest for the pkg
      mdm_manifest = {}
      mdm_manifest['url'] = manifest_url_for_deployment(parsed_manifest)
      mdm_manifest['hash'], mdm_manifest['hashType'] = manifest_checksum_for_deployment(parsed_manifest)
      mdm_manifest['bundleId'] = manifest_bundle_identifier_for_deployment(parsed_manifest)
      mdm_manifest['bundleVersion'] = manifest_bundle_version_for_deployment(parsed_manifest)
      mdm_manifest['title'] = manifest_title_for_deployment(parsed_manifest)
      mdm_manifest['sizeInBytes'] = manifest_size_for_deployment(parsed_manifest)

      set_optional_mdm_manifest_values(parsed_manifest, mdm_manifest)

      # make sure the computers are in an array
      computer_ids = [computer_ids].flatten.compact.uniq

      # make the payload
      payload = {
        manifest: mdm_manifest,
        installAsManaged: managed,
        devices: computer_ids
      }
      payload[:groupId] = group_id.to_s if group_id

      # send the command
      @deploy_response = cnx.post(DEPLOYMENT_ENDPOINT, payload)
    end

    # the URL is required for MDM deployments
    # @param parsed_manifest [Hash] the parsed manifest data as a ruby hash
    # @return [String] the URL in the manifest for MDM deployments
    #####################################
    def manifest_url_for_deployment(parsed_manifest)
      url = parsed_manifest.dig 'items', 0, 'assets', 0, 'url'
      raise Jamf::MissingDataError, 'No URL in the manifest' unless url

      url
    end
    private :manifest_url_for_deployment

    # whole-file checksums are required for MDM deployments
    # @return [Array<String>] the checksum and checksum type in the manifest for MDM deployments
    #####################################
    def manifest_checksum_for_deployment(parsed_manifest)
      if whole = parsed_manifest.dig('items', 0, 'metadata', 'sha256-whole')
        [whole, CHECKSUM_HASH_TYPE_SHA256_MDM_DEPLOY]
      elsif whole = parsed_manifest.dig('items', 0, 'metadata', 'md5-whole')
        [whole, CHECKSUM_HASH_TYPE_MD5]
      else
        raise Jamf::MissingDataError, 'No whole-file checksum in the manifest. Must have either sha256-whole or md5-whole in the metadata'
      end
    end
    private :manifest_checksum_for_deployment

    # size in bytes is required for MDM deployments
    # @return [Integer] the size in bytes in the manifest for MDM deployments
    #####################################
    def manifest_size_for_deployment(parsed_manifest)
      size = parsed_manifest.dig 'items', 0, 'metadata', 'sizeInBytes'
      raise Jamf::MissingDataError, 'No sizeInBytes in the manifest metadata' unless size

      size
    end
    private :manifest_size_for_deployment

    # bundle identifier is required for MDM deployments
    # @return [String] the bundle identifier in the manifest for MDM deployments
    #####################################
    def manifest_bundle_identifier_for_deployment(parsed_manifest)
      bid = parsed_manifest.dig 'items', 0, 'metadata', 'bundle-identifier'
      raise Jamf::MissingDataError, 'No bundle-identifier in the manifest metadata' unless bid

      bid
    end
    private :manifest_bundle_identifier_for_deployment

    # bundle version is required for MDM deployments
    # @return [String] the bundle version in the manifest for MDM deployments
    #####################################
    def manifest_bundle_version_for_deployment(parsed_manifest)
      bv = parsed_manifest.dig 'items', 0, 'metadata', 'bundle-version'
      raise Jamf::MissingDataError, 'No bundle-version in the manifest metadata' unless bv

      bv
    end
    private :manifest_bundle_version_for_deployment

    # title is required for MDM deployments
    # @return [String] the title in the manifest for MDM deployments
    #####################################
    def manifest_title_for_deployment(parsed_manifest)
      ttl = parsed_manifest.dig 'items', 0, 'metadata', 'title'
      raise Jamf::MissingDataError, 'No title in the manifest metadata' unless ttl

      ttl
    end
    private :manifest_title_for_deployment

    # set the optional values for the MDM deployment manifest
    # @return [void]
    #####################################
    def set_optional_mdm_manifest_values(parsed_manifest, mdm_manifest)
      # subtitle is optional for MDM deployments
      sttl = parsed_manifest.dig 'items', 0, 'metadata', 'subtitle'
      mdm_manifest['subtitle'] = sttl if sttl

      # Images are optional for MDM deployments
      parsed_manifest['items'][0]['assets']&.each do |asset|
        mdm_manifest['fullSizeImageURL'] = asset['url'] if asset['kind'] == 'full-size-image'
        mdm_manifest['displayImageURL'] = asset['url'] if asset['kind'] == 'display-image'
      end
    end
    private :set_optional_mdm_manifest_values

  end # class

end # module
