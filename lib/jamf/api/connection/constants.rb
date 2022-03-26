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

# THe main module
module Jamf

  class Connection

    # This module defines constants related to API connctions, used throughout
    # the connection class and elsewhere.
    ##########################################
    module Constants

      # This version of ruby-jss only works with this version of the server
      # and higher
      MIN_JAMF_VERSION = Gem::Version.new('10.35.0')

      # The base of the Classic API resources
      CAPI_RSRC_BASE = 'JSSResource'.freeze

      # The base of the Jamf Pro API resources
      JPAPI_RSRC_BASE = 'api'.freeze

      # pre-existing tokens must have this many seconds before
      # before they expire
      TOKEN_REUSE_MIN_LIFE = 60

      # A string indicating we are not connected
      NOT_CONNECTED = 'Not Connected'.freeze

      # if @name is any of these when a connection is made, it
      # is reset to a default based on the connection params
      NON_NAMES = [NOT_CONNECTED, :unknown, nil, :disconnected].freeze

      HTTPS_SCHEME = 'https'.freeze

      # The Jamf default SSL port for on-prem servers
      ON_PREM_SSL_PORT = 8443

      # The https default SSL port for Jamf Cloud servers
      HTTPS_SSL_PORT = 443

      # Recognize Jamf Cloud servers
      JAMFCLOUD_DOMAIN = 'jamfcloud.com'.freeze

      # JamfCloud connections default to 443, not 8443
      JAMFCLOUD_PORT = HTTPS_SSL_PORT

      # The top line of an XML doc for submitting data via Classic API
      XML_HEADER = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'.freeze

      DFT_OPEN_TIMEOUT = 60
      DFT_TIMEOUT = 60

      # The Default SSL Version
      DFT_SSL_VERSION = 'TLSv1_2'.freeze

      RSRC_NOT_FOUND_MSG = 'The requested resource was not found'.freeze

      # values for the 'format' param of #c_get
      GET_FORMATS = %i[json xml].freeze

      HTTP_ACCEPT_HEADER = 'Accept'.freeze
      HTTP_CONTENT_TYPE_HEADER = 'Content-Type'.freeze

      MIME_JSON = 'application/json'.freeze
      MIME_XML = 'application/xml'.freeze

      # Only these variables are displayed with PrettyPrint
      # This avoids, especially, the caches, which are available
      # as attr_readers
      PP_VARS = %i[
        @name
        @connected
        @open_timeout
        @timeout
        @server_path
        @connect_time
      ].freeze

    end # module

  end # class

end # module Jamf
