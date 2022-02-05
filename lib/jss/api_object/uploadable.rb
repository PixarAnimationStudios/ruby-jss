### Copyright 2020 Pixar

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
module JSS

  #####################################
  # Module Variables
  #####################################

  #####################################
  # Module Methods
  #####################################

  #####################################
  # Sub-Modules
  #####################################

  #
  # A mixin module providing file-upload capabilities to JSSAPIObject subclasses.
  #
  # Classes mixing in this module are required to define a constant UPLOAD_TYPES
  # which is a Hash of :type => :resource pairs, like this:
  #
  #  UPLOAD_TYPES = {
  #     :icon => :mobiledeviceapplicationsicon
  #     :app => :mobiledeviceapplicationsipa
  #     :attachment => :mobiledeviceapplications
  #   }
  #
  # with one pair for each type of upload that the class can handle.
  # (most of them only handle one, usually :attachment)
  #
  # When the #upload method is called, one of the keys from that Hash must be specified
  #
  # Classes with only one upload type may want to redefine #upload to always call super with
  # that one type.
  #
  # ----
  #
  # Implementation Notes from
  # https://casperserver:8443/api/index.htm#!/fileuploads/uploadFiles_post
  #
  #   POST ...JSSResource/fileuploads/<resource>/<idType>/<id>
  #
  # You can POST different types of files by entering parameters for <resource>, <idType>, and <id>.
  # For example /JSSResource/fileuploads/computers/id/2.
  #
  # Attachments can be uploaded by specifying computers, mobiledevices, enrollmentprofiles, or
  # peripherals as the resource.
  #
  # Icons can be uploaded by specifying policies, ebooks, or mobiledeviceapplicationsicon as the resource.
  #
  # A mobile device application can be uploaded by using mobiledeviceapplicationsipa as the resource.
  #
  # A disk encryption can be uploaded by specifying diskencryptionconfigurations as the resource.
  #
  # idTypes supported are "id" and "name", although peripheral names are not supported.
  #
  # A sample command is:
  #   curl -k -u user:password https://my.jss:8443/JSSResource/fileuploads/computers/id/2 -F name=@/Users/admin/Documents/Sample.doc -X POST
  #
  #
  #
  #
  module Uploadable

    #  Constants
    #####################################

    UPLOADABLE = true

    UPLOAD_RSRC_PREFIX = 'fileuploads'.freeze

    FORCE_IPA_UPLOAD_PARAM = 'FORCE_IPA_UPLOAD'.freeze

    #  Class/Module Methods
    #####################################
    module ClassMethods

      # Upload a file to the JSS to be stored with an item of the
      # class mixing in the Uploadable module.
      #
      # This class method does not require fetching a Ruby instance first,
      # but the matching instance method will work for a specific instance if
      # it's already been fetched.
      #
      # @param ident[Integer, String] A unique identifier for the object taking the upload
      #
      # @param type[Symbol] the type of upload happening.
      #   Must be one of the keys defined in the class's UPLOAD_TYPES Hash.
      #
      # @param local_file[String, Pathname] String or Pathname pointing to the
      #   locally-readable file to be uploaded.
      #
      # @param force_ipa_upload[Boolean] Should the server upload the .ipa file to
      #   JCDS or AWS if such are confgured for use?
      #
      # @param api[JSS::APIConnection] the connection object for the operation.
      #   defaults to the default connection for the JSS module.
      #
      # @return [Boolean] was the  upload successful?
      #
      def upload(ident, type, local_file, force_ipa_upload: false, api: JSS.api)
        id = valid_id ident, :refresh, api: api
        raise "No #{self::RSRC_OBJECT_KEY} matching '#{ident}'" unless id

        # the type has to be defined in the class including this module.
        raise JSS::InvalidDataError, "#{self::RSRC_LIST_KEY} only take uploads of type: :#{self::UPLOAD_TYPES.keys.join(', :')}." \
          unless self::UPLOAD_TYPES.key? type

        # figure out the resource after the UPLOAD_RSRC_PREFIX
        upload_rsrc = "#{UPLOAD_RSRC_PREFIX}/#{self::UPLOAD_TYPES[type]}/id/#{id}"

        upload_rsrc << "?#{FORCE_IPA_UPLOAD_PARAM}=true" if self::UPLOAD_TYPES[type] == :mobiledeviceapplicationsipa && force_ipa_upload

        api.upload upload_rsrc, local_file
      end # def upload

    end # module classmethods

    # this loads the class methods (via 'extend') when the instanace methods
    # are included
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    #  Instance Methods
    #####################################

    # instance method wrapper for class method
    #
    # Upload a file to the JSS to be stored with this instance of the
    # class mixing in the Uploadable module
    #
    # @param type[Symbol] the type of upload happening.
    #   Must be one of the keys defined in the class's UPLOAD_TYPES Hash.
    #
    # @param local_file[String, Pathname] String or Pathname pointing to the
    #   locally-readable file to be uploaded.
    #
    # @param force_ipa_upload[Boolean] Should the server upload the .ipa file to
    #   JCDS or AWS if such are confgured for use?
    #
    # @return [Boolean] was the  upload successful?
    #
    def upload(type, local_file, force_ipa_upload: false)
      # the thing's gotta be in the JSS, and have an @id
      raise JSS::NoSuchItemError, "Create this #{self.class::RSRC_OBJECT_KEY} in the JSS before uploading files to it." unless @id && @in_jss

      self.class.upload @id, type, local_file, force_ipa_upload: force_ipa_upload, api: @api
    end

  end # module FileUpload

end # module JSS
