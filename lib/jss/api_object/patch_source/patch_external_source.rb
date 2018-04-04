### Copyright 2018 Pixar

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

  # An 'External' patch source. These sources are defined by Jamf Admins
  # and can be created, modified or deleted.
  #
  # @see JSS::APIObject
  #
  class PatchExternalSource < JSS::PatchSource

    include JSS::Creatable
    include JSS::Updatable

    # Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'patchexternalsources'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :patch_external_sources

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :patch_external_source

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = %i[enabled ssl_enabled host_name].freeze

    # Instance Methods
    #####################################

    # @param name[String] the new source host name
    #
    # @return [void]
    #
    def host_name=(name)
      return if name == @hostname
      raise JSS::InvalidDataError, 'names must be String' unless name.is_a? String
      @host_name = name
      @need_to_update = true
    end
    alias hostname= host_name=
    alias host= host_name=

    # @param port[Integer] the new port on the source host name
    #
    # @return [void]
    #
    def port=(port)
      return if port == @port
      raise JSS::InvalidDataError, 'ports must be Integers' unless port.is_a? Integer
      @port = port
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

    # Do not use SSL for connecting to the source host
    #
    # @return [void]
    #
    def no_ssl
      return unless ssl_enabled?
      @ssl_enabled = false
      @need_to_update = true
    end

    def create
      validate_host_port('create a patch source')
      super
    end

    private

    def rest_xml
      doc = super
      src = doc.root
      src.add_element('name').text = @name
      src.add_element('ssl_enabled').text = @ssl_enabled.to_s
      src.add_element('host_name').text = @host_name
      src.add_element('port').text = @port.to_s
      doc.to_s
    end

  end # class PatchInternalSource

end # module JSS
