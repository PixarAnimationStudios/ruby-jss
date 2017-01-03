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
  ### - api_ssl_version [String] the SSL version (from the open_ssl module) to use for the connection.
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

    ### The filename for storing the config, globally or user-level.
    ### The first matching file is used - the array provides
    ### backward compatibility with earlier versions.
    ### Saving will always happen to the first filename
    CONF_FILES = [ "ruby-jss.conf", "jss_gem.conf"]

    ### The Pathname to the machine-wide preferences plist
    GLOBAL_CONFS =  CONF_FILES.map{|cf| Pathname.new "/etc/#{cf}"}

    ### The Pathname to the user-specific preferences plist
    USER_CONFS =  CONF_FILES.map{|cf| ENV["HOME"] ? Pathname.new("~/.#{cf}").expand_path : nil }.compact

    ### The attribute keys we maintain, and the type they should be stored as
    CONF_KEYS = {
      :api_server_name => :to_s,
      :api_server_port => :to_i,
      :api_ssl_version => :to_s,
      :api_verify_cert => :jss_to_bool,
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
      GLOBAL_CONFS.each { |gcf|
        if gcf.file? and gcf.readable?
          read gcf
          return
        end
      }
    end

    ###
    ### (Re)read the user prefs, if it exists.
    ###
    ### @return [void]
    ###
    def read_user
      USER_CONFS.each { |ucf|
        if ucf.file? and ucf.readable?
          read ucf
          return
        end
      }
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
        when :global then GLOBAL_CONFS.first
        when :user then USER_CONFS.first
        else Pathname.new(file)
      end

      raise JSS::MissingDataError, "No HOME environment variable, can't write to user conf file." if path.nil?

      # file already exists? read it in and update the values.
      if path.readable?
        data = path.read

        # go thru the known attributes/keys
        CONF_KEYS.keys.sort.each do |k|

          # if the key exists, update it.
          if data =~ /^#{k}:/
            data.sub!(/^#{k}:.*$/, "#{k}: #{self.send k}")

          # if not, add it to the end unless it's nil
          else
            data += "\n#{k}: #{self.send k}" unless self.send(k).nil?
          end # if data =~ /^#{k}:/
        end #each do |k|

      else # not readable, make a new file
        data = ""
        CONF_KEYS.keys.sort.each do |k|
          data << "#{k}: #{self.send k}\n" unless self.send(k).nil?
        end
      end # if path readable

      # make sure we end with a newline, the save it.
      data << "\n" unless data.end_with?("\n")
      path.jss_save data
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
