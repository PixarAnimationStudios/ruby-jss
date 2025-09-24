# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

# THe main module
module Jamf

  # The connection class
  class Connection

    # Jamf module methods and aliases for dealing with the default connection
    # This is extended into the Jamf module itself
    ######################
    module DefaultConnection

      # The current default Jamf::Connection instance.
      #
      # @return [Jamf::Connection]
      #
      def cnx
        @default_connection ||= Jamf::Connection.new name: :default
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
        @default_connection = Jamf::Connection.new url, **params
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
      def disconnect
        @default_connection.disconnect if @default_connection&.connected?
      end

      # Log out the default connection
      # This not only disconnects the connection, but tells the server to
      # invalidate the token that was used, meaning that token cannot be used
      # elsewhere before its expiration time.
      def logout
        @default_connection.logout if @default_connection&.connected?
      end

    end # module DefaultConnection

  end # class Connection

end # module Jamf
