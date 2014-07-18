module JSS

### A class representing a JSS Client Mac where this code is running, 
### and various JAMF-related aspects of it
###


  
  #####################################
  ### Module Variables
  #####################################
 
  #####################################
  ### Module Methods
  #####################################
  
  #####################################
  ### Classes
  #####################################
  
  ###
  ### This class represents a Casper/JSS Client computer, on which 
  ### this code is running.
  ###
  ### At the moment, only Macintosh computers are supported.
  ###
  class Client
    
    #####################################
    ### Class Constants
    #####################################
    
    ### The Pathname to the jamf binary executable
    JAMF_BINARY = Pathname.new "/usr/sbin/jamf"
    
    ### The Pathname to the preferences plist used by the jamf binary
    JAMF_PLIST = Pathname.new "/Library/Preferences/com.jamfsoftware.jamf.plist"
    
    ### The Pathname to the JAMF support folder
    JAMF_SUPPORT_FOLDER = Pathname.new "/Library/Application Support/JAMF"
    
    ### The JAMF receipts folder, where package installs are tracked.
    RECEIPTS_FOLDER = JAMF_SUPPORT_FOLDER + "Receipts"
    
    #####################################
    ### Class Variables
    #####################################
    
    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Attributes
    #####################################
    
    ### Boolean - is the jamf binary installed?
    attr_reader :installed
    alias  installed? installed
    
    ### String - the version of the jamf binary installed on this client
    attr_reader :jamf_version
    
    ### String - the url to the JSS for this client
    attr_reader :jss_url
    
    ### String - the JSS server for this client
    attr_reader :jss_server
    
    ### String - the protocol to the JSS for this client, "http" or "https"
    attr_reader :jss_protocol
    
    ### Integer - the port to the JSS for this client
    attr_reader :jss_port
    
    #####################################
    ### Instance Methods
    #####################################
    
    ###
    ### Initialize!
    ###
    def initialize
      @installed = JAMF_BINARY.executable?
      @jamf_version = @installed ?  run_jamf(:version).chomp.split('=')[1] : nil
      @plist_details = `/usr/libexec/PlistBuddy -c print '#{JAMF_PLIST}'`
      @plist_details =~ %r{\sjss_url\s*=\s*(htt.*)(\s|$)}
      @jss_url = $1
      @jss_url =~ %r{(https?)://(.+):(\d+)/}
      @jss_protocol = $1
      @jss_server = $2
      @jss_port = $3 ? $3.to_i : 80
    end
    
    ###
    ### @return [Array] an array of Pathnames for all regular files in the jamf receipts folder
    ###
    def receipts
      raise JSS::NoSuchItemError, "The JAMF Receipts folder doesn't exist on this computer." unless RECEIPTS_FOLDER.exist?
      RECEIPTS_FOLDER.children.select{|c| c.file?}
    end
    
    ###
    ### @return [true,false] is the JSS available now?
    ###
    def jss_available?
      output = run_jamf :checkJSSConnection, "-retry 1"
      $?.exitstatus == 0
    end
    
    ###
    ### Run an arbitrary jamf command.
    ###
    ### @param command[String,Symbol] the jamf binary command to run
    ###   The command is the single jamf command that comes after the/usr/bin/jamf. 
    ###
    ### @param args[String,Array] the arguments passed to the jamf command.
    ###   This is to be passed to Kernel.` (backtick), after being combined with the 
    ###   jamf binary and the jamf command
    ###
    ### @return [String] the stdout of the jamf binary.
    ###
    ### @example
    ###   These two are equivalent:
    ###
    ###     JSS::Client.new.run_jamf "recon", "-assetTag 12345 -department 'IT Support'"
    ###
    ###     JSS::Client.new.run_jamf :recon, ['-assetTag', '12345', '-department', 'IT Support'"]
    ###
    ### 
    ### This method does not redirect stderr from the jamf command.
    ### 
    ### The details of the Process::Status can be captured from $?
    ### immediately after calling.  (See Process::Status)
    ###
    def run_jamf(command, args = nil)
      raise JSS::UnmanagedError, "The jamf binary is not installed on this computer." unless @installed
      case args
        when nil
          `#{JAMF_BINARY} #{command}`
        when String
          `#{JAMF_BINARY} #{command} #{args}`
        when Array
          `#{([JAMF_BINARY.to_s, command] + args).join(' ')}`
        else
          raise JSS::InvalidDataError, "args must be a String or Array of Strings"
      end # case
    end # run_jamf
    
  end # class Client
  
end # module
