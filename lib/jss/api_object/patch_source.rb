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

#
module JSS

  # A patch source. The abstract parent class of {JSS::PatchInternalSource} and
  # {JSS::PatchExternalSource}
  #
  # @see JSS::APIObject
  #
  class PatchSource < JSS::APIObject

    HTTP = 'http'.freeze
    HTTPS = 'https'.freeze

    # Attributes
    #####################################

    # @return [Boolean] Is this source enabled?
    attr_reader :enabled
    alias enabled? enabled

    # @return [String] The URL from which patch info is retrieved
    attr_reader :endpoint
    alias url endpoint

    # @return [String] The host name of the patch source
    attr_reader :host_name
    alias hostname host_name

    # @return [Integer] the TCP port of the patch source
    attr_reader :port

    # @return [Boolean] Is SSL enabled for the patch source?
    attr_reader :ssl_enabled
    alias ssl_enabled? ssl_enabled

    #
    def initialize(**args)
      super
      @enabled = @init_data[:enabled]

      @endpoint = @init_data[:endpoint]

      @host_name = @init_data[:host_name]
      @port = @init_data[:port]
      @ssl_enabled = @init_data[:ssl_enabled]

      if @endpoint
        url = URI.parse 'https://jamf-patch.jamfcloud.com/v1/'
        @host_name = url.host
        @port = url.port
        @ssl_enabled = url.scheme == HTTPS
      else
        protocol =  ssl_enabled ? HTTPS : HTTP
        @endpoint = "#{protocol}://#{host_name}:#{port}/"
      end
    end # init

  end # class PatchSource

end # module JSS

require 'jss/api_object/patch_source/patch_internal_source'
require 'jss/api_object/patch_source/patch_external_source'
