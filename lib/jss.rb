# = pixjss.rb
#
# Author::    Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2012 Pixar Animation Studios
#
# PixJSS, A Ruby module containing common classes, values, and methods
# for interacting with Pixar's JSS database.
#
# To use these items in your script, add this line to the top:
#  require 'pixar/jss' 
#
# General notes:
#
#   * While the indexed unique ID of each pkg in the JSS is the numeric package_id field
#   and each one also has a package_name field, we will use the file_name field as the human-readable
#   name for each pkg. Why? 
#   1) name and file_name usually match anyway
#   2) they aren't guaranteed to match
#   3) the file_name is *almost* guaranteed to be unique since the installer pkgs live in the same folder on the server
#   4) d3 cares a lot about filenames, for receipts, for installing pilots, etc...

#####################################
# Required Libraries, etc
#####################################

###################
# Pixar Libraries
# Note that pixar/pixar requires rubygems and adds the
# pixar gem folder to Gem.path
require 'pixar/pixar'

###################
# Gems - if you haven't required pixar/pixar above
# uncomment the next line:
# require 'rubygems' ; Gem.path.unshift "/Library/Ruby/Site/1.8/pixar/gems"
#gem 'mysql' , :version => '=2.9.3'
require 'mysql'
require 'rest-client'
require 'json'

###################
# Standard Libraries
require 'date'
require 'singleton'
require 'pathname'
require 'fileutils'
require 'uri'
require 'cgi'


###################
# Our classes and submodules
$LOAD_PATH << File.dirname(__FILE__)

# first load the site settings
require "jss/site_settings.rb"

# then all the standard module files
require 'jss/db_connection'
require 'jss/rest_connection'
require 'jss/computer'
require 'jss/computer_group'
require 'jss/net_segment'
require 'jss/script'
require 'jss/package'
require 'jss/extension_attribute'
require 'jss/peripheral'

# then all the other customizations
Dir[File.dirname(__FILE__) + '/jss/site_*.rb'].each {|file| require file unless file.end_with? "site_settings.rb"}


### 
### PixJSS - The primary module for interacting w/ the JSS. <br>
### This defines Classes and Methods for access
### to data stored in the JSS database and on it's file server.
###
module PixJSS
  extend self
  
  #####################################
  # Constants
  #####################################
  
  ###
  ### Server access
  ###
  
  # if this code is running ON the server, some behavior must be different.
  THIS_IS_THE_SERVER = (`/bin/hostname`.chomp == JSS_HOST and Pathname.new("/Library/JSS/Tomcat/").directory?)
  
  ###
  ### Paths & Executables
  ###
  
  # the jamf binary, for installing pkgs, running scripts, running recons, etc
  JAMF_BINARY = Pathname.new "/usr/sbin/jamf"
  
  # Jamf App Spt folder
  JAMF_SPPT_DIR = Pathname.new "/Library/Application Support/JAMF"
  
  # jamf receipts
  JAMF_RCPTS_DIR = JAMF_SPPT_DIR + "Receipts"
  
  ###
  ### JSS general values
  ###
  
  # The possible values for the "stage" of a pkg or script in the JSS
  STAGES = ["Deployable", "Non-Deployable", "Testing", "Deleted"]
  
  # The possible values for cpu_type (required_processor) in a JSS package
  CPU_TYPES = ["None", "x86", "PowerPC"]
  
  # The possible values for priority in a JSS script
  SCRIPT_PRIORITIES = ["Before", "After"]
  
  # The resrouce to look up via REST for the purposes of authenticating
  # as a JSS user
  REST_AUTH_RSRC = "jsssummary"
  
  #####################################
  # Module Variables
  #####################################
  
  # the password for the mgmt acct defined as a constant above.
  # see the get_mgmt_pw module method for getting it from the user
  @@mgmt_pw=nil
  
  # Are we currently connected to the jss?
  @@connected = false
  
  # a hash with one item per category in the JSS
  # The keys are category names, values are JSS id's as ints.
  # populated by the categories method, q.v.
  @@categories = nil
  
  # an array with one item per removable mac address in the JSS
  @@removable_mac_addrs = nil
  
  # a hash of all JSSNetSegment objects in the JSS
  # keyed off their network identifiers (startingIP/CIDR)
  @@net_segments = nil
  
  # was the CasperShare volume NFS mounted by this ruby program?
  # if so, it's safe to unmount it when we're done with it
  # otherwise, leave it be.
  @@i_mounted_cshare = false
  
  # If the user authenticates to the JSS, we'll save the pw for use with sudo
  @@sudopw = nil
  
  #####################################
  # Exceptions
  #####################################
  
  ### 
  ### MissingDataError - raise this error when we 
  ### are missing args, or other simliar stuff.
  ### 
  class MissingDataError < RuntimeError; end
  
  ### 
  ### InvalidConnectionError - raise this error when we 
  ### don't have a usable connection to a network service, or
  ### don't have proper authentication/authorization.
  ### 
  class InvalidConnectionError < RuntimeError; end
  
  ### 
  ### NoSuchItemError - raise this error when 
  ### a desired item doesn't exist.
  ### 
  class NoSuchItemError < RuntimeError; end
  
  ### 
  ### InvalidTypeError - raise this error when 
  ### a data item isn't what we expected.
  ### 
  class InvalidTypeError < RuntimeError; end
  
  ### 
  ### AlreadyExistsError - raise this error when 
  ### trying to create something that already exists.
  ### 
  class AlreadyExistsError < RuntimeError; end
  
  ### 
  ### FileServiceError - raise this error when 
  ### there's a problem accessing file service on the 
  ### Casper server
  ### 
  class FileServiceError < RuntimeError; end

  #####################################
  # PixJSS Module Methods
  #####################################
  
  ###
  ### raise an error if there's no connection to the jss
  ###
  def check_connection
    raise InvalidConnectionError , "Not connected. Use PixJSS.connect or PixJSS.authenticate first." unless @@connected
  end

  ###
  ### Return a hash with one item per policy in the JSS
  ### The keys of this hash, :name & :id, are the policy names, and the values are the JSS id's for
  ### the policy.
  ###
  def policies
    check_connection
    REST_CNX.get_rsrc('policies')[:policies][:policy]
  end
  
  ###
  ### return an array of just the names of all jss polices
  ###
  def policy_names
    names = []
    policies.each { |pol| names.push pol[:name] }
    names
  end
  
  ###
  ### return a hash with one item per category in the JSS
  ### The keys are category names, values are JSS id's as ints.
  ###
  def categories (refresh = nil)
    @@categories = nil if refresh
    return @@categories if @@categories
    
    @@categories = {}
    check_connection
    
    REST_CNX.get_rsrc('categories')[:categories][:category].each do |cat|
      @@categories[cat[:name]] = cat[:id] 
    end ### do cat
    @@categories 
  end

  ###
  ### return a hash of all JSSNetSegment objects in the JSS
  ### keyed off their network identifiers (startingIP/CIDR)
  ###
  def net_segments(refresh = nil)
    @@net_segments = nil if refresh
    return @@net_segments if @@net_segments
    
    @@net_segments = {}
    check_connection
    
    rest_segments = REST_CNX.get_rsrc('networksegments')[:network_segments][:network_segment]
    rest_segments = [] if rest_segments.nil? or rest_segments.empty?
    rest_segments.each do |ns|
      this_seg = JSSNetSegment.new :jss_id => ns[:id]
      @@net_segments[this_seg.identifier] = this_seg
    end
    @@net_segments 
  end # def net_segments
  
  
  ###
  ### Return an array  of all removable mac addrs in the jss
  ###
  def removable_mac_addrs(refresh = false)
    @@removable_mac_addrs = nil if refresh
    return @@removable_mac_addrs if @@removable_mac_addrs
    
    @@removable_mac_addrs = []
    check_connection
    theQuery = "SELECT removable_mac_address FROM #{REMOVABLE_MACADDR_TABLE}"
    @@db_cnx.query(theQuery).each {|rma| @@removable_mac_addrs << rma[0] }
    @@removable_mac_addrs
  end # 
  
  ###
  ### Add a new removable mac addrs to the jss
  ###
  def add_removable_mac_addr(new_addr)
    
    # check that the new addr is good
    # delimiter must be : or .
    raise InvalidTypeError, "Improper format for MACaddr: xx:xx:xx:xx:xx:xx. Delimiters must be : or ." unless new_addr =~ /^([0-9a-f]{2}([:.]|$)){6}$/i
    
    # convert delimiters to dots, and lowercase the letters
    new_addr.gsub!(":", ".").downcase!
    
    # skip if it's already there
    return true if removable_mac_addrs(:refresh).include? new_addr
    theStmt = @@db_cnx.prepare "INSERT INTO #{REMOVABLE_MACADDR_TABLE} (removable_mac_address) VALUES ('#{Mysql.quote new_addr}')"
    stmt_result = theStmt.execute
    @@removable_mac_addrs << new_addr
    return true
  end #


  ###
  ### Clean up a hash of data from the db - it all comes back as strings :-(
  ### For now this is only for scripts and pkgs.
  ### so type is only :pkg or :script
  ###
  def clean_jss_db_data(db_data, type)
    
    case type
      when :pkg then
        db_data[JMAP[:id]] = db_data[JMAP[:id]].to_i
        
        db_data[JMAP[:feu]] = db_data[JMAP[:feu]].to_i == 1 ? true : false
        
        db_data[JMAP[:reboot]] = db_data[JMAP[:reboot]].to_i == 1 ? true : false
        
        db_data[JMAP[:oses]] = db_data[JMAP[:oses]].nil? ? [] : db_data[JMAP[:oses]].split(/,\s*/)
        
        db_data[JMAP[:cpu_type]] = db_data[JMAP[:cpu_type]] == "None" ? nil : db_data[JMAP[:cpu_type]]
        
        db_data[JMAP[:removable]] = db_data[JMAP[:removable]].to_i == 1 ? true : false
        
        db_data[JMAP[:notes]].gsub!("\r", "\n") if db_data[JMAP[:notes]]
        
        db_data[:category] = categories.index db_data[JMAP[:cat_id]].to_i
      
      when :script then
        db_data[SMAP[:id]] = db_data[SMAP[:id]].to_i
        
        db_data[SMAP[:oses]] = db_data[SMAP[:oses]].nil? ? [] : db_data[SMAP[:oses]].split(/,\s*/)
        
        db_data[:category] = categories.index db_data[SMAP[:cat_id]].to_i
    end # case type
    
    # turn all empty strings to nils
    db_data.delete_if {|k, v| v == '' }
    
    return db_data
  end # clean db data
  
  
  ###
  ### Mount the CasperShare volume via NFS
  ### or just return if it's already 
  ### While some methods in this module may mount the CasperShare
  ### (e.g. to change the name of a file)
  ### It's the responsibility of the calling script to unmount it 
  ### when no longer needed.  See the umount_caspershare method.
  ###
  def mount_caspershare(user = nil, pw = nil)
    
    # if the Pkgs folder is already visible, just return   
    return true if  (CASPERSHARE_MNTPNT + CSHARE_PKGS).directory?
    
    # if we're on the server, just make a symlink from caspershare mntpoint to the realone.
    if THIS_IS_THE_SERVER
      
      File.symlink "/Volumes/CasperData/CasperShare/", CASPERSHARE_MNTPNT
      @@i_mounted_cshare = true
      return true
    end
    
    # if we were given a user/pw, use AFP to mount
    # as that user. Otherwise, use NFS for passwordless read-only access
    # this will avoid the 16 group problem for d3 admins.
    if user
      
      raise MissingDataError, "Missing password for mounting CasperShare" unless pw
      
      # is the casper server already mounted via AFP? if so, it'll need to be unmounted.
      raise FileServiceError, "Please unmount your AFP connection to the casper server." if `/bin/df`.lines.grep(%r{^(afp|//).*/Volumes/Casper(Share|Data)\n?$}).count > 0
      
      protocol = "afp"
      
      # for some reason, URIescape isn't catching @s properly
      encpw = URI.escape(pw.to_s).gsub(/@/, "%40")
      src = "afp://#{user}:#{encpw}@#{JSS_HOST}/#{CSHARE}/"
    else
      protocol = "nfs"
      src = "#{JSS_HOST}:#{CSHARE_SVR_PATH}"
    end
    
    # mount it, remembering that we did so, so we can unmount it later.
    CASPERSHARE_MNTPNT.mkpath   
   
    if system "/sbin/mount_#{protocol} -o nobrowse '#{src}' '#{CASPERSHARE_MNTPNT}'"
      @@i_mounted_cshare = true
      return true
    else
      addendum = user ? "(bad pw? manually mounted?)" : ""
      raise FileServiceError, "There was a problem mounting CasperShare at '#{CASPERSHARE_MNTPNT}' #{addendum}"
      return false
    end 
  end # mount_cshare_nfs
  
  
  ###
  ### Unmount the CasperShare volume via NFS
  ### but only if it was mounted by this script.
  ###
  def unmount_caspershare
    
    return true unless @@i_mounted_cshare
    
    # if we're on the server, just remove the symlink from caspershare mntpoint to the real one.
    if THIS_IS_THE_SERVER
      File.delete CASPERSHARE_MNTPNT
    else
      system "/sbin/umount  '#{CASPERSHARE_MNTPNT}'"
    end
    
    @@i_mounted_cshare = false
    return true
  end # mount_cshare_nfs
  alias umount_caspershare unmount_caspershare
  
  
 
  ###
  ### Authenticate to the JSS and if successfull 
  ### set @@rest_cnx and @@db_cnx to use the credentials provided
  ### 
  ### Needs :pw
  ### :user defaults to ENV['USER'] if not provided
  ### :rest_timeout and :rest_open_timeout (optional) are integers representing seconds
  ### :rest_server and :rest_port for using a non-standard server/port for JSS REST
  ### :db_server for a nonstd mysql server
  def authenticate(args = {})
      
      args[:user] ||= ENV['USER']
      
      raise MissingDataError, "Missing :pw" unless args[:pw]

      # make a new rest connection using the args
      REST_CNX.connect :server => args[:rest_server], :port => args[:rest_port], :user => args[:user], :pw => args[:pw], :timeout => args[:rest_timeout], :open_timeout => args[:rest_open_timeout]

      @@rest_cnx = RESTConnection.instance
      
      # try to use the credentials to read a simple resource
      begin
        REST_CNX.get_rsrc REST_AUTH_RSRC
      rescue
        # reset the rest connection to the standard read-only access
        REST_CNX.connect
        # complain
        raise NoSuchItemError, "Incorrect passwd for user #{args[:user]}."
      end
      
      # Remember the good pw for use with sudo if needed
      @@sudopw = args[:pw]
      
      # now that we have rest access, we should be able to see the auth data for the mysql connection
      # mount_caspershare(args[:user], args[:pw])
      
      # raise MissingDataError, "Can't read the mysql access credentials from the server." unless DB_RW_AUTH_PATH.exist?
      
      # grab the auth data for the mysql connection
      begin
        dbuser = "d3admin"
        dbpw = PixJSS.pixar_jss[dbuser]
        
        # (dbuser,dbpw) = IO.read(DB_RW_AUTH_PATH).strip.split(/:\s*/)
      rescue
        raise MissingDataError, "Can't read the mysql access credentials from the REST API" unless dbuser and dbpw
      end
      # make the db connection using it
      @@db_cnx = DB_CNX.connect :user => dbuser, :pw => dbpw, :server => args[:db_server]
      
      @@connected = true
  end #jss_auth

  
  ###
  ### jss_connect - connect to the JSS using the default read-only connections
  ### :rest_timeout and :rest_open_timeout (optional) are integers representing seconds
  ### :rest_server and :rest_port for using a non-standard server/port for JSS REST
  ### :db_server for a nonstd mysql server
  ### 
  def connect(args={})
      @@db_cnx = DB_CNX.connect :server => args[:db_server]
      REST_CNX.connect :server => args[:rest_server], :port => args[:rest_port], :timeout => args[:rest_timeout], :open_timeout => args[:rest_open_timeout]
      @@rest_cnx = RESTConnection.instance
      @@connected = true
  end


  ###
  ### Close any open mysql connection 
  ### and reset the auth credentials to the rest api
  ### 
  ### After doing this, they'll need to be re-established
  ### either with jss_authenticate, or 
  ### each directly with the appropriate connect methods.
  ###
  def disconnect
    @@db_cnx = DB_CNX.disconnect
    @@rest_cnx = REST_CNX.disconnect
    @@connected = false
  end #jss_disconnect

  ###
  ### (Re)Set the timeouts for the rest connection
  ###
  def rest_timeout=(timeout)
    REST_CNX.cnx.options[:timeout] = timeout
  end
  
  def rest_open_timeout=(timeout)
    REST_CNX.cnx.options[:open_timeout] = timeout
  end
  
  
  ###
  ### several things need to be run as root w/sudo
  ### if the user has authenticated then the pw has been retained for sudo use
  ### This just runs the given command as root and returns its output a la ``
  ###
  def sudo_run(the_command = nil)
    return nil if the_command.nil?
    raise MissingDataError, "Please authenticate to the JSS first by calling PixJSS.authenticate" unless @@sudopw
    
    quoted_pw = "'#{@@sudopw.gsub "'", "'\\\\''"}'"
    
    `echo #{quoted_pw} | sudo -S -p '' #{the_command}`
  end # sudo_run
  
  ###
  ### when making a computer in the JSS managed, we need the passwd
  ### for the MGMT_ACCT. This gets it from the user, if it isn't already set.
  ### If your code can't deal with prompting a user, make sure @@mgmt_pw is
  ### already set shortly after including this module.
  ### WARNING: this passwd isn't checked other than being entered twice.
  ###
  def set_mgmt_pw(newpw = nil)
    # if one was provided, use it
    @@mgmt_pw = newpw if newpw
    
    # if its already set, use what we have
    return unless @@mgmt_pw.nil?
    
    # if not already set, ask for it.
    begin
      system "stty -echo"
      they_match = false
      
      until they_match 
        puts "Password needed for JSS management account."
        print "Please enter the password for #{MGMT_ACCT}: "
        pw1= gets.chomp
        puts
        print "Please enter it again to avoid typos: "
        pw2= gets.chomp
        puts
        they_match = (pw1 == pw2)
        they_match or puts "Sorry, they don't match, please try again."
      end # until they match
      
      @@mgmt_pw = pw1
      
    ensure
      system "stty echo"
    end

  end # set mgmt pw
  
  ###
  ### return the current mgmt passwd, or raise an error if unset
  ###
  def mgmt_pw
    raise NoSuchItemError unless @@mgmt_pw
    @@mgmt_pw
  end
  
  ###
  ### run_recon - run the 'jamf recon' command to update the JSS
  ### with info about this computer.
  ### returning the exit status of the recon
  ###
  ### opts, if provided, is a string of valid options to the recon 
  ### command (see "/usr/sbin/jamf help recon")
  ### If no opts are provided, and the most recent values
  ### derived from LDAP are used.
  ###
  def run_recon (opts = nil, verbose = true)
      redirect = verbose ? "" : "&>/dev/null"
      opts = PIXAR_RECON_OPTS.read if opts.nil? and PIXAR_RECON_OPTS.exist?
      system "#{JAMF_BINARY} recon #{opts} #{redirect}"
      $?.exitstatus
  end # run Recon
  
  ###
  ### given either a comma-seprated string or an array of strings, 
  ### return a hash of both with the same data
  ###
  ### E.g given: "foo, bar, baz" -or- ["foo", "bar", "baz"]
  ### return:  {:stringform => "foo, bar, baz", :arrayform => ["foo", "bar", "baz"]}
  ###
  def to_s_and_a (somedata)
    if somedata.class == String
      valstr = somedata
      valarr = somedata.split(/,\s*/)
    elsif somedata.class == Array
      valstr = somedata.join ", "
      valarr = somedata
    else
      return "type error" # return this simple string so the caller can raise an informative error.
    end #if
    return { :stringform => valstr, :arrayform => valarr }
  end # to_s_and_a
  
end # module PixJSS


