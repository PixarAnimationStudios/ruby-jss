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

###
module JSS

  #####################################
  ### Module Constants
  #####################################

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
  ### A Script in the JSS.
  ###
  ### As of Casper 9.4, the script contents as stored in the database are
  ### accessible via the API
  ###
  ### This class will save the script contents back to the database with
  ### the {#create} or {#update} methods
  ###
  ### If your scripts are stored on the master distribution point instead of
  ### the database, you can use {#upload_master_file} to save it to the server,
  ### and {#delete_master_file} to delete it from the server.
  ###
  ### Use the {#run} method to run the script on the local machine via the 'jamf runScript' command
  ###
  ### @see JSS::APIObject
  ###
  class Script < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################

    include JSS::Creatable
    include JSS::Updatable

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "scripts"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :scripts

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :script

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:parameters, :filename, :os_requirements ]

    ### The script storage folder on the distribution point, if used
    DIST_POINT_SCRIPTS_FOLDER = "Scripts"

    ### Priority to use for running the script in relation to other actions during imaging
    PRIORITIES = [ 'Before', 'After','At Reboot']

    ### which is default?
    DEFAULT_PRIORITY = "After"

    ### The keys used in the @parameters Hash
    PARAMETER_KEYS = [:parameter4, :parameter5, :parameter6,:parameter7, :parameter8, :parameter9, :parameter10, :parameter11]

    #####################################
    ### Attributes
    #####################################

    ### @return [String] the file name of the script, if stored in a dist. point
    attr_reader :filename

    ### @return [Array<String>] the OS versions this can be installed onto. For all minor versions, the format is 10.5.x
    attr_reader :os_requirements

    ### @return [String] either 'Before' or 'After' or "At Reboot".
    attr_reader :priority

    ### @return [String] the info field for this script
    attr_reader :info

    ### @return [String] the notes field for this script
    attr_reader :notes

    ### @return [String] the category of this script, stored in the JSS as the id number from the categories table
    attr_reader :category

    ### @return [Hash] script parameters 4-11. Parameters 1-3 are predefined as target drive, computer name, and username
    attr_reader :parameters

    ### @return {String] the actual code for this script, if it's stored in the database.
    attr_reader :script_contents


    #####################################
    ### Constructor
    #####################################

    ###
    ###
    ###
    def initialize (args = {})
      super

      @category = JSS::APIObject.get_name(@init_data[:category])
      @filename = @init_data[:filename] || @name
      @info = @init_data[:info]
      @notes = @init_data[:notes]
      @os_requirements = @init_data[:os_requirements] ? JSS.to_s_and_a(@init_data[:os_requirements] )[:arrayform] : []
      @parameters = @init_data[:parameters] ? @init_data[:parameters] : {}
      @priority = @init_data[:priority] || DEFAULT_PRIORITY
      @script_contents =  @init_data[:script_contents]

    end # initialize

    ###
    ### Change the script filename
    ###
    ### Setting it to nil will make it match the script name
    ###
    ### @param new_val[String,Nil] the new filename
    ###
    ### @return [void]
    ###
    ### @note This method does NOT change the filename on the distribution point
    ###   if that's where you store your scripts.
    ###
    def filename= (new_val)

      new_val = nil if new_val == ''
      new_val = @name unless new_val

      return nil if new_val == @filename

      @filename = new_val
      @need_to_update = true
    end #filename=

    ###
    ### Change the script's display name
    ###
    ### If the filename is the same as the name, the filename  will be changed also
    ###
    ### @param new_val[String] the new display name
    ###
    ### @return [void]
    ###
    def name= (new_val)
      return nil if new_val == @name
      new_val = nil if new_val == ''
      raise JSS::MissingDataError, "Name can't be empty" unless new_val
      raise JSS::AlreadyExistsError, "A #{RSRC_OBJECT_KEY} already exists with the name '#{args[:name]}'" if JSS.send(LIST_METHOD).values.include?

      ### if the filename is the same, keep it the same
      @filename = new_val if @filename == @name
      @name = new_val

      ### if our REST resource is based on the name, update that too
      @rest_rsrc = "#{RSRC_BASE}/name/#{URI.escape @name}" if @rest_rsrc.include? '/name/'
      @need_to_update = true
    end #name=

    ###
    ### Change the os_requirements
    ###
    ### Minumum OS's can be specified as a string using the notation ">=10.6.7"
    ### See the {JSS.expand_min_os} method for details.
    ###
    ### @param new_val[String, Array<String>] the new os requirements as a comma-separted String or an Array of Strings
    ###
    ### @return [void]
    ###
    ### @example String value
    ###   myscript.os_requirements "10.5, 10.5.3, 10.6.x"
    ###
    ### @example Array value
    ###   ok_oses = ['10.5', '10.5.3', '10.6.x']
    ###   myscript.os_requirements ok_oses
    ###
    ### @example Minimum OS
    ###   myscript.os_requirements ">=10.7.5"
    ###
    def os_requirements= (new_val)
      ### nil should be an empty array
      new_val = [] if new_val.to_s.empty?

      ### if any value starts with >=, expand it
      case new_val
        when String
          new_val = JSS.expand_min_os(new_val) if new_val =~ /^>=/
        when Array
          new_val.map!{|a|  a =~ /^>=/ ? JSS.expand_min_os(a) : a }
          new_val.flatten!
          new_val.uniq!
        else
          raise JSS::InvalidDataError, "os_requirements must be a String or an Array of strings"
      end # case

      ### get the array version
      @os_requirements = JSS.to_s_and_a(new_val)[:arrayform]
      @need_to_update = true

    end #os_requirements=

    ###
    ### Change the priority of this script
    ###
    ### @param new_val[Integer] the new priority, which must be one of {PRIORITIES}
    ###
    ### @return [void]
    ###
    def priority= (new_val)
      return nil if new_val == @priority
      new_val = DEFAULT_PRIORITY if new_val.nil? or new_val == ""
      raise JSS::InvalidDataError, ":priority must be one of: #{PRIORITIES.join ', '}" unless PRIORITIES.include? new_val
      @priority = new_val
      @need_to_update = true
    end #priority=

    ###
    ### Change the info field
    ###
    ### @param new_val[String] the new info
    ###
    ### @return [void]
    ###
    def info= (new_val)
      return nil if new_val == @info
      ### line breaks should be \r
      new_val = new_val.to_s.gsub(/\n/, "\r")
      @info = new_val
      @need_to_update = true
    end #info=

    ###
    ### Change the notes field
    ###
    ### @param new_val[String] the new notes
    ###
    ### @return [void]
    ###
    def notes= (new_val)
      return nil if new_val == @notes
      ### line breaks should be \r
      new_val = new_val.to_s.gsub(/\n/, "\r")
      @notes = new_val
      @need_to_update = true
    end #notes=

    ###
    ### Change the category
    ###
    ### @param new_val[String] the name of the new category, which must be in {JSS::Category.all_names}
    ###
    ### @return [void]
    ###
    def category= (new_val)
      return nil if new_val == @category
      new_val = nil if new_val == ''
      new_val ||= JSS::Category::DEFAULT_CATEGORY
      raise JSS::InvalidDataError, "Category #{new_val} is not known to the JSS" unless JSS::Category.all_names.include? new_val
      @need_to_update = true
      @category = new_val
    end #category=

    ###
    ### Replace all the script parameters at once.
    ###
    ### This will replace the entire set with the hash provided.
    ###
    ### @param new_val[Hash]  the Hash keys must exist in {PARAMETER_KEYS}
    ###
    ### @return [void]
    ###
    def parameters= (new_val)
      return nil if new_val == @parameters
      new_val = {} if new_val.nil? or new_val== ''

      ### check the values
      raise JSS::InvalidDataError, ":parameters must be a Hash with keys :parameter4 thru :parameter11" unless new_val.kind_of? Hash and (new_val.keys & PARAMETER_KEYS) == new_val.keys
      new_val.each do |k,v|
            raise JSS::InvalidDataError, ":parameter values must be strings or nil" unless v.nil? or v.kind_of? String
      end

      @parameters = new_val
      @need_to_update = true
    end # parameters=

    ###
    ### Change one of the stored parameters
    ###
    ### @param param_num[Integer] which param are we setting? must be 4..11
    ###
    ### @param new_val[String] the new value for the parameter
    ###
    ### @return [void]
    ###
    def set_parameter (param_num, new_val)
      raise JSS::NoSuchItemError, "Parameter numbers must be from 4-11" unless (4..11).include? param_num
      pkey = "parameter#{param_num}".to_sym
      raise JSS::InvalidDataError, "parameter values must be strings or nil" unless new_val.nil? or new_val.kind_of? String
      return nil if new_val == @parameters[pkey]
      @parameters[pkey] = new_val
      @need_to_update = true
    end

    ###
    ### Change the executable code of this script.
    ###
    ### If the arg is a Pathname instance, or a String starting with "/"
    ### Then the arg is assumed to be a file from which to read the code.
    ###
    ### Otherwise it should be a String with the code itself, and it must start with '#!"
    ###
    ### After doing this, use {#create} or {#update} to write it to the database or
    ### use {#upload_master_file} to save it to the master dist. point.
    ###
    ### @param new_val[String,Pathname] the new script contents or a path to a file containing it.
    ###
    ### @return [void]
    ###
    def script_contents= (new_val)

      new_code = case new_val
        when String
          if new_val.start_with? '/'
            Pathname.new(new_val).read
          else
            new_val
          end #if
        when Pathname
          new_val.read
        else
          raise JSS::InvalidDataError, "New code must be a String (path or code) or Pathname instance"
      end # case

      raise JSS::InvalidDataError, "Script contents must start with '#!'" unless new_code.start_with? '#!'

      @script_contents = new_code
      @need_to_update = true
    end

    ###
    ### Save the @script_contents for this script to a file on the Master Distribution point.
    ###
    ### If you'll be uploading several files you can specify unmount as false, and do it manually when all
    ### are finished.
    ###
    ### use {#script_contents=}  to set the script_contents from a String or Pathname
    ###
    ### @param rw_pw[String] the password for the read/write account on the master Distribution Point
    ###
    ### @param unmount[Boolean] whether or not ot unount the distribution point when finished.
    ###
    ### @return [void]
    ###
    def upload_master_file( rw_pw, unmount = true)
      raise JSS::MissingDataError, "No code specified. Use #code= first." if @script_contents.nil? or @script_contents.empty?

      mdp = JSS::DistributionPoint.master_distribution_point
      raise JSS::InvaldDatatError, "Incorrect password for read-write access to master distribution point." unless mdp.check_pw :rw, rw_pw

      destination = mdp.mount(rw_pw, :rw) + "#{DIST_POINT_SCRIPTS_FOLDER}/#{@filename}"
      destination.save @script_contents
      mdp.unmount if unmount
    end # upload

    ###
    ### Delete the filename from the master distribution point, if it exists.
    ###
    ### If you'll be uploading several files you can specify unmount as false, and do it manually when all
    ### are finished.
    ###
    ### @param rw_pw[String] the password for the read/write account on the master Distribution Point
    ###
    ### @param unmount[Boolean] whether or not ot unount the distribution point when finished.
    ###
    ### @return [Boolean] was the file deleted?
    ###
    def delete_master_file(rw_pw, unmount = true)
      file = JSS::DistributionPoint.master_distribution_point.mount(rw_pw, :rw) + "#{DIST_POINT_SCRIPTS_FOLDER}/#{@filename}"
      if file.exist?
        file.delete
        did_it = true
      else
        did_it = false
      end # if exists
      JSS::DistributionPoint.master_distribution_point.unmount if unmount
      return did_it
    end


    ###
    ### Run this script on the current machine using the "jamf runScript" command.
    ###
    ### If the script code is available in the {#script_contents} attribute, then that
    ### code is saved to a tmp file, and executed. Otherwise, the script is assumed
    ### to be stored on the distribution point.
    ###
    ### If the dist. point has http downloads enabled, then the URL is used as the path with the
    ### 'jamf runScript' command.
    ###
    ### If http is not an option, the dist.point is mounted, and the script copied locally before running.
    ### In this case the options must include :ro_pw => 'somepass'
    ### to provide the read-only password for mounting the distribution point. If :unmount => true
    ### is provided, the dist. point will be unmounted immediately after copying
    ### the script locally.  Otherwise it will remain mounted, in case there's further need of it.
    ###
    ### Any local on-disk copies of the script are removed after running.
    ###
    ### After the script runs, this method returns a two-item Array.
    ### - the first item is an Integer, the exit status of the script itself (0 means success)
    ### - the second item is a String, the output (stdout + stderr) of the jamf binary, which will include
    ###   the script output.
    ### The exit status of the jamf binary process will be available as a Process::Status object
    ### in $? immediately after running.
    ###
    ### @param opts[Hash] the options for running the script
    ###
    ### @option opts :target[String,Pathname] the 'target drive', passed to the script as the first commandline option.
    ###   Defaults to '/'
    ###
    ### @option opts :computer_name[String] the name of the computer, passed to the script as the second commandline
    ###   option. Defaults to the name of the current machine
    ###
    ### @option opts :username[String] the username to be passed to the script as the third commandline option.
    ###
    ### @option opts :p1..:p8[String] the values to be passed as the 4th - 11th commandline options, overriding
    ###   those defined with the script in the JSS
    ###
    ### @option opts :ro_pw[String] the read-only password for mounting the distribution point, if needed
    ###
    ### @option opts :unmount[Boolean} should the dist. point be unmounted when finished, if we mounted it?
    ###
    ### @option opts :verbose[Boolean] should the 'jamf runScript' command be verbose?
    ###
    ### @option opts :show_output[Boolean] should the output (stdout + stderr) of 'jamf runScript' be copied to
    ###  stdout in realtime, as well as returned?
    ###
    ### @return [Array<(Integer,String)>] the exit status of the *script* and stdout+stderr of 'jamf runScript'.
    ###   The exit status of the jamf binary will be available in $? immediately after running.
    ###
    ### *NOTE* In the WEB UI and API, the definable parameters are numbered 4-11, since 1, 2, & 3 are the
    ### target drive, computer name, and user name respectively.  However, the jamf binary refers to them as
    ### p1-p8, and that's how they are expected as options to #run. So if :p1=> "new param" is given as an
    ### aption to #run, it will override any value that the API provided in @parameters[:parameter4]
    ###
    def run( opts = {} )

      opts[:target] ||= "/"
      opts[:p1] ||= @parameters[:parameter4]
      opts[:p2] ||= @parameters[:parameter5]
      opts[:p3] ||= @parameters[:parameter6]
      opts[:p4] ||= @parameters[:parameter7]
      opts[:p5] ||= @parameters[:parameter8]
      opts[:p6] ||= @parameters[:parameter9]
      opts[:p7] ||= @parameters[:parameter10]
      opts[:p8] ||= @parameters[:parameter11]

      dp_mount_pt = nil
      delete_exec = false

      begin

        # do we have the code already? if so, save it out and make it executable
        if @script_contents and (not @script_contents.empty?)

          script_path = JSS::Client::DOWNLOADS_FOLDER

          executable = script_path + @filename

          executable.jss_touch
          executable.chmod 0700
          executable.jss_save @script_contents
          delete_exec = true

        # otherwise, get it from the dist. point
        else
          dist_point = JSS::DistributionPoint.my_distribution_point

          ### how do we access our dist. point?
          if dist_point.http_downloads_enabled
            script_path = dist_point.http_url + "/#{DIST_POINT_SCRIPTS_FOLDER}/"

          else
            dp_mount_pt = dist_point.mount opts[:ro_pw]

            script_path = (dp_mount_pt + DIST_POINT_SCRIPTS_FOLDER)

          end # if http enabled

        end # if @script_contents and (not @script_contents.empty?)


        # build the command as an array.
        command_arry = ["-script", @filename, '-path', script_path.to_s]

        command_arry << "-target"
        command_arry << opts[:target].to_s

        command_arry << "-computerName" if opts[:computer_name]
        command_arry << opts[:computer_name] if opts[:computer_name]

        command_arry << "-username" if opts[:username]
        command_arry << opts[:username] if opts[:username]

        command_arry << "-p1" if opts[:p1]
        command_arry << opts[:p1] if opts[:p1]

        command_arry << "-p2" if opts[:p2]
        command_arry << opts[:p2] if opts[:p2]

        command_arry << "-p3" if opts[:p3]
        command_arry << opts[:p3] if opts[:p3]

        command_arry << "-p4" if opts[:p4]
        command_arry << opts[:p4] if opts[:p4]

        command_arry << "-p5" if opts[:p5]
        command_arry << opts[:p5] if opts[:p5]

        command_arry << "-p6" if opts[:p6]
        command_arry << opts[:p6] if opts[:p6]

        command_arry << "-p7" if opts[:p7]
        command_arry << opts[:p7] if opts[:p7]

        command_arry << "-p8" if opts[:p8]
        command_arry << opts[:p8] if opts[:p8]

        command_arry << "-verbose" if opts[:verbose]

        command = command_arry.shelljoin

        jamf_output =  JSS::Client.run_jamf "runScript", command, opts[:show_output]

        jamf_output =~ /^.*Script exit code: (\d+)(\D|$)/

        script_exitstatus = $1.to_i

      ensure
        executable.delete if delete_exec and executable.exist?
        dist_point.unmount if (dp_mount_pt and dp_mount_pt.mountpoint? and opts[:unmount])
      end # begin/ensure

      return [script_exitstatus, jamf_output]

    end # def run


    # aliases under their methods seem to confuse the YARD documenter, so I'm putting them all here.
    alias oses os_requirements
    alias oses= os_requirements=
    alias code script_contents
    alias code= script_contents=
    alias contents script_contents
    alias contents= script_contents=


    #####################################
    ### Private Instance Methods
    #####################################

    private

    ###
    ### Return the xml for creating or updating this script in the JSS
    ###
    def rest_xml
      doc = REXML::Document.new
      scpt = doc.add_element "script"
      scpt.add_element('category').text = @category
      scpt.add_element('filename').text = @filename
      scpt.add_element('id').text = @id
      scpt.add_element('info').text = @info
      scpt.add_element('name').text = @name
      scpt.add_element('notes').text = @notes
      scpt.add_element('os_requirements').text = JSS.to_s_and_a(@os_requirements)[:stringform]
      scpt.add_element('priority').text = @priority

      if @parameters.empty?
        scpt.add_element('parameters').text = nil
      else
        pars = scpt.add_element('parameters')
        PARAMETER_KEYS.each {|p| pars.add_element(p.to_s).text = @parameters[p]}
      end

      scpt.add_element('script_contents_encoded').text = Base64.encode64(@script_contents)

      return doc.to_s
    end # rest xml

  end # class Script
end # midule
