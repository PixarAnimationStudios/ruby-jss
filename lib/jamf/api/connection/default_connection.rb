### Copyright 2022 Pixar
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

  # The connection class
  class Connection

    # Jamf module methods and aliases for dealing with the default connection
    ######################
    module DefaultConnection

      # The current default Jamf::Connection instance.
      #
      # @return [Jamf::Connection]
      #
      def cnx
        @default_connection ||= Connection.new name: :default
      end
      alias api cnx
      alias api_connection cnx
      alias connection cnx
      alias default_connection cnx

      # Create a new Connection object and use it as the default for all
      # future API calls. This will replace the existing default connection with
      # a totally new one
      #
      # @param (See Jamf::Connection#initialize)
      #
      # @return [String] the to_s output of the new connection
      #
      def connect(url = nil, **params)
        params[:name] ||= :default
        @default_connection = Connection.new url, params
        @default_connection.to_s
      end
      alias login connect
      alias new_api_connection connect
      alias new_api connect
      alias new_cnx connect
      alias new_connection connect

      # Use the given Jamf::Connection object as the default connection, replacing
      # the one that currently exists.
      #
      # @param connection [Jamf::Connection] The default Connection to use for future
      #   API calls
      #
      # @return [APIConnection] The connection now being used.
      #
      def cnx=(connection)
        raise 'API connections must be instances of Jamf::Connection' unless connection.is_a? Jamf::Connection

        @default_connection = connection
      end
      alias use_connection cnx=
      alias use_api_connection cnx=
      alias use_api cnx=
      alias activate_connection cnx=

      # Disconnect the default connection
      #
      def self.disconnect
        @default_connection.disconnect if @default_connection&.connected?
      end

      # Log out the default connection
      # This not only disconnects the connection, but tells the server to
      # invalidate the token that was used, meaning that token cannot be used
      # elsewhere before its expiration time.
      def self.logout
        @default_connection.logout if @default_connection&.connected?
      end

    end # module DefaultConnection

  end # class Connection

end # module Jamf
