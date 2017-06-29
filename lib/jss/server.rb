### Copyright 2017 Pixar

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

  # A class representing the currently-connected JSS Server.
  #
  # The {JSS::APIConnection} instance has a JSS::Server instance in its #server
  # attribute. It is created fresh every time {APIConnection#connect} is called.
  #
  # That's the only time it should be instantiated, and all access should be
  # through {JSS.api_connection.server}
  #
  class Server

    # Constants
    #####################################
    ACTIVATION_CODE_RSRC = 'activationcode'.freeze
    ACTIVATION_CODE_KEY = :activation_code


    # Attributes
    #####################################

    # @return [String] the type of server licence
    attr_reader :license_type

    # @return [String] the license product name
    attr_reader :product

    #  @return [String] The version of the JSS. See the method JSS.parse_jss_version
    attr_reader :version

    #  @return [Integer]
    attr_reader :major_version

    #  @return [Integer]
    attr_reader :minor_version

    #  @return [Integer]
    attr_reader :revision_version

    #  @return [String]
    attr_reader :raw_version

    # Instance Methods
    #####################################

    # Initialize!
    # THe jss_data to be passed in is the JSON output of the 'jssuser' resource
    # on the API server.
    # the jssuser resource is readable by anyone with a JSS acct
    # regardless of their permissions.
    # However, it's marked as 'deprecated'. Hopefully jamf will
    # keep this basic level of info available for basic authentication
    # and JSS version checking.
    def initialize(jss_data)

      @license_type = jss_data[:license_type]
      @product = jss_data[:product]
      @raw_version = jss_data[:version]
      parsed = JSS.parse_jss_version(@raw_version)
      @major_version = parsed[:major]
      @minor_version = parsed[:minor]
      @revision_version = parsed[:revision]
      @version = parsed[:version]
    end

    # @return [String] the organization to which the server is licensed
    def organization
      @act_code_data ||= JSS.api_connection.get_rsrc(ACTIVATION_CODE_RSRC)[ACTIVATION_CODE_KEY]
      @act_code_data[:organization_name]
    end

    # @return [String] the activation code for the server licence
    def activation_code
      @act_code_data ||= JSS.api_connection.get_rsrc(ACTIVATION_CODE_RSRC)[ACTIVATION_CODE_KEY]
      @act_code_data[:code]
    end

    ##### Aliases
    alias institution organization
    alias product_name product

  end # class server

end # module
