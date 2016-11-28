### Copyright 2016 Pixar
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

module JSSWebHooks

  # The configuration object
  class Configuration

    include Singleton

    # The location of the default config file
    DEFAULT_CONF_FILE = Pathname.new '/etc/jsswebhooks.conf'

    ### The attribute keys we maintain, and the type they should be stored as
    CONF_KEYS = {
      server_port: :to_i,
      server_engine:  :to_sym,
      handler_dir: :to_s,
      handler_computer_added: :to_s,
      handler_computer_check_in: :to_s,
      handler_computer_inventory_completed: :to_s,
      handler_computer_policy_finished: :to_s,
      handler_computer_push_capability_changed: :to_s,
      handler_jss_shutdown: :to_s,
      handler_jss_startup: :to_s,
      handler_mobile_device_check_in: :to_s,
      handler_mobile_device_command_complete: :to_s,
      handler_mobile_device_enrolled: :to_s,
      handler_mobile_device_push_sent: :to_s,
      handler_mobile_device_unenrolled: :to_s,
      handler_patch_software_title_updated: :to_s,
      handler_push_sent: :to_s,
      handler_rest_api_operation: :to_s,
      handler_scep_challenge: :to_s,
      handler_smart_group_computer_membership_change: :to_s,
      handler_smart_group_mobile_device_membership_change: :to_s
    }.freeze

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
    CONF_KEYS.keys.each { |k| attr_accessor k }

    #####################################
    ### Constructor
    #####################################

    ###
    ### Initialize!
    ###
    def initialize
      read_global
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
      CONF_KEYS.keys.each { |k| send "#{k}=".to_sym, nil }
    end

    ###
    ### (Re)read the global prefs, if it exists.
    ###
    ### @return [Boolean] was the file loaded?
    ###
    def read_global
      return false unless DEFAULT_CONF_FILE.file? && DEFAULT_CONF_FILE.readable?
      read DEFAULT_CONF_FILE
    end

    ###
    ### Clear the settings and reload the prefs file, or another file if provided
    ###
    ### @param file[String,Pathname] a non-standard prefs file to load
    ###
    ### @return [Boolean] was the file reloaded?
    ###
    def reload(file = DEFAULT_CONF_FILE)
      file = Pathname.new file
      return false unless file.file? and file.readable?
      clear_all
      read file
    end

    ###
    ### Save the prefs into a file
    ###
    ### @param file[Symbol,String,Pathname] either :user, :global, or an arbitrary file to save.
    ###
    ### @return [void]
    ###
    def save(file)
      path = Pathname.new(file)

      # file already exists? read it in and update the values.
      # Don't overwrite it, since the user might have comments
      # in there.
      if path.readable?
        data = path.read

        # go thru the known attributes/keys
        CONF_KEYS.keys.sort.each do |k|
          # if the key exists, update it.
          if data =~ /^#{k}:/
            data.sub!(/^#{k}:.*$/, "#{k}: #{send k}")

          # if not, add it to the end unless it's nil
          else
            data += "\n#{k}: #{send k}" unless send(k).nil?
          end # if data =~ /^#{k}:/
        end # each do |k|

      else # not readable, make a new file
        data = ''
        CONF_KEYS.keys.sort.each do |k|
          data << "#{k}: #{send k}\n" unless send(k).nil?
        end
      end # if path readable

      # make sure we end with a newline, the save it.
      data << "\n" unless data.end_with?("\n")
      path.jss_save data
    end # save file

    ###
    ### Print out the current settings to stdout
    ###
    ### @return [void]
    ###
    def print
      CONF_KEYS.keys.sort.each { |k| puts "#{k}: #{send k}" }
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
    ### @return [Boolean] was the file read?
    ###
    def read(file)
      available_conf_keys = CONF_KEYS.keys
      Pathname.new(file).read.each_line do |line|
        # skip blank lines and those starting with #
        next if line =~ /^\s*(#|$)/

        line.strip =~ /^(\w+?):\s*(\S.*)$/
        key = Regexp.last_match(1)
        next unless key
        attr = key.to_sym
        setter = "#{key}=".to_sym
        value = Regexp.last_match(2).strip

        next unless available_conf_keys.include? attr

        # convert the value to the correct class
        value = value.send(CONF_KEYS[attr]) if value

        send(setter, value)
      end # do line
      true
    end # read file

  end # class Configuration

  # The single instance of Configuration
  CONFIG = JSSWebHooks::Configuration.instance

end # module
