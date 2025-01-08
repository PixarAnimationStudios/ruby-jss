# Copyright 2025 Pixar

#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

module Jamf

  # Module Methods
  #####################################

  # A FileShare Distribution Point in the JSS
  #
  # As well as the normal Class and Instance methods for {APIObject} subclasses, the
  # DistributionPoint class provides more interaction with other parts of the API.
  #
  # Beyond the standard listing methods DistributionPoint.all, .all_ids, etc, every JSS
  # has a single "master" distribution point.  The Class method {DistributionPoint.master_distribution_point} will
  # return the Jamf::DistributionPoint object for that master.
  #
  # Also, some network segments have specific DistributionPoints assigned to them. Calling the Class method
  # {DistributionPoint.my_distribution_point} will return a Jamf::DistributionPoint object for your local IP address.
  #
  # Once you have an instance of Jamf::DistributionPoint, you can mount it (on a Mac) by calling its {#mount} method
  # and unmount it with {#unmount}. The {Jamf::Package} and possibly {Jamf::Script} classes use this to upload
  # items to the master.
  #
  # NOTE: This class only deals with FileShare Distribution Points.
  # There is no access to the Cloud Distribution Point in the classic API.
  # See the .master_distribution_point and .my_distribution_point class methods
  # for how they handle things when the Cloud DP is the master.
  #
  # @see Jamf::APIObject
  #
  class DistributionPoint < Jamf::APIObject

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'distributionpoints'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    # its also used in various error messages
    RSRC_LIST_KEY = :distribution_points

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :distribution_point

    # what  are the mount options? these are comma-separated, and are passed with -o
    MOUNT_OPTIONS = 'nobrowse'.freeze

    # An empty SHA256 digest
    EMPTY_PW_256 = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'.freeze

    # Set default local mount for distribution point
    DEFAULT_MOUNTPOINT_DIR = Pathname.new '/tmp'

    DEFAULT_MOUNTPOINT_PREFIX = 'CasperDistribution-id'.freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 76

    # Class Methods
    #####################################

    # Get the DistributionPoint instance for the master distribution point.
    #
    # If the Cloud Dist Point is master, then the classic API has no way to
    # know that or access it. In that case you can provide the 'default:' parameter.
    # Give it the name or id of any dist. point to be used instead, or give it
    # :random to randomly choose one.
    #
    # If there are no fileshare dist points defined (the cloud is the only one)
    # then this whole class can't really be used.
    #
    # @param refresh[Boolean] should the distribution point be re-queried?
    #
    # @param default[String, Integer, Symbol] Name or ID of a dist point to use
    #   if no master is found, or :random to randomly choose one.
    #
    # @param cnx [Jamf::Connection] which API connection should we query?
    #
    # @return [Jamf::DistributionPoint]
    #
    def self.master_distribution_point(refresh = false, default: nil, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      all_ids(refresh, cnx: cnx).each do |dp_id|
        dp = fetch id: dp_id, cnx: cnx
        return dp if dp.master?
      end

      case default
      when :random
        fetch id: all_ids.sample, cnx: cnx
      when nil
        raise Jamf::NoSuchItemError, 'No Master FileShare Distribtion Point. Use the default: parameter if needed.'
      else
        fetch default, cnx: cnx
      end
    end

    # Get the DistributionPoint instance for the machine running
    # this code, based on its IP address. If none is defined for this IP address,
    # use the name or id provided as default. If no default: is provided,
    # the master dp is used. If no master dp available (meaning its the
    # cloud dp) then use a randomly chosen dp.
    #
    # @param refresh[Boolean] should the distribution point be re-queried?
    #
    # @param default[String, Integer, Symbol] the name or id of a Dist Point
    #   to use if none is specified for this IP addr. Or :master, to use the
    #   master DP, or :random to use a randomly chosen one. If :master is
    #   specified and there is no master (master is cloud) then a random one is used.
    #
    # @param cnx [Jamf::Connection] which API connection should we query?
    #
    # @return [Jamf::DistributionPoint]
    #
    def self.my_distribution_point(refresh = false, default: :master, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      @my_distribution_point = nil if refresh
      return @my_distribution_point if @my_distribution_point

      my_net_seg_id = Jamf::NetworkSegment.my_network_segment refresh, cnx: cnx

      if my_net_seg_id
        my_net_seg = Jamf::NetworkSegment.fetch id: my_net_seg_id, cnx: cnx
        my_dp_name = my_net_seg.distribution_point
        @my_distribution_point = fetch name: my_dp_name, cnx: cnx if my_dp_name
      end # if my_net_seg_id

      return @my_distribution_point if @my_distribution_point

      @my_distribution_point =
        case default
        when String
          fetch name: default, cnx: cnx
        when Integer
          fetch id: default, cnx: cnx
        when :master
          master_distribution_point refresh, default: :random, cnx: cnx
        when :random
          fetch id: all_ids(refresh).sample, cnx: cnx
        end
    end

    # Class Attributes
    #####################################

    # @return [String] the hostname of this DP
    attr_reader :ip_address

    # @return [String] the local path on the server to the distribution point directory
    attr_reader :local_path

    # @return [String] load balanacing enabled?
    attr_reader :enable_load_balancing

    # @return [Integer] the id of the DP to use for failover
    attr_reader :failover_point

    # @return [Boolean] is this the master DP?
    attr_reader :is_master

    # FileService Access

    # @return [String] Protocol for fileservice access (e.g. AFP, SMB)
    attr_reader :connection_type

    # @return [Integer] the port for fileservice access
    attr_reader :share_port

    # @return [String]  the name of the fileservice sharepoint
    attr_reader :share_name

    # @return [String] the read-write username for fileservice access
    attr_reader :read_write_username

    # @return [String] the read-write password as a SHA256 digest
    attr_reader :read_write_password_sha256

    # @return [String] read-only username for fileservice
    attr_reader :read_only_username

    # @return [String] read-only password as a SHA256 digest
    attr_reader :read_only_password_sha256

    # @return [String] work group or domain for SMB
    attr_reader :workgroup_or_domain

    # http(s) access

    # @return [Boolean] are http downloads available from this DP?
    attr_reader :http_downloads_enabled

    # @return [String] the protocol to use for http downloads (http/https)
    attr_reader :protocol

    # @return [Integer] the port for http access
    attr_reader :port

    # @return [String] the "context" for http downloads (what goes after the hostname part of the URL)
    attr_reader :context

    # @return [Boolean] do http downloads work without auth?
    attr_reader :no_authentication_required

    # @return [Boolean] do http downloads use cert. authentication?
    attr_reader :certificate_required

    # @return [Boolean] do http downloads use user/pw auth?
    attr_reader :username_password_required

    # @return [String] the username to use for http downloads if needed for user/pw auth
    attr_reader :http_username

    # @return [String] the password for http downloads, if needed, as a SHA256 digest
    attr_reader :http_password_sha256

    # @return [String] the name of the cert. used for http cert. auth.
    attr_reader :certificate

    # @return [String] the URL for http downloads
    attr_reader :http_url

    # @return [String] the URL to use if this one doesn't work
    attr_reader :failover_point_url

    # ssh (scp, rsync, sftp) access

    # @return [String] ssh username
    attr_reader :ssh_username

    # @return [String] the ssh password as a SHA256 digest
    attr_reader :ssh_password_sha256

    def initialize(**args)
      super

      @ip_address = @init_data[:ip_address]
      @local_path = @init_data[:local_path]
      @enable_load_balancing = @init_data[:enable_load_balancing]
      @failover_point = @init_data[:failover_point]
      @is_master = @init_data[:is_master]

      @connection_type = @init_data[:connection_type]
      @share_port = @init_data[:share_port]
      @share_name = @init_data[:share_name]
      @workgroup_or_domain = @init_data[:workgroup_or_domain]

      @read_write_username = @init_data[:read_write_username]
      @read_write_password_sha256 = @init_data[:read_write_password_sha256]
      @read_only_username = @init_data[:read_only_username]
      @read_only_password_sha256 = @init_data[:read_only_password_sha256]
      @ssh_username = @init_data[:ssh_username]
      @ssh_password_sha256 = @init_data[:ssh_password_sha256]
      @http_username = @init_data[:http_username]
      @http_password_sha256 = @init_data[:http_password_sha256]

      @http_downloads_enabled = @init_data[:http_downloads_enabled]
      @protocol = @init_data[:protocol]
      @port = @init_data[:port]
      @context = @init_data[:context]
      @no_authentication_required = @init_data[:no_authentication_required]
      @certificate_required = @init_data[:certificate_required]
      @username_password_required = @init_data[:username_password_required]
      @certificate = @init_data[:certificate]
      @http_url = @init_data[:http_url]
      @failover_point_url = @init_data[:failover_point_url]

      @port = @init_data[:ssh_password]

      # if we mount for fileservice, where's the mountpoint?
      @mountpoint = DEFAULT_MOUNTPOINT_DIR + "#{DEFAULT_MOUNTPOINT_PREFIX}#{@id}"
    end # init

    # @deprecated The API no longer sends SHA256 hashed password data, and instead
    #   only has a string of asterisks, meaning we can no longer use it to validate
    #   passwords before attempting to use them. Instead, the processes that use
    #   them, e.g. mounting a Dist. Point, will fail on their own if the pw is not
    #   valid.
    #
    #   This method remains defined for backward-compatibility with any existing
    #   code that calls it. but it will always return true. It will be removed in
    #   a future version
    #
    # @param user[Symbol] ignored
    #
    # @param pw[String] ignored
    #
    # @return [TrueClass] Allow the process calling this to continue.
    #
    def check_pw(_user = nil, _pw = nil)
      true
    end

    # Check to see if this dist point is reachable for downloads (read-only)
    # via either http, if available, or filesharing.
    #
    # @param pw[String] the read-only password to use for checking the connection
    #   If http downloads are enabled, and no http password is required
    #   this can be omitted.
    #
    # @param check_http[Boolean] should we try the http download first, if enabled?
    #   If you're intentionally using the ro password for filesharing, and want to check
    #   only filesharing, then set this to false.
    #
    # @return [FalseClass, Symbol] false if not reachable, otherwise :http or :mountable
    #
    def reachable_for_download?(pw = '', check_http = true)
      return :http if check_http && http_reachable?(pw)
      return :mountable if mounted?

      begin
        mount pw, :ro
        :mountable
      rescue
        false
      ensure
        unmount
      end
    end

    # Check to see if this dist point is reachable for uploads (read-write)
    # via filesharing.
    #
    # @param pw[String] the read-write password to use for checking the connection
    #
    # @return [FalseClass, Symbol] false if not reachable, otherwise :mountable
    #
    def reachable_for_upload?(pw)
      return :mountable if mounted?

      begin
        mount pw, :rw
        :mountable
      rescue
        false
      ensure
        unmount
      end
    end

    #
    # Mount this distribution point locally.
    #
    # @param pw[String,Symbol] the read-only or read-write password for this DistributionPoint
    #   If :prompt, the user is promted on the commandline to enter the password for the :user.
    #   If :stdin#, the password is read from a line of std in represented by the digits at #,
    #   so :stdin3 reads the passwd from the third line of standard input. defaults to line 2,
    #   if no digit is supplied. see {JSS.stdin}
    #
    # @param access[Symbol] how to mount the DistributionPoint, and which password to expect.
    #  :ro (or anything else) = read-only, :rw = read-write
    #
    # @return [Pathname] the mountpoint.
    #
    def mount(pw = nil, access = :ro)
      return @mountpoint if mounted?

      access = :ro unless access == :rw

      password = if pw == :prompt
                   JSS.prompt_for_password "Enter the password for the #{access} user '#{access == :ro ? @read_only_username : @read_write_username}':"
                 elsif pw.is_a?(Symbol) && pw.to_s.start_with?('stdin')
                   pw.to_s =~ /^stdin(\d+)$/
                   line = Regexp.last_match(1)
                   line ||= 2
                   JSS.stdin line
                 else
                   pw
                 end

      username = access == :ro ? @read_only_username : @read_write_username

      safe_pw = CGI.escape password.to_s

      @mount_url = "#{@connection_type.downcase}://#{username}:#{safe_pw}@#{@ip_address}/#{@share_name}"
      @mnt_cmd = case @connection_type.downcase
                 when 'smb' then '/sbin/mount_smbfs'
                 when 'afp' then '/sbin/mount_afp'
                 else raise "Can't mount distribution point #{@name}: no known connection type."
                 end

      @mountpoint.mkpath

      mount_out = `#{@mnt_cmd} -o '#{MOUNT_OPTIONS}' '#{@mount_url}' '#{@mountpoint}' 2>&1`
      if ($CHILD_STATUS.exitstatus == 0) && @mountpoint.mountpoint?
        # if system @mnt_cmd.to_s, *['-o', MOUNT_OPTIONS, @mount_url, @mountpoint.to_s]
        @mounted = access
      else
        @mountpoint.rmdir if @mountpoint.directory?
        @mounted = nil
        raise Jamf::FileServiceError, "Can't mount #{@ip_address}: #{mount_out}"
      end
      @mountpoint
    end # mount

    # Unmount the distribution point.
    #
    # Does nothing if it wasn't mounted with #mount.
    #
    # @return [void]
    #
    def unmount
      return nil unless mounted?

      raise Jamf::FileServiceError, "There was a problem unmounting #{@mountpoint}" unless system "/sbin/umount '#{@mountpoint}'"

      sleep 1 # the umount takes time.
      @mountpoint.rmdir if @mountpoint.directory? && !@mountpoint.mountpoint?
      @mounted = false
      
        
      
      nil
    end # unmount

    # Is this thing mounted right now?
    #
    # @return [Boolean]
    #
    def mounted?
      @mountpoint.directory? && @mountpoint.mountpoint?
    end

    #### aliases
    alias hostname ip_address
    alias umount unmount
    alias master? is_master

    # Private Instance Methods
    ######################################
    private

    # can the dp be reached for http downloads?
    def http_reachable?(pw = nil)
      return false unless http_downloads_enabled

      url =
        if @username_password_required
          user_pass = "#{CGI.escape @http_username.to_s}:#{CGI.escape pw.to_s}@"
          @http_url.sub "://#{@ip_address}", "://#{user_pass}#{@ip_address}"
        else
          @http_url
        end
      URI.parse(url).read
      true
    rescue
      false
    end

    # Unused - until I get around to making DP's updatable
    #
    # the XML representation of the current state of this object,
    # for POSTing or PUTting back to the JSS via the API
    # Will be supported for Dist Points some day, I'm sure.
    #
    def rest_xml
      doc = REXML::Document.new
      dp = doc.add_element 'distribution_point'
      dp.add_element(:name.to_s).text = @name
      dp.add_element(:ip_address.to_s).text = @ip_address
      dp.add_element(:local_path.to_s).text = @local_path
      dp.add_element(:enable_load_balancing.to_s).text = @enable_load_balancing
      dp.add_element(:failover_point.to_s).text = @failover_point
      dp.add_element(:is_master.to_s).text = @is_master

      dp.add_element(:connection_type.to_s).text = @connection_type
      dp.add_element(:share_port.to_s).text = @share_port
      dp.add_element(:share_name.to_s).text = @share_name
      dp.add_element(:read_write_username.to_s).text = @read_write_username
      dp.add_element(:read_write_password.to_s).text = @read_write_password
      dp.add_element(:read_only_username.to_s).text = @read_only_username
      dp.add_element(:read_only_password.to_s).text = @read_only_password
      dp.add_element(:workgroup_or_domain.to_s).text = @workgroup_or_domain

      dp.add_element(:http_downloads_enabled.to_s).text = @http_downloads_enabled
      dp.add_element(:protocol.to_s).text = @protocol
      dp.add_element(:port.to_s).text = @port
      dp.add_element(:context.to_s).text = @context
      dp.add_element(:no_authentication_required.to_s).text = @no_authentication_required
      dp.add_element(:certificate_required.to_s).text = @certificate_required
      dp.add_element(:username_password_required.to_s).text = @username_password_required
      dp.add_element(:http_username.to_s).text = @http_username
      dp.add_element(:certificate.to_s).text = @certificate
      dp.add_element(:http_url.to_s).text = @http_url
      dp.add_element(:failover_point_url.to_s).text = @failover_point_url

      dp.add_element(:ssh_username.to_s).text = @ssh_username
      dp.add_element(:ssh_password.to_s).text = @ssh_password if @ssh_password

      doc.to_s
    end # rest_xml

  end # class

end # module
