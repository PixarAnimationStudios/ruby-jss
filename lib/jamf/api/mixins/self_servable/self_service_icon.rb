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
module Jamf

    # An Icon in the JSS, used in Self Service.
    #
    # At the moment, icons are not API objects, they are collections of data
    # stored in the JSS that might be included in some API object's
    # Self Service data.
    #
    # The data available for an icon are:
    #
    # - id: the icon's id in the JSS
    # - name: the icon's non-unique name in the JSS
    # - uri: the uri to download or preview the icon
    # - data: the icon file itself, base-64 encoded.
    #
    # Icon instances are read-only. To change the icon for a self-servable object,
    # see {SelfServable#icon=}.
    #
    # NOTE: Since icons are not APIObjects, there's no way to see a list of them
    # via the API. The Jamf::Icon class methods .all, .all_ids, and .all_names
    # require MySQL database access. See {Jamf::DBConnection}.
    #
    # This also means, if you use multiple API connections, you'll have to
    # make sure to connect to the correct MySQL server for the
    # APIConnection you care about.
    #
    class Icon

      #  Class Methods
      #####################################

      # Return an Array of { id:, name: } Hashes for all icons known to the JSS
      # Since Icon lists aren't accessible via the API, this method must
      # query the SQL database directly, and will raise an exception if you
      # aren't connected to the database.
      #
      # @param refresh[Boolean] re-read the data from the server?
      #
      # @return [Array<Hash>] The names and ids of all icons known to the JSS
      #
      def self.all(refresh = false)
        @all_icons = nil if refresh
        return @all_icons if @all_icons
        @all_icons = []
        qry = 'SELECT icon_id, filename FROM icons'
        res = Jamf::DB_CNX.db.query qry
        res.each_hash { |icon| @all_icons << { id: icon['icon_id'].to_i, name: icon['filename'] } }
        @all_icons
      end

      # An Array of all icon ids known to the JSS.
      # See {Icon.all}.
      #
      # @param refresh[Boolean] re-read the data from the server?
      #
      # @return [Array<Integer>] The ids of all icons known to the JSS
      #
      def self.all_ids(refresh = false)
        all(refresh).map { |i| i[:id] }
      end

      # An Array of all icon names known to the JSS.
      # See {Icon.all}.
      # NOTE: Icon names are not unique
      #
      # @param refresh[Boolean] re-read the data from the server?
      #
      # @return [Array<Integer>] The names of all icons known to the JSS
      #
      def self.all_names(refresh = false)
        all(refresh).map { |i| i[:name] }
      end

      #  Attributes
      #####################################

      # @return [Integer] the icon's id in the JSS
      attr_reader :id

      # @return [String] the icon's name in the JSS
      #   NOTE: these are not unique
      attr_reader :name
      alias filename name

      # @return [String] The URI for downloading or previewing the icon from the JSS
      attr_reader :uri

      # @return [String] The raw icon file.
      attr_reader :data


      #  Constructor
      #####################################

      # Set up a new Jamf::Icon instance
      #
      # @param icon_data[Hash] The :self_service_icon Hash from the :self_service
      #   Hash of an object's API @init_data
      #
      # @return [Jamf::Icon] The new object
      #
      def initialize(icon_data)
        return unless icon_data.is_a? Hash
        @id = icon_data[:id]
        @name = icon_data[:filename]
        @uri = icon_data[:uri]
        @data = icon_data[:data]

        # if no :filename, its called :name
        @name ||= icon_data[:name]

        # if there's no id, as with MobileDeviceConfigurationProfile
        # get it from the end of the uri if possible
        if @uri && !@id
          @id = Regexp.last_match(1).to_i if @uri =~ /(\d+)$/
        end

        # decode the icon data, or grab from
        # the URI if needed
        @data = Base64.decode64(@data) if @data
        begin
          @data ||= URI.parse(@uri).read if @uri
        rescue
          @data = nil
        end

      end

      # Instance Methods
      #####################################

      # Open the icon's URL in the current user's browser
      #
      # @return [void]
      #
      def show_in_browser
        return nil unless @uri
        system "/usr/bin/open '#{@uri}'"
      end

      # Save the icon to a file.
      #
      # @param path[Pathname, String] The path to which the file should be saved.
      # If the path given is an existing directory, the icon's current filename will
      # be used, if known.
      #
      # @param overwrite[Boolean] Overwrite the file if it exists? Defaults to false
      #
      # @return [void]
      #
      def save(path, overwrite = false)
        path = Pathname.new path
        path = path + @name if path.directory? && @name

        raise Jamf::AlreadyExistsError, "The file #{path} already exists" if path.exist? unless overwrite
        path.delete if path.exist?
        path.jss_save @data
      end

      # Remove the data  object from
      # the instance_variables used to create
      # pretty-print (pp) output.
      #
      # @return [Array] the desired instance_variables
      #
      def pretty_print_instance_variables
        vars = instance_variables.sort
        vars.delete :@data
        vars
      end

    end # class icon

end # module
