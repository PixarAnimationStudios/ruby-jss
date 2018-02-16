module JSS

  # Restricted Software items in the JSS.
  #
  # @see JSS::APIObject
  #
  class RestrictedSoftware < JSS::APIObject

    # Mix-Ins
    #####################################
    include JSS::Updatable
    include JSS::Creatable
    include JSS::Scopable
    include JSS::Sitable

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'restrictedsoftware'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :restricted_software

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :restricted_software

    # these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:scope].freeze

    # Our scopes deal with computers
    SCOPE_TARGET_KEY = :computers

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 5

    # Where is the Site data in the API JSON?
    SITE_SUBSET = :general

    # Attributes
    #####################################

    # @return [String] the process name
    attr_reader :process_name

    # @return [Boolean] whether to return match exact process name
    attr_reader :match_exact_process_name

    # @return [Boolean] whether to send a notification
    attr_reader :send_notification

    # @return [Boolean] whether to kill the running process
    attr_reader :kill_process

    # @return [Boolean] whether to delete the executable
    attr_reader :delete_executable

    # @return [String] message displayed to the user
    attr_reader :display_message

    # @return [Hash] the :name and :id of the site for this machine
    attr_reader :site

    # Instance Methods
    #####################################

    def initialize(args = {})
      super args

      @init_data[:general] ||= {}
      @process_name = @init_data[:general][:process_name]
      @match_exact_process_name = @init_data[:general][:match_exact_process_name]
      @send_notification = @init_data[:general][:send_notification]
      @kill_process = @init_data[:general][:kill_process]
      @delete_executable = @init_data[:general][:delete_executable]
      @display_message = @init_data[:general][:display_message]
      @site = JSS::APIObject.get_name(@init_data[:general][:site])
      @site ||= 'None'
      @scope ||= JSS::Scopable::Scope.new SCOPE_TARGET_KEY, nil
    end # init

    def process_name=(new_val)
      @process_name = new_val.to_s
      @need_to_update = true
    end

    def match_exact_process_name=(new_val)
      confirm_boolean(new_val)
      @match_exact_process_name = new_val
      @need_to_update = true
    end

    def send_notification=(new_val)
      confirm_boolean(new_val)
      @send_notification = new_val
      @need_to_update = true
    end

    def kill_process=(new_val)
      confirm_boolean(new_val)
      @kill_process = new_val
      @need_to_update = true
    end

    def delete_executable=(new_val)
      confirm_boolean(new_val)
      @delete_executable = new_val
      @need_to_update = true
    end

    def display_message=(new_val)
      @display_message = new_val.to_s
      @need_to_update = true
    end

    def site=(new_val)
      if new_val.is_a? Integer
        raise JSS::NoSuchItemError, "No site found with id #{new_val}" unless JSS::Site.all_ids(api: @api).include? new_val
        new_val = JSS::Site.map_all_ids_to(:name, api: @api)[new_val]
      else
        new_val = new_val.to_s
        raise JSS::NoSuchItemError, "No site found with name #{new_val}" unless JSS::Site.all_names(api: @api).include? new_val
      end
      @site = new_val
      @need_to_update = true
    end

    def create
      raise JSS::MissingDataError, 'process_name must be set before creating' if @process_name.to_s.empty?
      raise JSS::AlreadyExistsError, "A #{RSRC_OBJECT_KEY} named #{@name} already exists in the JSS" if self.class.all_names(:refresh, api: @api).include? @name
      super
    end

    def update
      raise JSS::MissingDataError, 'process_name must be set before updating' if @process_name.to_s.empty?
      super
    end

    ##### Aliases

    alias match_exact_process_name? match_exact_process_name
    alias send_notification? send_notification
    alias kill_process? kill_process
    alias delete_executable? delete_executable

    ##### Private Instance Methods
    private

    def rest_xml
      doc = REXML::Document.new APIConnection::XML_HEADER
      obj = doc.add_element RSRC_OBJECT_KEY.to_s

      general = obj.add_element 'general'
      general.add_element('name').text = @name
      general.add_element('process_name').text = @process_name
      general.add_element('match_exact_process_name').text = @match_exact_process_name.to_s
      general.add_element('send_notification').text = @send_notification.to_s
      general.add_element('kill_process').text = @kill_process.to_s
      general.add_element('delete_executable').text = @delete_executable.to_s
      general.add_element('display_message').text = @display_message.to_s

      site = general.add_element 'site'
      site.add_element('name').text = @site

      obj << @scope.scope_xml
      add_self_service_xml doc
      doc.to_s
    end # rest_xml

    # TODO: Move this into a Validators module
    def confirm_boolean(val)
      raise JSS::InvalidDataError, 'Value must be boolean true or false' unless JSS::TRUE_FALSE.include? val
    end

  end # class

end # module JSS
