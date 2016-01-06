### Copyright 2014 Pixar
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

  #####################################
  ### Module Variables
  #####################################

  ### the master dist. point, see JSS.master_distribution_point
  @@master_distribution_point = nil

  ### the dist point for this machine right now
  @@my_distribution_point =nil

  #####################################
  ### Module Methods
  #####################################



  ###
  ### A Distribution Point in the JSS
  ###
  ### As well as the normal Class and Instance methods for {APIObject} subclasses, the
  ### DistributionPoint class provides more interaction with other parts of the API.
  ###
  ### Beyond the standard listing methods DistributionPoint.all, .all_ids, etc, every JSS
  ### has a single "master" distribution point.  The Class method {DistributionPoint.master_distribution_point} will
  ### return the JSS::DistributionPoint object for that master.
  ###
  ### Also, some network segments have specific DistributionPoints assigned to them. Calling the Class method
  ### {DistributionPoint.my_distribution_point} will return a JSS::DistributionPoint object for your local IP address.
  ###
  ### Once you have an instance of JSS::DistributionPoint, you can mount it (on a Mac) by calling its {#mount} method
  ### and unmount it with {#unmount}. The {JSS::Package} and possibly {JSS::Script} classes use this to upload
  ### items to the master.
  ###
  ### @see JSS::APIObject
  ###
  class DistributionPoint  < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "distributionpoints"

    ### the hash key used for the JSON list output of all objects in the JSS
    ### its also used in various error messages
    RSRC_LIST_KEY = :distribution_points

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :distribution_point

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:read_only_username, :ssh_username, :is_master ]

    ### what  are the mount options? these are comma-separated, and are passed with -o
    MOUNT_OPTIONS = 'nobrowse'

    ### An empty SHA256 digest
    EMPTY_PW_256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"



    #####################################
    ### Class Variables
    #####################################

    @@master_distribution_point = nil

    @@my_distribution_point = nil

    #####################################
    ### Class Methods
    #####################################

    ### Get the DistributionPoint instance for the master
    ### distribution point in the JSS. If there's only one
    ### in the JSS, return it even if not marked as master.
    ###
    ### @return [JSS::DistributionPoint]
    ###
    def self.master_distribution_point(refresh = false)
      @@master_distribution_point = nil if refresh
      return @@master_distribution_point if @@master_distribution_point

      case self.all.count
        when 0
          raise JSS::NoSuchItemError, "No distribution points defined"
        when 1
          self.new :id => self.all_ids[0]
        else
          self.new :id => :master
        end
    end

    ### Get the DistributionPoint instance for the machine running
    ### this code, based on its IP address. If none is defined for this IP address,
    ### use the result of master_distribution_point
    ###
    ### @param refresh[Boolean] should the distribution point be re-queried?
    ###
    ### @return [JSS::DistributionPoint]
    ###
    def self.my_distribution_point(refresh = false)
      @@my_distribution_point = nil if refresh
      return @@my_distribution_point if @@my_distribution_point

      my_net_seg = JSS::NetworkSegment.my_network_segment[0]
      specific = if my_net_seg
        JSS::NetworkSegment.new(:id => my_net_seg).distribution_point
      else
        nil
      end
      return specific ? self.new(:name => specific) : self.master_distribution_point
    end

    #####################################
    ### Class Attributes
    #####################################

    ### @return [String] the hostname of this DP
    attr_reader :ip_address

    ### @return [String] the local path on the server to the distribution point directory
    attr_reader :local_path

    ### @return [String] load balanacing enabled?
    attr_reader :enable_load_balancing

    ### @return [Integer] the id of the DP to use for failover
    attr_reader :failover_point

    ### @return [Boolean] is this the master DP?
    attr_reader :is_master

    ### FileService Access

    ### @return [String] Protocol for fileservice access (e.g. AFP, SMB)
    attr_reader :connection_type

    ### @return [Integer] the port for fileservice access
    attr_reader :share_port

    ### @return [String]  the name of the fileservice sharepoint
    attr_reader :share_name

    ### @return [String] the read-write username for fileservice access
    attr_reader :read_write_username

    ### @return [String] the read-write password as a SHA256 digest
    attr_reader :read_write_password_sha256

    ### @return [String] read-only username for fileservice
    attr_reader :read_only_username

    ### @return [String] read-only password as a SHA256 digest
    attr_reader :read_only_password_sha256

    ### @return [String] work group or domain for SMB
    attr_reader :workgroup_or_domain

    ### http(s) access

    ### @return [Boolean] are http downloads available from this DP?
    attr_reader :http_downloads_enabled

    ### @return [String] the protocol to use for http downloads (http/https)
    attr_reader :protocol

    ### @return [Integer] the port for http access
    attr_reader :port

    ### @return [String] the "context" for http downloads (what goes after the hostname part of the URL)
    attr_reader :context

    ### @return [Boolean] do http downloads work without auth?
    attr_reader :no_authentication_required

    ### @return [Boolean] do http downloads use cert. authentication?
    attr_reader :certificate_required

    ### @return [Boolean] do http downloads use user/pw auth?
    attr_reader :username_password_required

    ### @return [String] the username to use for http downloads if needed for user/pw auth
    attr_reader :http_username

    ### @return [String] the password for http downloads, if needed, as a SHA256 digest
    attr_reader :http_password_sha256

    ### @return [String] the name of the cert. used for http cert. auth.
    attr_reader :certificate

    ### @return [String] the URL for http downloads
    attr_reader :http_url

    ### @return [String] the URL to use if this one doesn't work
    attr_reader :failover_point_url

    ### ssh (scp, rsync, sftp) access

    ### @return [String] ssh username
    attr_reader :ssh_username

    ### @return [String] the ssh password as a SHA256 digest
    attr_reader :ssh_password_sha256

    ###
    ### As well as the standard :id, :name, and :data, you can
    ### instantiate this class with :id => :master, in which case you'll
    ### get the Master Distribution Point as defined in the JSS.
    ### An error will be raised if one hasn't been defined.
    ###
    ### You can also do this more easily by calling JSS.master_distribution_point
    ###
    def initialize(args = {})

      @init_data = nil

      ### looking for master?
      if args[:id] == :master

        self.class.all_ids.each do |id|
          @init_data  = JSS::API.get_rsrc("#{RSRC_BASE}/id/#{id}")[RSRC_OBJECT_KEY]
          if @init_data[:is_master]
            @id = @init_data[:id]
            @name = @init_data[:name]
            break
          end # if data is master
          @init_data = nil
        end # each id
      end # if args is master

      if @init_data.nil?
        super(args)
      end

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

      ### Note, as of Casper 9.3:
      ### :management_password_md5=>"xxxxx"
      ### and
      ### :management_password_sha256=> "xxxxxxxxxx"
      ### Are the read/write password
      ###
      ### An empty passwd is
      ### MD5 = d41d8cd98f00b204e9800998ecf8427e
      ### SHA256 = e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
      ###
      ### Seemms the read-only pw isn't available in the API


      ### if we mount for fileservice, where's the mountpoint?
      @mountpoint = Pathname.new "/Volumes/CasperDistribution-id-#{@id}"

    end #init

    ###
    ### Check the validity of a password.
    ###
    ### @param user[Symbol] one of :ro, :rw, :ssh, :http
    ###
    ### @param pw[String] the password to check for the given user
    ###
    ### @return [Boolean,Nil] was the password correct?
    ###   nil is returned if there is no password set in the JSS.
    ###
    def check_pw(user, pw)
      raise JSS::InvalidDataError, "The first parameter must be one of :ro, :rw, :ssh, :http" unless [:ro, :rw, :ssh, :http].include? user
      sha256 = case user
        when :rw then @read_write_password_sha256
        when :ro then @read_only_password_sha256
        when :http then @http_password_sha256
        when :ssh then @ssh_password_sha256
      end # case

      return nil if sha256 == EMPTY_PW_256

      sha256 == Digest::SHA2.new(256).update(pw).to_s
    end



    ###
    ### Mount this distribution point locally.
    ###
    ### @param pw[String,Symbol] the read-only or read-write password for this DistributionPoint
    ###   If :prompt, the user is promted on the commandline to enter the password for the :user.
    ###   If :stdin#, the password is read from a line of std in represented by the digit at #, 
    ###   so :stdin3 reads the passwd from the third line of standard input. defaults to line 2, 
    ###   if no digit is supplied. see {JSS.stdin}
    ###
    ### @param access[Symbol] how to mount the DistributionPoint, and which password to expect.
    ###  :ro = read-only, :rw (or anything else) = read-write
    ###
    ### @return [Pathname] the mountpoint.
    ###
    def mount(pw = nil, access = :ro1)
      return @mountpoint if mounted?
      access = :rw unless access == :ro
      
      password = if pw == :prompt
        JSS.prompt_for_password "Enter the password for the #{access} user '#{access == :ro ? @read_only_username : @read_write_username }':"
      elsif pw.is_a?(Symbol) and pw.to_s.start_with?('stdin')
        pw.to_s =~ /^stdin(\d+)$/
        line = $1
        line ||= 2
        JSS.stdin line
      else
        pw
      end
      
      pwok = check_pw(access, password)
      unless pwok
        msg = pwok.nil? ? "No #{access} password set in the JSS" : "Incorrect password for #{access} account"
        raise JSS::InvalidDataError, msg
      end

      username = access == :ro ? @read_only_username : @read_write_username

      safe_pw = URI.escape password, /[^a-zA-Z\d]/

      @mount_url = "#{@connection_type.downcase}://#{username}:#{safe_pw}@#{@ip_address}/#{@share_name}"
      @mnt_cmd = case @connection_type.downcase
        when 'smb' then '/sbin/mount_smbfs'
        when 'afp' then '/sbin/mount_afp'
        else raise "Can't mount distribution point #{@name}: no known connection type."
      end

      @mountpoint.mkpath

      #if system "#{@mnt_cmd} -o '#{MOUNT_OPTIONS}' '#{@mount_url}' '#{@mountpoint}'"
      if system @mnt_cmd.to_s, *['-o', MOUNT_OPTIONS, @mount_url, @mountpoint.to_s]
        @mounted = access
      else
        @mountpoint.rmdir if @mountpoint.directory?
        @mounted = nil
        raise JSS::FileServiceError, "There was a problem mounting #{@ip_address}"
      end
      return @mountpoint
    end # mount

    ###
    ### Unmount the distribution point.
    ###
    ### Does nothing if it wasn't mounted with #mount.
    ###
    ### @return [void]
    ###
    def unmount
      return nil unless mounted?
      if system "umount '#{@mountpoint}'"
        @mountpoint.rmdir if @mountpoint.directory? and (not @mountpoint.mountpoint?)
        @mounted = false
      else
        raise  JSS::FileServiceError ,"There was a problem unmounting #{@mountpoint}"
      end
      nil
    end # unmount
    

    ###
    ### Is this thing mounted right now?
    ###
    ### @return [Boolean]
    ###
    def mounted?
      @mountpoint.directory? and  @mountpoint.mountpoint?
    end
    
    
    #### aliases
    alias hostname ip_address
    alias umount unmount

    ######################################
    ### Private Instance Methods
    ######################################
    private

    ###
    ### Unused - until I get around to making DP's updatable
    ###
    ### the XML representation of the current state of this object,
    ### for POSTing or PUTting back to the JSS via the API
    ### Will be supported for Dist Points some day, I'm sure.
    ###
    def rest_xml
      doc = REXML::Document.new
      dp = doc.add_element "distribution_point"
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

      return doc.to_s
    end #rest_xml

  end # class
end # module
