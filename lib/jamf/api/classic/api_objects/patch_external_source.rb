# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

  # An 'External' patch source. These sources are defined by Jamf Admins
  # and can be created, modified or deleted.
  #
  # @see Jamf::APIObject
  #
  class PatchExternalSource < Jamf::PatchSource

    include Jamf::Creatable

    # Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'patchexternalsources'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :patch_external_sources

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :patch_external_source

    # Instance Methods
    #####################################

    # Enable this source for retrieving patch info
    #
    # @return [void]
    #
    def enable
      return if enabled?

      validate_host_port('enable a patch source')
      @enabled = true
      @need_to_update = true
    end

    # Disable this source for retrieving patch info
    #
    # @return [void]
    #
    def disable
      return unless enabled?

      @enabled = false
      @need_to_update = true
    end

    # see PatchSource attr_reader :host_name
    #
    def host_name=(newname)
      return if newname == host_name
      raise Jamf::InvalidDataError, 'names must be String' unless name.is_a? String

      @host_name = name
      @need_to_update = true
    end
    alias hostname= host_name=
    alias host= host_name=

    # see PatchSource attr_reader :port
    #
    def port=(new_port)
      return if new_port == port
      raise Jamf::InvalidDataError, 'ports must be Integers' unless port.is_a? Integer

      @port = new_port
      @need_to_update = true
    end

    # Use SSL for connecting to the source host
    #
    # @return [void]
    #
    def use_ssl
      return if ssl_enabled?

      @ssl_enabled = true
      @need_to_update = true
    end
    alias enable_ssl use_ssl

    # Do not use SSL for connecting to the source host
    #
    # @return [void]
    #
    def no_ssl
      return unless ssl_enabled?

      @ssl_enabled = false
      @need_to_update = true
    end
    alias disable_ssl no_ssl

    def create
      validate_host_port('create a patch source')
      super
    end

    def update
      validate_host_port('update a patch source')
      super
    end

    private

    # raise an exeption if needed when trying to do something that needs
    # a host and port set
    #
    # @param action[String] The action that needs a host and port
    #
    # @return [void]
    #
    def validate_host_port(action)
      raise Jamf::UnsupportedError, "Cannot #{action} without first setting a host_name and port" if host_name.to_s.empty? || port.to_s.empty?
    end

    def rest_xml
      doc = REXML::Document.new
      src = doc.add_element self.class::RSRC_OBJECT_KEY.to_s
      src.add_element('enabled').text = @enabled.to_s
      src.add_element('name').text = @name
      src.add_element('ssl_enabled').text = @ssl_enabled.to_s
      src.add_element('host_name').text = @host_name
      src.add_element('port').text = @port.to_s
      doc.to_s
    end

  end # class PatchInternalSource

end # module Jamf
