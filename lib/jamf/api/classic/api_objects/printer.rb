module Jamf

  ### Module Constants
  #####################################

  ### Module Variables
  #####################################

  ### Module Methods
  #####################################

  ### Classes
  #####################################

  ### Printer object inside JSS
  ###
  ### @see Jamf::APIObject
  class Printer < Jamf::APIObject

    ## Mix-Ins
    #####################################
    include Jamf::Creatable
    include Jamf::Updatable
    include Jamf::Categorizable

    ## Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = 'printers'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :printers

    ### The hash key used for the JSON object output
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :printer

    # Where is the Category in the API JSON?
    CATEGORY_SUBSET = :top

    # How is the category stored in the API data?
    CATEGORY_DATA_TYPE = String

    ## Attributes
    #####################################

    ### @return [String] The URI path for the specific printer.
    attr_reader :uri

    ### @return [String] The CUPs name to be used
    attr_reader :CUPS_name

    ### @return [String] The physical location of the printer.
    attr_reader :location

    ### @return [String] The specific model of printer.
    attr_reader :model

    ### @return [Boolean] Is this printer to be shared?
    attr_reader :shared

    ### @return [String] Information for this specific printer.
    attr_reader :info

    ### @return [String] Notes for this specific printer.
    attr_reader :notes

    ### @return [Boolean] Make this printer as the default printer upon installation.
    attr_reader :make_default

    ### @return [Boolean] Use a generic PPD.
    attr_reader :use_generic

    ### @return [String] The PPD file name.
    attr_reader :ppd

    ### @return [String] The contents of the PPD file.
    attr_reader :ppd_contents

    ### @return [String] The path the PPD file will be installed.
    attr_reader :ppd_path

    ### @return [String] The OS version requirements seperated by commas
    attr_reader :os_requirements

    ## Constructor
    #####################################

    ###
    def initialize(**args)
      super

      if in_jss?

        @uri = @init_data[:uri]
        @CUPS_name = @init_data[:CUPS_name]
        @location = @init_data[:location]
        @model = @init_data[:model]
        @shared = @init_data[:shared]
        @info = @init_data[:info]
        @notes = @init_data[:notes]
        @make_default = @init_data[:make_default]
        @use_generic = @init_data[:use_generic]
        @ppd = @init_data[:ppd]
        @ppd_contents = @init_data[:ppd_contents]
        @ppd_path = @init_data[:ppd_path]
        @os_requirements = @init_data[:os_requirements]
      else

        raise Jamf::MissingDataError, 'CUPS_name must be provided.' if @init_data[:CUPS_name].nil?
        raise Jamf::MissingDataError, 'uri must be provided.' if @init_data[:uri].nil?

        raise Jamf::InvalidDataError, 'uri must be a String.' unless @init_data[:uri].is_a?(String) || @init_data[:uri].nil?
        raise Jamf::InvalidDataError, 'CUPS_name must be a String.' unless @init_data[:CUPS_name].is_a?(String)
        raise Jamf::InvalidDataError, 'location must be a String.' unless @init_data[:location].is_a?(String) || @init_data[:location].nil?
        raise Jamf::InvalidDataError, 'model must be a String.' unless @init_data[:model].is_a?(String) || @init_data[:model].nil?
        raise Jamf::InvalidDataError, 'info must be a String.' unless @init_data[:info].is_a?(String) || @init_data[:info].nil?
        raise Jamf::InvalidDataError, 'notes must be a String.' unless @init_data[:notes].is_a?(String) || @init_data[:notes].nil?
        raise Jamf::InvalidDataError, 'ppd must be a String.' unless @init_data[:ppd].is_a?(String) || @init_data[:ppd].nil?
        raise Jamf::InvalidDataError, 'ppd_contents must be a String.' unless @init_data[:ppd_contents].is_a?(String) || @init_data[:ppd_contents].nil?
        raise Jamf::InvalidDataError, 'ppd_path must be a String.' unless @init_data[:ppd_path].is_a?(String) || @init_data[:ppd_path].nil?

        unless @init_data[:os_requirements].is_a?(String) || @init_data[:os_requirements].nil?
          raise Jamf::InvalidDataError,
                'os_requirements must be a String.'
        end
        unless (@init_data[:shared].is_a?(TrueClass) || @init_data[:shared].is_a?(FalseClass)) || @init_data[:shared].nil?
          raise Jamf::InvalidDataError,
                'shared must be a String.'
        end
        unless (@init_data[:make_default].is_a?(TrueClass) || @init_data[:make_default].is_a?(FalseClass)) || @init_data[:make_default].nil?
          raise Jamf::InvalidDataError,
                'make_default must be a String.'
        end
        unless (@init_data[:use_generic].is_a?(TrueClass) || @init_data[:use_generic].is_a?(FalseClass)) || @init_data[:use_generic].nil?
          raise Jamf::InvalidDataError,
                'use_generic must be a String.'
        end

        @uri = @init_data[:uri]
        @CUPS_name = @init_data[:CUPS_name]
        @location = @init_data[:location]
        @model = @init_data[:model]
        @shared = @init_data[:shared]
        @info = @init_data[:info]
        @notes = @init_data[:notes]
        @make_default = @init_data[:make_default]
        @use_generic = @init_data[:use_generic]
        @ppd = @init_data[:ppd]
        @ppd_contents = @init_data[:ppd_contents]
        @ppd_path = @init_data[:ppd_path]
        @os_requirements = @init_data[:os_requirements]
      end
    end

    ## Class Methods
    #####################################

    # The URI path for the specific printer.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def uri=(newvalue)
      raise Jamf::InvalidDataError, 'URI must be a string.' unless newvalue.is_a? String

      @uri = newvalue

      @need_to_update = true
    end

    # The CUPs name to be used
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def CUPS_name=(newvalue)
      raise Jamf::InvalidDataError, 'CUPS_name must be a string.' unless newvalue.is_a? String

      @CUPS_name = newvalue

      @need_to_update = true
    end

    # The physical location of the printer.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def location=(newvalue)
      raise Jamf::InvalidDataError, 'location must be a string.' unless newvalue.is_a? String

      @location = newvalue

      @need_to_update = true
    end

    # The specific model of printer.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def model=(newvalue)
      raise Jamf::InvalidDataError, 'model must be a string.' unless newvalue.is_a? String

      @model = newvalue

      @need_to_update = true
    end

    # Is this printer to be shared?
    #
    # @author Tyler Morgan
    #
    # @param newvalue [Boolean]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a Boolean
    #
    # @return [void]
    def shared=(newvalue)
      raise Jamf::InvalidDataError, 'shared must be a string.' unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

      @shared = newvalue

      @need_to_update = true
    end

    # Information for this specific printer.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def info=(newvalue)
      raise Jamf::InvalidDataError, 'info must be a string.' unless newvalue.is_a? String

      @info = newvalue

      @need_to_update = true
    end

    # Notes for this specific printer.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def notes=(newvalue)
      raise Jamf::InvalidDataError, 'notes must be a string.' unless newvalue.is_a? String

      @notes = newvalue

      @need_to_update = true
    end

    # Make this printer as the default printer upon installation.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [Boolean]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a Boolean
    #
    # @return [void]
    def make_default=(newvalue)
      raise Jamf::InvalidDataError, 'make_default must be a string.' unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

      @make_default = newvalue

      @need_to_update = true
    end

    # Use a generic PPD.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [Boolean]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a Boolean
    #
    # @return [void]
    def use_generic=(newvalue)
      raise Jamf::InvalidDataError, 'use_generic must be a string.' unless newvalue.is_a?(TrueClass) || newvalue.is_a?(FalseClass)

      @use_generic = newvalue

      @need_to_update = true
    end

    # The PPD file name.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def ppd=(newvalue)
      raise Jamf::InvalidDataError, 'ppd must be a string.' unless newvalue.is_a? String

      @ppd = newvalue

      @need_to_update = true
    end

    # The contents of the PPD file.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def ppd_contents=(newvalue)
      raise Jamf::InvalidDataError, 'ppd_contents must be a string.' unless newvalue.is_a? String

      @ppd_contents = newvalue

      @need_to_update = true
    end

    # The path the PPD file will be installed.
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String
    #
    # @return [void]
    def ppd_path=(newvalue)
      raise Jamf::InvalidDataError, 'ppd_path must be a string.' unless newvalue.is_a? String

      @ppd_path = newvalue

      @need_to_update = true
    end

    # The OS version requirements seperated by commas
    #
    # @author Tyler Morgan
    #
    # @param newvalue [String, Float, Array[String], Array[Float]]
    #
    # @raise [Jamf::InvalidDataError] If newvalue is not a String, Float, Array containing Strings, or Array containing Floats.
    #
    # @example Limit Printer object to only High Sierra devices and Mojave 10.14.5 OS versions
    #   printer.os_requirements = "10.13.x, 10.14.5"
    #
    # @return [void]
    def os_requirements=(newvalue)
      if newvalue.is_a? Array
        # Parse Array
        unless newvalue[0].is_a?(String) || newvalue[0].is_a?(Float)
          raise Jamf::InvalidDataError,
                'If setting os_requirements with an array, it must contain strings or floats.'
        end

        newvalue = newvalue.map { |x| x.to_s }.join(',')
      else
        unless (newvalue.is_a?(String) || newvalue.is_a?(Float)) && !newvalue.nil?
          raise Jamf::InvalidDataError,
                'os_requirements must either be a string, float, or an array containing strings or floats.'
        end
      end

      @os_requirements = newvalue

      @need_to_update = true
    end

    # Remove the various large data
    # from the instance_variables used to create
    # pretty-print (pp) output.
    #
    # @return [Array] the desired instance_variables
    #
    def pretty_print_instance_variables
      vars = super
      vars.delete :@ppd_contents
      vars
    end

    ## Private Instance Methods
    #####################################
    private

    ### Return the xml for creating or updating this script in the JSS
    ###
    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      doc.root.name = 'printer'
      printer = doc.root

      printer.add_element('id').text = @id
      printer.add_element('name').text = @name
      printer.add_element('uri').text = @uri
      printer.add_element('CUPS_name').text = @CUPS_name
      printer.add_element('location').text = @location
      printer.add_element('model').text = @model
      printer.add_element('shared').text = @shared
      printer.add_element('info').text = @info
      printer.add_element('notes').text = @notes
      printer.add_element('make_default').text = @make_default
      printer.add_element('use_generic').text = @use_generic
      printer.add_element('ppd').text = @ppd
      printer.add_element('ppd_contents').text = @ppd_contents
      printer.add_element('ppd_path').text = @ppd_path
      printer.add_element('os_requirements').text = @os_requirements
      add_category_to_xml(doc)

      doc.to_s
    end

  end

end
