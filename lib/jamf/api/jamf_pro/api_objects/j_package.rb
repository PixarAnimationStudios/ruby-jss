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
    ALT_IDENTIFIERS = %i[packageName fileName].freeze

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

    # The hashType value in the API for sha256 - IF it exists
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

    # Not doing chunking by default in generated manifests
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
            'bundle-identifier' => 'com.example.pkg',
            'bundle-version' => '0',
            'title' => 'title',
            'sizeInBytes' => 1
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
    # each time when calling #generate_manifest, however you can still provide one
    # at that time to override any default.
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
    # Packages in Jamf Pro can have a checksum in either MD5 or SHA512, or possibly
    # SHA256 - none of our 1500 pkgs have 256, but given the existence of the sha256
    # attribute in the API data, I'm assuming it existed at some point, and behaves like
    # md5 (read on)
    #
    # In all cases, the hashType indicates the type of checksum, as a string, one of
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
    def receipt
      # the receipt is the filename with any .zip extension removed.
      fileName ? (Jamf::Client::RECEIPTS_FOLDER + fileName.to_s.sub(/.zip$/, '')) : nil
    end

    # Recalculate the checksum of the package file from a given filepath, and update the
    # object's checksum and hashValue attributes.
    #
    # You will need to call #save on the object to save the new checksum to the server.
    #
    # New checksums are always SHA512
    #
    # @param filepath [String, Pathname] the path to a local copy of the package file
    # @param type [String] the type of checksum to calculate, one of CHECKSUM_HASH_TYPES
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

    # @return [String] The manifest file name or a default if none is set
    ##############################
    def default_manifestFileName
      "#{fileName.gsub(' ', '-')}#{MANIFEST_FILENAME_DEFAULT_SUFFIX}"
    end

    # Set the manifest from a local file or XML plist string.
    # If from a file, update the manifestFileName attribute to use the filename
    #
    # To generate a basic manifest plist for this package, use #generate_manifest
    #
    # When using this method, if you want to be able to deploy the pkg using
    # #deploy_via_mdm, the manifest MUST include a metadata dictionary
    # with at least the following keys
    #  - 'bundle-identifier' that matches the bundle identifier of the pkg
    #  - 'bundle-version' = the version of the pkg
    #  - 'kind' = 'software'
    #  - 'title' = the name of the pkg or what it installs
    #  - 'sizeInBytes' = the size of the pkg in bytes
    # optional keys include bundle-version, and subtitle
    #
    # @param manifest [String, Pathname] the manifest plist data or path to a local file
    #
    # @return [void]
    ##############################
    def manifest=(manifest)
      if manifest.is_a? Pathname
        @manifest = manifest.read
        self.manifestFileName = manifest.basename.to_s
      else
        @manifest = manifest
      end
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

    # Generate a manifest plist (xml) for this package, update the #manifest attribute,
    # and assign an appropriate #manifestFileName.
    #
    # You will need to call #save on the object to save the new values to the server.
    #
    # The download URL used in the manifest will be the default for the class
    # (if you have set one) or the URL passed in, with the fileName appended
    #
    # Unless set explicitly, the manifest filename will be the fileName of the filepath
    # with spaces converted to dashes, followed by MANIFEST_FILENAME_DEFAULT_SUFFIX.
    # e.g. my-app.pkg-manifest.plist
    #
    # You can also do this when uploading the pkg file by providing appropriate options to #upload,
    # in which case the new values will be saved to the Jamf Pro server automatically.
    #
    # @param filepath [String, Pathname] the path to a local copy of the package file for which
    #   this manifest is being generated. This MUST match the one uploaded to the server, as it is
    #   used to calculate the checksums in the manifest.
    #
    # @param opts [Hash] a hash of keyword arguments
    #
    # @options opts url[String] the URL where the package will be downloaded from,
    #   defaults to the class default
    #
    # @option opts append_filename_to_url [Boolean] should the fileName be appended to the URL,
    #   defaults to true
    #   If false, the url given must be the full URL to download the individual package file.
    #
    # @option opts bundle_identifier [String, Symbol] the bundle identifier of the package,
    #   Should match that in the .pkg itself. Defaults to 'xolo.fileName'
    #
    # @option opts chunk_size [Integer] the size of each chunk in the manifest, in bytes.
    #   if omitted, the whole file will be checksummed at once and downloads will not be chunked.
    #   A common chunk size is 10MB, or 1024 * 1024 * 10
    #
    # @option opts bundle_version [String, Symbol] the version of the package.
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
      raise ArgumentError, 'No locally-readable file provided' unless file.readable?

      filesize = file.size

      opts[:url] ||= self.class.default_manifest_base_url
      raise ArgumentError, 'No URL provided for manifest generation' unless opts[:url]

      # append the filename to the URL if needed
      url = opts[:url].to_s.chomp('/') + "/#{CGI.escape fileName}" unless opts[:append_filename_to_url] == false

      # make sure it's valid a URI
      url = URI.parse url.to_s

      # remember the orig manifest
      manifest
      # make the manifest
      new_manifest = MANIFEST_PLIST_TEMPLATE.dup
      new_manifest[:items][0][:assets][0]['url'] = url.to_s

      # are we chunking the download?
      if opts[:chunk_size].is_a? Integer
        new_manifest[:items][0][:assets][0]['sha256-size'] = opts[:chunk_size]
        file.open do |f|
          while chunk = f.read(chunk_size) # only load chunk_size bytes at a time
            new_manifest[:items][0][:assets][0]['sha256s'] << Digest::SHA256.hexdigest(chunk)
          end
        end

      # not chunking, use the file filesize
      else
        new_manifest[:items][0][:assets][0]['sha256-size'] = filesize
        new_manifest[:items][0][:assets][0]['sha256s'] = [Digest::SHA256.hexdigest(file.read)]
      end

      if opts[:full_size_image_url]
        # make sure it's valid a URI
        URI.parse opts[:full_size_image_url]

        new_manifest[:items][0][:assets] << {
          'kind' => 'full-size-image',
          'url' => opts[:full_size_image_url]
        }
      end

      if opts[:display_image_url]
        # make sure it's valid a URI
        URI.parse opts[:display_image_url]

        new_manifest[:items][0][:assets] << {
          'kind' => 'display-image',
          'url' => opts[:display_image_url]
        }
      end

      new_manifest[:items][0][:metadata]['title'] = packageName
      new_manifest[:items][0][:metadata]['subtitle'] = opts[:subtitle] if opts[:subtitle]
      new_manifest[:items][0][:metadata]['sizeInBytes'] = filesize
      new_manifest[:items][0][:metadata]['bundle-identifier'] = opts[:bundle_identifier] || "xolo.#{fileName}"
      new_manifest[:items][0][:metadata]['bundle-version'] = opts[:bundle_version] || '0'

      # TESTING - store the whole-file checksum in
      # manifest[:items][0][:metadata]['sha256-whole']. taking it from
      # manifest[:items][0][:assets][0]['sha256s'][0], if available, or generate it if needed
      # It is used by the deploy_via_mdm method.
      # The test will be to deploy this pkg via MDM in a prestage, and see
      # if the 'unknown' hash key 'sha256-whole' causes a problem installing.
      new_manifest[:items][0][:metadata]['sha256-whole'] =
        if new_manifest[:items][0][:assets][0]['sha256s'].size == 1
          new_manifest[:items][0][:assets][0]['sha256s'][0]
        else
          new_manifest[:items][0][:assets][0]['sha256s'] = [Digest::SHA256.hexdigest(file.read)]
        end

      plist = CFPropertyList::List.new
      plist.value = CFPropertyList.guess(new_manifest)
      self.manifest = plist.to_str CFPropertyList::List::FORMAT_XML, formatted: true
      # note_unsaved_change :manifest, orig_manifest
      self.manifestFileName = default_manifestFileName
    end

    # Upload a package file to Jamf Pro for this package object.
    # After uploading, the upload response is in the @upload_response attribute.
    #
    # The fileName attribute of the JPackage object will be updated to the local filename
    # if it differs.
    # If that filename is in use by some other package, you'll get an error:
    #    Field: fileName, Error: DUPLICATE_FIELD duplicate name
    #
    # IMPORTANT: This will automatically call #save.
    # First, in order to ensure the correct fileName in Jamf based on the file being uploaded,
    # and second, in order to update the checksum and manifest in Jamf Pro, if needed.
    # *** Any other outstanding changes will also be saved!
    #
    # @param filepath [String, Pathname] the path to the package file to upload
    #
    # @param opts[Hash] a hash of keyword arguments
    #
    # @option opts :update_checksum [Boolean] update the checksum of the package in Jamf Pro.
    #   Defaults to true. All new checksums are SHA_512.
    #
    # @option opts :update_manifest [Boolean] update the manifest of the package in Jamf Pro
    #   Defaults to false
    #
    # @options opts :url [String] the URL where the package will be downloaded from,
    #   defaults to the class default
    #
    # @option opts append_filename_to_url [Boolean] should the fileName be appended to the URL,
    #   defaults to true
    #   If false, the url given must be the full URL to download the individual package file.
    #
    # @option opts bundle_identifier [String, Symbol] the bundle identifier of the package,
    #   Should match that in the .pkg itself. Defaults to 'xolo.fileName'
    #
    # @option opts chunk_size [Integer] the size of each chunk in the manifest, in bytes.
    #   if omitted, the whole file will be checksummed at once and downloads will not be chunked.
    #   A common chunk size is 10MB, or 1024 * 1024 * 10
    #
    # @option opts bundle_version [String, Symbol] the version of the package.
    #   Defaults to '0'
    #
    # @option opts subtitle [String] a subtitle for the package, optional
    #
    # @option opts full_size_image_url [String] optional
    #
    # @option opts display_image_url [String] optional
    #
    # @return [void]
    ##############################
    def upload(filepath, **opts)
      raise Jamf::NoSuchItemError, 'This package has no id, it must be saved in Jamf Pro before uploading' unless id
      raise Jamf::MissingDataError, 'No file path provided for upload' unless filepath

      file = Pathname.new(filepath)
      raise Jamf::MissingDataError, 'No readable file at the provided path' unless file.readable?

      # update the filename if needed
      # must happen before the upload
      real_filename = file.basename.to_s
      unless fileName == real_filename
        self.fileName = real_filename
        save
      end

      # upload the file
      @upload_response = cnx.jp_upload("#{get_path}/#{UPLOAD_ENDPOINT}", file)
      @upload_response[:time] = Time.now

      # recalulate the checksum unless told no to
      recalculate_checksum(file) unless opts[:update_checksum] == false

      # generate a manifest if needed
      generate_manifest file, **opts if opts[:update_manifest]

      # save the new checksum and manifest
      save
    end

    # Deploy this package to computers or a group via MDM.
    #
    # REQUIREMENTS:
    # - The package must have a manifest, see #generate_manifest
    # - The .pkg file must be a product archive (.pkg) built with Xcode or productbuild.
    #   Simple packages built with pkgbuild are not supported.
    # - The .pkg file must be signed with a Developer ID Installer certificate
    #
    # This will send a command to install the package to one or more
    # computers, and/or the members of a single computer group.
    #
    # The package must have a manifest set, see #generate_manifest
    #
    # @param computers [Array<Integer>,Integer] The ids of the computers to deploy to
    #
    # @param group [Integer] The id of the computer group to deploy to
    #
    # @param managed [Boolean] Should the installed package be managed by Jamf Pro, default is false.
    #
    # @return [void]
    ##############################
    def deploy_via_mdm(computers: nil, group: nil, managed: false)
      raise Jamf::MissingDataError, 'No manifest set for this package' unless manifest

      # convert the manifest to a hash
      parsed_manifest = manifest_hash

      # manifest for the MDMDeploy command, which is a hash.
      # hopefully some day jamf will just use the manifest for the pkg
      mdm_manifest = {}
      mdm_manifest['url'] = parsed_manifest['items'][0]['assets'][0]['url']
      mdm_manifest['hash'] = parsed_manifest['items'][0]['metadata']['sha256-whole']
      mdm_manifest['hashType'] = CHECKSUM_HASH_TYPE_SHA256_MDM_DEPLOY
      mdm_manifest['sizeInBytes'] = parsed_manifest['items'][0]['metadata']['sizeInBytes']
      mdm_manifest['bundleId'] = parsed_manifest['items'][0]['metadata']['bundle-identifier']
      mdm_manifest['bundleVersion'] = parsed_manifest['items'][0]['metadata']['bundle-version']
      mdm_manifest['title'] = parsed_manifest['items'][0]['metadata']['title']

      mdm_manifest['subtitle'] = parsed_manifest['items'][0]['metadata']['subtitle'] if parsed_manifest['items'][0]['metadata']['subtitle']

      parsed_manifest['items'][0]['assets'].each do |asset|
        mdm_manifest['fullSizeImageURL'] = asset['url'] if asset['kind'] == 'full-size-image'
        mdm_manifest['displayImageURL'] = asset['url'] if asset['kind'] == 'display-image'
      end

      # make sure the computers are in an array
      computers = [computers].flatten.compact.uniq

      # make the payload
      payload = {
        manifest: mdm_manifest,
        installAsManaged: managed,
        devices: computers,
        groupId: group.to_s
      }
      puts '-----'
      puts payload
      puts '-----'
      # send the command
      @deploy_response = cnx.post(DEPLOYMENT_ENDPOINT, payload)
    end

  end # class

end # module
