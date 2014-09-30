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
  ### A User in the JSS.
  ###
  ### @see JSS::APIObject
  ###
  class User < JSS::APIObject

    #####################################
    ### Mix-Ins
    #####################################
    include JSS::Creatable
    include JSS::Updatable
    include JSS::Extendable

    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################

    ### The base for REST resources of this class
    RSRC_BASE = "users"

    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :users

    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :user

    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:position, :full_name, :email]

    ### This class lets us seach for users
    SEARCH_CLASS = JSS::AdvancedUserSearch

    ### This is the class for relevant Extension Attributes
    EXT_ATTRIB_CLASS = JSS::UserExtensionAttribute

    #####################################
    ### Attributes
    #####################################

    ### @return [String] The user's full name
    attr_reader :full_name

    ### @return [String] The user's email address
    attr_reader :email

    ### @return [String] The user's phone number
    attr_reader :phone_number

    ### @return [String] The user's position / job title
    attr_reader :position

    ### @return [String] The name of the user's LDAP server
    attr_reader :ldap_server


    ### @return [Array<Hash>]
    ###
    ### The sites associated with this user
    ###
    ### Each Hash has then :id and :name for one site
    ###
    attr_reader :sites


    ### @return [Array<Hash>]
    ###
    ### The computers associated with this user
    ###
    ### Each Hash has then :id and :name for one computer
    ###
    attr_reader :computers


    ### @return [Array<Hash>]
    ###
    ### The peripherals associated with this user
    ###
    ### Each Hash has then :id and :name for one peripheral
    ###
    attr_reader :peripherals

    ### @return [Array<Hash>]
    ###
    ### The mobile devices associated with this user
    ###
    ### Each Hash has then :id and :name for one device
    ###
    ### @note This data is currently broken - the JSON output of the API only
    ### returns one mobile device, and it isn't formatted in a standard way.
    ###
    attr_reader :mobile_devices

    ### @return [Array<Hash>]
    ###
    ### The vpp assignments associated with this user
    ###
    ### Each Hash has then :id and :name for one assignment
    ###
    attr_reader :vpp_assignments

    ### @return [Integer] the total number of vpp codes assigned to this user
    attr_reader :total_vpp_code_count

    #####################################
    ### Constructor
    #####################################

    ###
    ### See JSS::APIObject#initialize
    ###
    def initialize (args = {})
      super

      @full_name = @init_data[:full_name]
      @email = @init_data[:email]
      @phone_number = @init_data[:phone_number]
      @position = @init_data[:position]
      @ldap_server = JSS::APIObject.get_name @init_data[:ldap_server]
      @sites = @init_data[:sites] ? @init_data[:sites]  : []

      if @init_data[:links]
        @computers = @init_data[:links][:computers]
        @peripherals = @init_data[:links][:peripherals]
        @mobile_devices = @init_data[:links][:mobile_devices]
        @vpp_assignments = @init_data[:links][:vpp_assignments]
        @total_vpp_code_count = @init_data[:links][:total_vpp_code_count]
      end

      parse_ext_attrs
    end

    #####################################
    ### Public Instance Methods
    #####################################


    ###
    ### Simple Setters
    ###

    ###
    def full_name= (new_val)
      @full_name = new_val
      @need_to_update = true
    end

    ###
    def email= (new_val)
      @email = new_val
      @need_to_update = true
    end

    ###
    def phone_number= (new_val)
      @phone_number = new_val
      @need_to_update = true
    end

    ###
    def position= (new_val)
      @position = new_val
      @need_to_update = true
    end

    ###
    def ldap_server= (new_val)
      raise JSS::InvalidDataError, "No LDAP server in the JSS named #{new_val}" unless JSS::LDAPServer.all_names.include? new_val
      @ldap_server = new_val
      @need_to_update = true
    end

    ###
    ### Add this user to a site
    ###
    ### @param site[String] the name of the site
    ###
    ### @return [void]
    ###
    def add_site (site)
      return nil if @sites.map{|s| s[:name]}.include? site
      raise JSS::InvalidDataError, "No site in the JSS named #{site}" unless JSS::Site.all_names.include? site
      @sites << {:name => site}
      @need_to_update = true
    end

    ###
    ### Remove this user from a site
    ###
    ### @param site[String] the name of the site
    ###
    ### @return [void]
    ###
    def remove_site (site)
      return nil unless @sites.map{|s| s[:name]}.include? site
      @sites.reject!{|s| s[:name] == site}
      @need_to_update = true
    end


    #####################################
    ### Private Instance Methods
    #####################################
    private

    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      user = doc.add_element self.class::RSRC_OBJECT_KEY.to_s

      user.add_element('name').text = @name
      user.add_element('full_name').text = @full_name
      user.add_element('email').text = @email
      user.add_element('phone_number').text = @phone_number
      user.add_element('position').text = @position

      ldap = user.add_element('ldap_server')
      ldap.add_element('name').text = @ldap_server

      user << JSS::Site.xml_list(@sites)

      user << ext_attr_xml

      return doc.to_s
    end

  end # class user

end # module
