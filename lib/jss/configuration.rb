module JSS


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
  ### A class for working with pre-defined settings & preferences for the JSS Gem
  ###
  ### This is a singleton class, only one instance can exist at a time.
  ###
  ### When the JSS module loads, that instance is created and stored in the constant {JSS::CONFIG},
  ### which can then be used in applications to avoid always having to pass in server names, API user names
  ### and so on.
  ###
  ### When the JSS::Configuration instance is created, the {GLOBAL_CONF} file (/etc/jss_gem.conf) is examined if it exists, and
  ### the items in it are loaded into the attributes.
  ###
  ### Then the user-specific {USER_CONF} file (~/.jss_gem.conf) is examined if it exists, and any attributes defined there will
  ### override those values from the {GLOBAL_CONF}.
  ###
  ### The file format is one attribute per line, thus:
  ###   attr_name: value
  ###
  ### Lines that don't start with a known attribute name followed by a colon are ignored. If an attribute is defined
  ### more than once, the last one wins.
  ###
  ### The known attributes are:
  ### - api_server_name [String] the hostname of the JSS API server
  ### - api_server_port [Integer] the port number for the API connection
  ### - api_verify_cert [Boolean] if SSL is used, should the SSL certificate be verified (usually false for a self-signed cert)
  ### - api_username [String] the JSS username for connecting to the API
  ### - api_timeout_open [Integer] the number of seconds for the open-connection timeout
  ### - api_timeout [Integer] the number of seconds for the response timeout
  ###
  ### The {APIConnection#connect} method will first use any values given as method arguments. For any not given, it will
  ### look at the Preferences instance for any values there, and if still none, will use default values or raise an exception.
  ###
  ### At any point, the attributes can read or changed using standard Ruby getter/setter methods matching the name of the attribute,
  ### e.g.
  ###   JSS::CONFIG.api_server_name  # => 'myjss.mycompany.com'
  ###   JSS::CONFIG.api_server_name = 'otherjss.mycompany.com'  # sets the api_server_name to a new value
  ###
  ###
  ### The current settings may be saved to the GLOBAL_CONF file, the USER_CONF file, or an arbitrary file using {#save}.
  ### The argument to {#save} should be either :user, :global, or a String or Pathname file path.
  ### NOTE: This overwrites any existing file.
  ###
  ### To re-load the settings use {#reload}. This clears the current settings, and re-reads both the global and user files.
  ### If a pathname is provided, e.g.
  ###   JSS::CONFIG.reload '/path/to/other/file'
  ### the current settings are cleared and reloaded from that other file.
  ###
  ### To view the current settings, use {#print}.
  ###
  ### @note Passwords are not saved in prefs files. Your application will have to acquire them using the :prompt or :stdin options to
  ###   {APIConnection#connect}, or by custom means.
  ###
  class Configuration
    include Singleton

    #####################################
    ### Class Constants
    #####################################

    ### The filename for storing the prefs, globally or user-level
    CONF_FILE = "jss_gem.conf"

    ### The Pathname to the machine-wide preferences plist
    GLOBAL_CONF = Pathname.new "/etc/#{CONF_FILE}"

    ### The Pathname to the user-specific preferences plist
    USER_CONF = Pathname.new("~/.#{CONF_FILE}").expand_path

    ### Put this above the attributes, below the comments when saving files.
    COMMENT_WARNING = "#--- Comments below here will be moved above when saved with JSS::CONFIG.save ---\n"

    ### The attribute keys we maintain, and the type they should be stored as
    CONF_KEYS = {
      :api_server_name => :to_s,
      :api_server_port => :to_i,
      :api_verify_cert => :to_bool,
      :api_username => :to_s,
      :api_timeout_open => :to_i,
      :api_timeout => :to_i,
      :db_server_name => :to_s,
      :db_server_port => :to_i,
      :db_server_socket => :to_s,
      :db_username => :to_s,
      :db_name => :to_s,
      :db_connect_timeout => :to_i,
      :db_read_timeout => :to_i,
      :db_write_timeout => :to_i
    }

    #####################################
    ### Class Variables
    #####################################

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Attributes
    #####################################

    # automatically create accessors for all the CONF_KEYS
    CONF_KEYS.keys.each {|k| attr_accessor k}


    #####################################
    ### Constructor
    #####################################

    ###
    ### Initialize!
    ###
    def initialize

      read_global
      read_user

    end

    #####################################
    ### Public Instance Methods
    #####################################

    ###
    ### Clear all values
    ###
    ### @return [void]
    ###
    def clear_all
      CONF_KEYS.keys.each {|k| self.send "#{k}=".to_sym, nil}
    end

    ###
    ### (Re)read the global prefs, if it exists.
    ###
    ### @return [void]
    ###
    def read_global
      read GLOBAL_CONF if GLOBAL_CONF.file? and GLOBAL_CONF.readable?
    end

    ###
    ### (Re)read the user prefs, if it exists.
    ###
    ### @return [void]
    ###
    def read_user
      read USER_CONF if USER_CONF.file? and USER_CONF.readable?
    end


    ###
    ### Clear the settings and reload the prefs files, or another file if provided
    ###
    ### @param file[String,Pathname] a non-standard prefs file to load
    ###
    ### @return [void]
    ###
    def reload(file = nil)
      clear_all
      if file
        read file
        return true
      end
      read_global
      read_user
      return true
    end


    ###
    ### Save the prefs into a file
    ###
    ### @param file[Symbol,String,Pathname] either :user, :global, or an arbitrary file to save.
    ###
    ### @return [void]
    ###
    def save(file)
      path = case file
        when :global then GLOBAL_CONF
        when :user then USER_CONF
        else Pathname.new(file)
      end

      # if the file exists and has any comment lines
      # extract them and put them back at the top of the new file.
      data = ""
      if path.readable?
        path.read.each_line do |line|
          next if line == COMMENT_WARNING
          data << line if line =~ /^\s*(#|$)/
        end
      end
      data << COMMENT_WARNING

      CONF_KEYS.keys.sort.each{|k| data << "#{k}: #{self.send k}\n"}
      path.save data
    end # read file


    ###
    ### Print out the current settings to stdout
    ###
    ### @return [void]
    ###
    def print
      CONF_KEYS.keys.sort.each{|k| puts "#{k}: #{self.send k}"}
    end

    #####################################
    ### Private Instance Methods
    #####################################
    private

    ###
    ### Read in any prefs file
    ###
    ### @param file[String,Pathname] the file to read
    ###
    ### @return [void]
    ###
    def read(file)

      Pathname.new(file).read.each_line do |line|
          # skip blank lines and those starting with #
          next if line =~ /^\s*(#|$)/

          line.strip =~ /^(\w+?):\s*(\S.*)$/
          next unless $1
          attr = $1.to_sym
          setter = "#{attr}=".to_sym
          value = $2.strip

          if CONF_KEYS.keys.include? attr
            if value
              # convert the value to the correct class
              value = value.send(CONF_KEYS[attr])
            end
            self.send(setter, value)
          end  # if
        end # do line

    end # read file

  end # class Preferences

  # The single instance of Configuration
  CONFIG = JSS::Configuration.instance

end # module
