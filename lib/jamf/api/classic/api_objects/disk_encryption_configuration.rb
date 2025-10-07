module Jamf

  ### Module Constants
  #####################################

  ### Module Variables
  #####################################

  ### Module Methods
  #####################################

  ### Classes
  #####################################

  ### Disk Encryption Configuration object inside JSS
  ###
  ### More Detailed Description if needed
  class DiskEncryptionConfiguration < Jamf::APIObject

    ## Mix-Ins
    #####################################
    include Jamf::Updatable

    ## Class Constants
    #####################################

    # @note Currently "Individual and Institutional" configuration type is unsupported through the API
    KEY_TYPE = {
      individual: 'Individual',
      institutional: 'Institutional',
      individual_and_institutional: 'Individual and Institutional'
    }.freeze

    # @note as of 10.13 Management Account cannot be used due to the lack of a secure token.
    ENABLED_USERS_TYPE = {
      management: 'Management Account',
      current: 'Current or Next User'
    }.freeze

    ### The base for REST resources of this class
    RSRC_BASE = 'diskencryptionconfigurations'.freeze

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :disk_encryption_configurations

    ### The hash key used for the JSON object output
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :disk_encryption_configuration

    ## Attributes
    #####################################
    attr_reader :key_type
    attr_reader :file_vault_enabled_users, :institutional_recovery_key

    ## Constructor
    #####################################

    ###
    def initialize(**args)
      super

      raise Jamf::InvalidDataError, 'Currently the ability to create a Disk Encryption Configuration is not possible through ruby-jss.' unless in_jss?

      @key_type = @init_data[:key_type]
      @file_vault_enabled_users = @init_data[:file_vault_enabled_users]
      @institutional_recovery_key = @init_data[:institutional_recovery_key]
        
            
        
    end

    ## Class Methods
    #####################################

    # Sets what type of account is to be enabled using the new value
    #
    # @author Tyler Morgan
    #
    # @param newvalue[Symbol] One of ENABLED_USERS_TYPE
    #
    # @return [Void]
    #
    def file_vault_enabled_users=(newvalue)
      unless ENABLED_USERS_TYPE.keys.include? newvalue
        raise Jamf::InvalidDataError, 
              "file_vault_enabled_users must be one of :#{ENABLED_USERS_TYPE.keys.join(',:')}."
      end

      @file_vault_enabled_users = ENABLED_USERS_TYPE[newvalue]

      @need_to_update = true
    end

    ## Private Instance Methods
    #####################################

    private

    def rest_xml
      if @key_type == KEY_TYPE[:individual_and_institutional]
        raise Jamf::UnsupportedError, 
              'Key type of "Individual and Institutional" is currently unsupported via. API. So changes are unable to be saved.'
      end

      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      doc.root.name = 'disk_encryption_configuration'

      disk_encryption_configuration = doc.root

      disk_encryption_configuration.add_element('id').text = @id
      disk_encryption_configuration.add_element('name').text = @name
      disk_encryption_configuration.add_element('key_type').text = @key_type
      disk_encryption_configuration.add_element('file_vault_enabled_users').text = @file_vault_enabled_users

      doc.to_s
    end

  end

end
