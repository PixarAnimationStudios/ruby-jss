# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
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
      #
      # NOTE: Some objects and features may require newer versions of Jamf Pro than this.
      # However this is the minimum required for even making an API connection using this
      # version of ruby-jss.
      #
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

      SLASH = '/'

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

      SET_COOKIE_HEADER = 'set-cookie'.freeze

      COOKIE_HEADER = 'Cookie'.freeze

      STICKY_SESSION_COOKIE_NAME = 'APBALANCEID'.freeze

    end # module

  end # class

end # module Jamf
