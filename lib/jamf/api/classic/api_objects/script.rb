# Copyright 2022 Pixar

#
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

#
module Jamf

  # Module Constants
  #####################################

  # Module Variables
  #####################################

  # Module Methods
  #####################################

  # Classes
  #####################################

  # A Script in the JSS.
  #
  # As of Casper 9.4, the script contents as stored in the database are
  # accessible via the API
  #
  # According to Jamf as of early 2021, it has been some years now since
  # its been possible to store script contents on a dist. point - they
  # are all always in the database.
  #
  # Use the {#run} method to run the script on the local machine.
  #
  # @see Jamf::APIObject
  #
  class Script < Jamf::APIObject

    # Mix-Ins
    #####################################

    include Jamf::Creatable
    include Jamf::Updatable
    include Jamf::Categorizable

    # Class Methods
    #####################################

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'scripts'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :scripts

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :script

    # The script storage folder on the distribution point, if used
    DIST_POINT_SCRIPTS_FOLDER = 'Scripts'.freeze

    # Priority to use for running the script in relation to other actions during imaging
    PRIORITIES = ['Before', 'After', 'At Reboot'].freeze

    # which is default?
    DEFAULT_PRIORITY = 'After'.freeze

    # The keys used in the @parameters Hash
    PARAMETER_KEYS = [:parameter4, :parameter5, :parameter6, :parameter7, :parameter8, :parameter9, :parameter10, :parameter11].freeze

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 91

    # Where is the Category in the API JSON?
    CATEGORY_SUBSET = :top

    # How is the category stored in the API data?
    CATEGORY_DATA_TYPE = String


    # Attributes
    #####################################

    # @return [String] the file name of the script, if stored in a dist. point
    attr_reader :filename

    # @return [Array<String>] the OS versions this can be installed onto. For all minor versions, the format is 10.5.x
    attr_reader :os_requirements

    # @return [String] either 'Before' or 'After' or "At Reboot".
    attr_reader :priority

    # @return [String] the info field for this script
    attr_reader :info

    # @return [String] the notes field for this script
    attr_reader :notes

    # @return [Hash] descriptions of parameters 4-11. Parameters 1-3 are predefined as target drive, computer name, and username
    attr_reader :parameters
    alias parameter_labels parameters
    alias parameter_descriptions parameters

    # @return {String] the actual code for this script, if it's stored in the database.
    attr_reader :script_contents

    # @return [String] the code for this script, Base64-encoded
    attr_reader :script_contents_encoded

    # Constructor
    #####################################

    #
    def initialize(**args)
      super

      @filename = @init_data[:filename] || @name
      @info = @init_data[:info]
      @notes = @init_data[:notes]
      @os_requirements = @init_data[:os_requirements] ? JSS.to_s_and_a(@init_data[:os_requirements])[:arrayform] : []
      @parameters = @init_data[:parameters] ? @init_data[:parameters] : {}
      @priority = @init_data[:priority] || DEFAULT_PRIORITY
      @script_contents = @init_data[:script_contents]
      @script_contents_encoded = @init_data[:script_contents_encoded]
      if @script_contents && @script_contents_encoded.to_s.empty?
        @script_contents_encoded = Base64.encode64 @script_contents
      end
    end # initialize

    # Change the script filename
    #
    # Setting it to nil will make it match the script name
    #
    # @param new_val[String,Nil] the new filename
    #
    # @return [void]
    #
    # @note This method does NOT change the filename on the distribution point
    #   if that's where you store your scripts.
    #
    def filename=(new_val)
      new_val = nil if new_val == ''
      new_val = @name unless new_val

      return nil if new_val == @filename

      @filename = new_val
      @need_to_update = true
    end # filename=

    # Change the script's display name
    #
    # If the filename is the same as the name, the filename  will be changed also
    #
    # @param new_val[String] the new display name
    #
    # @return [void]
    #
    def name=(new_val)
      new_val = new_val.to_s
      return if new_val == @name

      raise Jamf::MissingDataError, "Name can't be empty" if new_val.empty?
      raise Jamf::AlreadyExistsError, "A script already exists with the name '#{new_val}'" if Jamf::Script.all_names.include? new_val

      # if the filename matches the name, change that too.
      @filename = new_val if @filename == @name
      @name = new_val

      # if our REST resource is based on the name, update that too
      @rest_rsrc = "#{RSRC_BASE}/name/#{CGI.escape @name.to_s}" if @rest_rsrc.include? '/name/'
      @need_to_update = true
    end # name=

    # Change the os_requirements
    #
    # Minumum OS's can be specified as a string using the notation ">=10.6.7"
    # See the {JSS.expand_min_os} method for details.
    #
    # @param new_val[String, Array<String>] the new os requirements as a comma-separted String or an Array of Strings
    #
    # @return [void]
    #
    # @example String value
    #   myscript.os_requirements "10.5, 10.5.3, 10.6.x"
    #
    # @example Array value
    #   ok_oses = ['10.5', '10.5.3', '10.6.x']
    #   myscript.os_requirements ok_oses
    #
    # @example Minimum OS
    #   myscript.os_requirements ">=10.7.5"
    #
    def os_requirements=(new_val)
      # nil should be an empty array
      new_val = [] if new_val.to_s.empty?

      # if any value starts with >=, expand it
      case new_val
      when String
        new_val = JSS.expand_min_os(new_val) if new_val =~ /^>=/
      when Array
        new_val.map! { |a| a =~ /^>=/ ? JSS.expand_min_os(a) : a }
        new_val.flatten!
        new_val.uniq!
      else
        raise Jamf::InvalidDataError, 'os_requirements must be a String or an Array of strings'
      end # case

      # get the array version
      @os_requirements = JSS.to_s_and_a(new_val)[:arrayform]
      @need_to_update = true
    end # os_requirements=

    # Change the priority of this script
    #
    # @param new_val[Integer] the new priority, which must be one of {PRIORITIES}
    #
    # @return [void]
    #
    def priority=(new_val)
      return nil if new_val == @priority
      new_val = DEFAULT_PRIORITY if new_val.nil? || (new_val == '')
      raise Jamf::InvalidDataError, ":priority must be one of: #{PRIORITIES.join ', '}" unless PRIORITIES.include? new_val
      @priority = new_val
      @need_to_update = true
    end # priority=

    # Change the info field
    #
    # @param new_val[String] the new info
    #
    # @return [void]
    #
    def info=(new_val)
      return nil if new_val == @info
      # line breaks should be \r
      new_val = new_val.to_s.tr("\n", "\r")
      @info = new_val
      @need_to_update = true
    end # info=

    # Change the notes field
    #
    # @param new_val[String] the new notes
    #
    # @return [void]
    #
    def notes=(new_val)
      return nil if new_val == @notes
      # line breaks should be \r
      new_val = new_val.to_s.tr("\n", "\r")
      @notes = new_val
      @need_to_update = true
    end # notes=

    # Replace all the script parameters at once.
    #
    # This will replace the entire set with the hash provided.
    #
    # @param new_val[Hash]  the Hash keys must exist in {PARAMETER_KEYS}
    #
    # @return [void]
    #
    def parameters=(new_val)
      return nil if new_val == @parameters
      new_val = {} if new_val.nil? || (new_val == '')

      # check the values
      raise Jamf::InvalidDataError, ':parameters must be a Hash with keys :parameter4 thru :parameter11' unless \
        new_val.is_a?(Hash) && ((new_val.keys & PARAMETER_KEYS) == new_val.keys)
      new_val.each do |_k, v|
        raise Jamf::InvalidDataError, ':parameter values must be strings or nil' unless v.nil? || v.is_a?(String)
      end

      @parameters = new_val
      @need_to_update = true
    end # parameters=

    # Change one of the stored parameters
    #
    # @param param_num[Integer] which param are we setting? must be 4..11
    #
    # @param new_val[String] the new value for the parameter
    #
    # @return [void]
    #
    def set_parameter(param_num, new_val)
      raise Jamf::NoSuchItemError, 'Parameter numbers must be from 4-11' unless (4..11).cover? param_num
      pkey = "parameter#{param_num}".to_sym
      raise Jamf::InvalidDataError, 'parameter values must be strings or nil' unless new_val.nil? || new_val.is_a?(String)
      return nil if new_val == @parameters[pkey]
      @parameters[pkey] = new_val
      @need_to_update = true
    end
    alias set_parameter_label set_parameter
    alias set_parameter_description set_parameter

    # Change the executable code of this script.
    #
    # If the arg is a Pathname instance, or a String starting with "/"
    # Then the arg is assumed to be a file from which to read the code.
    #
    # Otherwise it should be a String with the code itself, and it must start with '#!"
    #
    # After doing this, use {#create} or {#update} to write it to the database or
    # use {#upload_master_file} to save it to the master dist. point.
    #
    # @param new_val[String,Pathname] the new script contents or a path to a file containing it.
    #
    # @return [void]
    #
    def script_contents=(new_val)
      new_code = case new_val
                 when String
                   if new_val.start_with? '/'
                     Pathname.new(new_val).read
                   else
                     new_val
                   end # if
                 when Pathname
                   new_val.read
                 else
                   raise Jamf::InvalidDataError, 'New code must be a String (path or code) or Pathname instance'
                 end # case

      raise Jamf::InvalidDataError, "Script contents must start with '#!'" unless new_code.start_with? '#!'

      @script_contents = new_code
      @script_contents_encoded = Base64.encode64 @script_contents
      @need_to_update = true
    end

    # Run this script on the current machine.
    #
    # If the script code is available in the {#script_contents} attribute, then that
    # code is saved to a tmp file, and executed. The tmp file is deleted immediately
    # after running
    #
    # After the script runs, this method returns a two-item Array.
    # - the first item is an Integer, the exit status of the script itself (0 means success)
    # - the second item is a String, the output (stdout + stderr) of the script.
    #
    # The exit status of the jamf binary process will be available as a Process::Status object
    # in $? immediately after running.
    #
    # @param opts[Hash] the options for running the script
    #
    # @option opts :target[String,Pathname] the 'target drive', passed to the script as the first commandline option.
    #   Defaults to '/'
    #
    # @option opts :computer_name[String] the name of the computer, passed to the script as the second commandline
    #   option. Defaults to the name of the current machine
    #
    # @option opts :username[String] the username to be passed to the script as the third commandline option.
    #   Defaults to the current console user.
    #
    # @option opts :p4..:p11[String] the values to be passed as the 4th - 11th commandline params
    #   Script params 1, 2, & 3 are the target:, computer_name: and username: params
    #
    # @option opts :show_output[Boolean] should the output (stdout + stderr) be copied to
    #  stdout in realtime, as well as returned?
    #
    # @return [Array<(Integer,String)>] the exit status and stdout+stderr of the script
    #
    def run(**opts)
      raise Jamf::MissingDataError, 'script_contents does not start with #!' unless @script_contents.to_s.start_with? '#!'

      opts[:target] ||= '/'
      opts[:computer_name] ||= Jamf::Client.run_jamf('getComputerName')[/>(.*?)</, 1]
      opts[:username] ||= Jamf::Client.console_user

      params = [opts[:target], opts[:computer_name], opts[:username]]
      params << opts[:p4]
      params << opts[:p5]
      params << opts[:p6]
      params << opts[:p7]
      params << opts[:p8]
      params << opts[:p9]
      params << opts[:p10]
      params << opts[:p11]

      # everything must be a string
      params.map! &:to_s

      # remove nils
      params.compact!

      # remove empty strings
      params.delete_if &:empty?

      return_value = []

      # Save and run the script from a private temp dir
      # which will be deleted when finished
      require 'tmpdir'
      Dir.mktmpdir do |dir|
        executable = Pathname.new "#{dir}/#{@name}"
        executable.jss_touch
        executable.chmod 0o700
        executable.jss_save @script_contents

        cmd = [executable.to_s]
        cmd += params

        stdout_and_stderr_str, status = Open3.capture2e(*cmd)

        return_value << status.exitstatus
        return_value << stdout_and_stderr_str
      end # Dir.mktmpdirs

      return_value
    end # def run

    # aliases under their methods seem to confuse the YARD documenter, so I'm putting them all here.
    alias oses os_requirements
    alias oses= os_requirements=
    alias code script_contents
    alias code= script_contents=
    alias contents script_contents
    alias contents= script_contents=

    # Private Instance Methods
    #####################################

    private

    # Return the xml for creating or updating this script in the JSS
    #
    def rest_xml
      doc = REXML::Document.new
      scpt = doc.add_element 'script'

      scpt.add_element('filename').text = @filename
      scpt.add_element('id').text = @id
      scpt.add_element('info').text = @info
      scpt.add_element('name').text = @name
      scpt.add_element('notes').text = @notes
      scpt.add_element('os_requirements').text = JSS.to_s_and_a(@os_requirements)[:stringform]
      scpt.add_element('priority').text = @priority
      add_category_to_xml(doc)

      if @parameters.empty?
        scpt.add_element('parameters').text = nil
      else
        pars = scpt.add_element('parameters')
        PARAMETER_KEYS.each { |p| pars.add_element(p.to_s).text = @parameters[p] }
      end

      scpt.add_element('script_contents_encoded').text = script_contents_encoded

      doc.to_s
    end # rest xml

  end # class Script

end # module
