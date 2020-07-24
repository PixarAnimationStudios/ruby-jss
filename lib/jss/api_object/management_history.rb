### Copyright 2020 Pixar

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

  # Mixin Modules
  #####################################

  # Objects mixing in this module have 'management history' in the JSS, which at
  # this point is Computers and MobileDevices
  #
  # *Important:* this is 'management history', i.e. the history and logs
  # of mdm commands, locations, apps, policies, and other events that are part
  # of management and inventory collection.
  #
  # When viewing the details page for a computer or mobile device in the
  # Web UI, this is the data visible in the 'History' pane of the page.
  #
  # It is not the same as 'object history' which are the changes made to a
  # JSS object in the database, e.g. edits & notes by admins or automated
  # processes in the JSS web UI or via the API. Object history is visble in
  # the Web UI by clicking the 'History' button at the bottom of a machine's
  # details page.
  #
  # == Class & Instance Methods
  #
  # This module provides both class methods, which can be used to retrieve history
  # data without instantiating a full Computer or MobileDevice, and
  # instance methods that are wrappers around the class methods. The methods
  # have the same names, but of course the class methods require arguments
  # specifying the target for which to retrieve data, and which API connection
  # to use (defaulting to the currently active connection).
  #
  # == Raw data versus processed data & event object classes
  #
  # The primary data-retrieval method for management history data is
  # {JSS::ManagementHistory.management_history}. This method returns the raw
  # JSON data from the API, parsed into a Ruby Hash. If you don't specify a
  # subset, the data returned can be very large.
  #
  # This data is somewhat inconsistent in its structure and content across the
  # different subsets of history events, but you're welcome to use it if needed.
  #
  # To provide a more consistent and ruby-like interface to the history events,
  # the remaining methods, which only return subsets of the full dataset, will
  # return Arrays of instances of the classes defined in this module.
  #
  # For example, the {JSS::MobileDevice.audit_history} method returns an Array
  # of JSS::ManagementHistory::AuditEvent instances,  and the
  # {JSS::Computer.completed_policies} gives an Array of
  # JSS::ManagementHistory::PolicyLog objects.
  #
  # These objects are read-only and provide access to their values via both
  # attribute-style methods, and hash-like keys, similar to how OpenStruct
  # objects do.
  # This means that
  #    `some_log_event.date_time`
  # and
  #    `some_log_event[:date_time]`
  # are identical.
  # This *may* help with some backward-compatibility issues.
  #
  #
  # NOTE: History queries from the API are *not* cached in ruby-jss, like the
  # APIObject.all data is - instead it is queried anew every time. For this reason,
  # you are encouraged to store the results of these methods in variables for
  # later use if needed.
  #
  module ManagementHistory

    # Constants
    #####################################

    HIST_RAW_STATUS_COMPLETED = 'Completed'.freeze
    HIST_RAW_STATUS_INSTALLED = 'Installed'.freeze
    HIST_RAW_STATUS_MANAGED = 'Managed'.freeze
    HIST_RAW_STATUS_UNMANAGED = 'Unmanaged'.freeze
    HIST_RAW_STATUS_FAILED = 'Failed'.freeze
    HIST_RAW_STATUS_PENDING = 'Pending'.freeze

    HIST_STATUS_COMPLETED = :completed
    HIST_STATUS_PENDING = :pending
    HIST_STATUS_FAILED = :failed
    HIST_STATUS_INSTALLED = :installed

    HIST_RAW_SOURCE_APP_IN_HOUSE = :in_house_from_mobile_device_app_catalog
    HIST_RAW_SOURCE_APP_STORE = :app_store_from_mobile_device_app_catalog
    HIST_RAW_SOURCE_EBOOK_IN_HOUSE = :inhouse
    HIST_RAW_SOURCE_IBOOKSTORE = :ibookstore
    HIST_RAW_SOURCE_OTHER = :other

    HIST_SOURCE_IN_HOUSE = :in_house
    HIST_SOURCE_APP_STORE = :app_store
    HIST_SOURCE_IBOOKSTORE = :ibookstore
    HIST_SOURCE_OTHER = :other

    HIST_MDM_STATUSES = [HIST_STATUS_COMPLETED, HIST_STATUS_PENDING, HIST_STATUS_FAILED].freeze
    HIST_APP_STATUSES = [HIST_STATUS_INSTALLED, HIST_STATUS_PENDING, HIST_STATUS_FAILED].freeze

    # The api resource for each history type
    HIST_COMPUTER_RSRC = 'computerhistory'.freeze
    HIST_DEVICE_RSRC = 'mobiledevicehistory'.freeze

    # The top-level hash key for the history data of each type
    HIST_COMPUTER_KEY = :computer_history
    HIST_DEVICE_KEY = :mobile_device_history

    # The keys are both the subset names in the resrouce URLS (when
    # converted to strings) and the second-level hash key of the
    # returned subset data.
    #
    HIST_COMPUTER_SUBSETS = %i[
      computer_usage_logs
      audits
      policy_logs
      casper_remote_logs
      screen_sharing_logs
      casper_imaging_logs
      commands
      user_location
      mac_app_store_applications
    ].freeze

    # The keys are both the subset names in the resrouce URLS (when
    # converted to strings) and the second-level hash key of the
    # returned subset data.
    #
    HIST_DEVICE_SUBSETS = %i[
      management_commands
      user_location
      audits
      applications
      ebooks
    ].freeze

    # Mixin Class Methods
    ###########################

    # See
    # https://codereview.stackexchange.com/questions/23637/mixin-both-instance-and-class-methods-in-ruby
    # for discussion of this technique for mixing in both
    # Class and Instance methods when including a module.
    #
    module ClassMethods

      # Return the raw management history for a Computer or Mobile Device
      #
      # WARNING: It's huge, better to use a subset.
      #
      # NOTE: This returns the raw JSON data from the API, parsed into
      # a ruby Hash. Use the subset-specific methods to retrieve more consistent
      # arrays of ruby-jss objects for each kind of history event, e.g.
      # JSS::Computer.audits(id) or JSS::MobileDevice.audits(id) to get an array
      # of JSS::ManagementHistory::AuditEvent objects
      #
      # @param ident [Integer,String] An identifier (id, name, serialnumber,
      #   macadress or udid) of the computer or device for which to retrieve history
      #
      # @param subset[Symbol] the subset to return, rather than full history.
      #
      # @param api[JSS::APIConnection] an API connection to use for the query.
      #   Defaults to the corrently active API. See {JSS::APIConnection}
      #
      # @return [Hash,Array] The raw full history or subset requested
      #
      def management_history(ident, subset = nil, api: JSS.api)
        id = valid_id ident, api: api
        raise JSS::NoSuchItemError, "No #{self::RSRC_OBJECT_KEY} matches identifier: #{ident}" unless id

        if self == JSS::Computer
          @hist_subsets ||= HIST_COMPUTER_SUBSETS
          @hist_rsrc ||= HIST_COMPUTER_RSRC
          @hist_key ||= HIST_COMPUTER_KEY
        else
          @hist_subsets ||= HIST_DEVICE_SUBSETS
          @hist_rsrc ||= HIST_DEVICE_RSRC
          @hist_key ||= HIST_DEVICE_KEY
        end

        if subset
          raise "Subset must be one of :#{@hist_subsets.join ', :'}" unless @hist_subsets.include? subset
          subset_rsrc = @hist_rsrc + "/id/#{id}/subset/#{subset}"
          api.get_rsrc(subset_rsrc)[@hist_key][subset]
        else
          api.get_rsrc(@hist_rsrc + "/id/#{id}")[@hist_key]
        end
      end
      alias history management_history

      # The history of Audit events for a target
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::AuditEvent>] An array of audit events
      #
      def audit_history(ident, api: JSS.api)
        hist = management_history(ident, :audits, api: api)
        hist.map! { |aud| JSS::ManagementHistory::AuditEvent.new aud }
      end
      alias audits audit_history

      # The history of User/Location changes for a target
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::UserLocationChange>] An array of UserLocation change events
      #
      def user_location_history(ident, api: JSS.api)
        hist = management_history(ident, :user_location, api: api)
        hist.map! { |evt| JSS::ManagementHistory::UserLocationChange.new evt }
      end

      # The history of mdm commands for a target
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param status [Symbol] Return only the :completed, :pending, or :failed commands
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::MDMCommand>] An array of MDMCommands
      #
      def mdm_command_history(ident, status = nil, api: JSS.api)
        subset = self == JSS::Computer ? :commands : :management_commands
        hist = management_history(ident, subset, api: api)
        if status
          raise JSS::InvalidDataError, 'status must be one of :completed, :pending, or :failed' unless HIST_MDM_STATUSES.include? status
          statuses_to_do = [status]
        else
          statuses_to_do = HIST_MDM_STATUSES
        end # if status

        result = []

        statuses_to_do.each do |a_status|
          result += hist[a_status].map! do |cmd|
            # failed computer cmds have the error message in cmd[:status]
            # failed mdm commands have them in cmd[:error], where they should be
            cmd[:error] ||= cmd[:status] if a_status == :failed

            # but we always set the :status
            cmd[:status] = a_status

            JSS::ManagementHistory::MDMCommand.new cmd
          end # map do |cmd|
        end # statuses_to_do.each do |a_status|
        result
      end # mdm_command_history
      alias commands mdm_command_history
      alias management_command_history mdm_command_history

      # The history of completed mdm commands for a target
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::MDMCommand>] An array of completed MDMCommands
      #
      def completed_mdm_commands(ident, api: JSS.api)
        mdm_command_history(ident, :completed, api: api)
      end # completed_mdm_commands
      alias completed_commands completed_mdm_commands

      # The history of pending mdm commands for a target
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::MDMCommand>] An array of pending MDMCommands
      #
      def pending_mdm_commands(ident, api: JSS.api)
        mdm_command_history(ident, :pending, api: api)
      end # completed_mdm_commands
      alias pending_commands pending_mdm_commands

      # The history of failed mdm commands for a target
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::MDMCommand>] An array of failed MDMCommands
      #
      def failed_mdm_commands(ident, api: JSS.api)
        mdm_command_history(ident, :failed, api: api)
      end # completed_mdm_commands
      alias failed_commands failed_mdm_commands

      # The time of the most recently completed or failed MDM command.
      # (knowledge of a failure means the device communicated with us)
      #
      # For Mobile Devices, this seems to be the best indicator of the real
      # last-contact time, since the last_inventory_update is changed when
      # changes are made via the API.
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Time, nil] An array of completed MDMCommands
      #
      def last_mdm_contact(ident, api: JSS.api)
        epochs = completed_mdm_commands(ident, api: api).map { |cmd| cmd.completed_epoch }
        epochs += failed_mdm_commands(ident, api: api).map { |cmd| cmd.failed_epoch }
        epoch = epochs.max
        epoch ? JSS.epoch_to_time(epoch) : nil
      end


      # The history of app store apps  for a computer
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param status [Symbol] Return only the :installed, :pending, or :failed apps
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::MacAppStoreApp>] An array of MacAppStoreApp
      #
      def mac_app_store_app_history(ident, status = nil, api: JSS.api)
        raise JSS::UnsupportedError, 'Only computers have mac app store apps' unless self == JSS::Computer

        hist = management_history(ident, :mac_app_store_applications, api: api)
        if status
          raise JSS::InvalidDataError, 'status must be one of :installed, :pending, or :failed' unless HIST_APP_STATUSES.include? status
          statuses_to_do = [status]
        else
          statuses_to_do = HIST_APP_STATUSES
        end # if status

        result = []

        statuses_to_do.each do |a_status|
          result += hist[a_status].map! do |app|
            # set the :status
            app[:status] = a_status
            JSS::ManagementHistory::MacAppStoreApp.new app
          end # map do |cmd|
        end # statuses_to_do.each do |a_status|

        result
      end # mac_app_store_app_history

      # The history of apps for a mobile device
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param status [Symbol] Return only the :installed, :pending, or :failed apps
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::MobileDeviceApp>] An array of MobileDeviceApp
      #
      def mobile_device_app_history(ident, status = nil, api: JSS.api)
        raise JSS::UnsupportedError, 'Only mobile devices have mobile device apps' unless self == JSS::MobileDevice

        hist = management_history(ident, :applications, api: api)
        if status
          raise JSS::InvalidDataError, 'status must be one of :installed, :pending, or :failed' unless HIST_APP_STATUSES.include? status
          statuses_to_do = [status]
        else
          statuses_to_do = HIST_APP_STATUSES
        end # if status

        result = []

        statuses_to_do.each do |a_status|
          # merge the sources of installed apps into their hashes
          apps =
            if a_status == :installed
              instapps = []
              hist[a_status].each do |src, apps_from_src|
                real_src =
                  case src
                  when HIST_RAW_SOURCE_APP_IN_HOUSE then HIST_SOURCE_IN_HOUSE
                  when HIST_RAW_SOURCE_APP_STORE then HIST_SOURCE_APP_STORE
                  else HIST_SOURCE_OTHER
                  end # case src
                instapps += apps_from_src.map! { |iapp| iapp[:source] = real_src }
              end
              instapps
            else
              hist[a_status]
            end
          # now 'apps' is an array of hashes of apps with the same status
          # and if they are :installed, their source is in the hash

          # merge the statuses of the apps into their hashes
          result += apps.map! do |app|
            # set the :status in the hash
            app[:status] = a_status
            JSS::ManagementHistory::MobileDeviceApp.new app
          end # map do |cmd|
        end # statuses_to_do.each do |a_status|

        result
      end # mobile_device_app_history

      # Wrapper for app store history for both computers and mobile devices
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param status [Symbol] Return only the :installed, :pending, or :failed apps
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array] An array of MacAppStoreApp or MobileDeviceApp
      #
      def app_store_app_history(ident, status = nil, api: JSS.api)
        if self == JSS::MobileDevice
          mobile_device_app_history(ident, status, api: api)
        else
          mac_app_store_app_history(ident, status, api: api)
        end
      end
      alias managed_app_history app_store_app_history

      # shortcut for app_store_app_history where status = :installed
      #
      # @see #app_store_app_history
      #
      def installed_app_store_apps(ident, api: JSS.api)
        app_store_app_history(ident, :installed, api: api)
      end
      alias installed_managed_apps installed_app_store_apps

      # shortcut for app_store_app_history where status = :pending
      #
      # @see #app_store_app_history
      #
      def pending_app_store_apps(ident, api: JSS.api)
        app_store_app_history(ident, :pending, api: api)
      end
      alias pending_managed_apps pending_app_store_apps

      # shortcut for app_store_app_history where status = :failed
      #
      # @see #app_store_app_history
      #
      def failed_app_store_apps(ident, api: JSS.api)
        app_store_app_history(ident, :failed, api: api)
      end
      alias failed_managed_apps failed_app_store_apps

      # The history of Casper Imaging events for a computer
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::CasperImagingLog>] An array of CasperImagingLog events
      #
      def casper_imaging_logs(ident, api: JSS.api)
        raise JSS::UnsupportedError, 'Only computers have casper imaging logs' unless self == JSS::Computer
        hist = management_history(ident, :casper_imaging_logs, api: api)
        hist.map! { |evt| JSS::ManagementHistory::CasperImagingLog.new evt }
      end

      # The history of Casper Remote events for a computer
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::CasperRemoteLog>] An array of CasperRemoteLog events
      #
      def casper_remote_logs(ident, api: JSS.api)
        raise JSS::UnsupportedError, 'Only computers have casper remote logs' unless self == JSS::Computer
        hist = management_history(ident, :casper_remote_logs, api: api)
        hist.map! { |evt| JSS::ManagementHistory::CasperRemoteLog.new evt }
      end

      # The history of usage events for a computer
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::ComputerUsageLog>] An array of ComputerUsageLog events
      #
      def computer_usage_logs(ident, api: JSS.api)
        raise JSS::UnsupportedError, 'Only computers have usage logs' unless self == JSS::Computer
        hist = management_history(ident, :computer_usage_logs, api: api)
        hist.map! { |evt| JSS::ManagementHistory::ComputerUsageLog.new evt }
      end
      alias usage_logs computer_usage_logs

      # The history of screen sharing events for a computer
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::ScreenSharingLog>] An array of ScreenSharingLog events
      #
      def screen_sharing_logs(ident, api: JSS.api)
        raise JSS::UnsupportedError, 'Only computers have screen sharing logs' unless self == JSS::Computer
        hist = management_history(ident, :screen_sharing_logs, api: api)
        hist.map! { |evt| JSS::ManagementHistory::ScreenSharingLog.new evt }
      end

      # The history of policy execution for a computer
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::PolicyLog>] An array of PolicyLog events
      #
      def policy_logs(ident, api: JSS.api)
        raise JSS::UnsupportedError, 'Only computers have policy logs' unless self == JSS::Computer
        hist = management_history(ident, :policy_logs, api: api)
        hist.map! { |evt| JSS::ManagementHistory::PolicyLog.new evt }
      end

      # The array from .policy_logs, limited to status = :completed
      # @see ManagementHistory::ClassMethods.policy_logs
      #
      def completed_policies(ident, api: JSS.api)
        policy_logs(ident, api: api).select { |pl| pl.status == :completed }
      end

      # The array from .policy_logs, limited to status = :failed
      # @see ManagementHistory::ClassMethods.policy_logs
      #
      def failed_policies(ident, api: JSS.api)
        policy_logs(ident, api: api).select { |pl| pl.status == :failed }
      end

      # The history of ebooks for a mobile device
      #
      # @param ident [Type] The identifier for the object - id, name, sn, udid, etc.
      #
      # @param status [Symbol] Return only the :installed, :pending, or :failed apps
      #
      # @param api [JSS::APIConnection] The API connection to use for the query
      #   defaults to the currently active connection
      #
      # @return [Array<JSS::ManagementHistory::EBook>] An array of EBook
      #
      def ebook_history(ident, status = nil, api: JSS.api)
        raise JSS::UnsupportedError, 'Only mobile devices have ebooks' unless self == JSS::MobileDevice

        hist = management_history(ident, :ebooks, api: api)
        if status
          raise JSS::InvalidDataError, 'status must be one of :installed, :pending, or :failed' unless HIST_APP_STATUSES.include? status
          statuses_to_do = [status]
        else
          statuses_to_do = HIST_APP_STATUSES
        end # if status

        result = []

        statuses_to_do.each do |a_status|
          # merge the sources of installed apps into their hashes
          books =
            if a_status == :installed
              instbooks = []
              hist[a_status].each do |src, books_from_src|
                real_src =
                  case src
                  when HIST_RAW_SOURCE_EBOOK_IN_HOUSE then HIST_SOURCE_IN_HOUSE
                  when HIST_RAW_SOURCE_IBOOKSTORE then HIST_SOURCE_IBOOKSTORE
                  else HIST_SOURCE_OTHER
                  end # case src
                instbooks += books_from_src.map! { |book| book[:source] = real_src }
              end
              instbooks
            else
              hist[a_status]
            end
          # now 'books' is an array of hashes of books with the same status
          # and if they are :installed, their source is in the hash

          # merge the statuses of the books into their hashes
          result += books.map! do |book|
            # set the :status in the hash
            book[:status] = a_status
            JSS::ManagementHistory::EBook.new book
          end # map do |books|
        end # statuses_to_do.each do |a_status|

        result
      end # mobile_device_app_history
      alias managed_ebook_history ebook_history

      # shortcut for ebook_history where status = :installed
      #
      # @see #ebook_history
      #
      def installed_ebooks(ident, api: JSS.api)
        ebook_history(ident, :installed, api: api)
      end
      alias installed_managed_ebooks installed_ebooks

      # shortcut for ebook_history where status = :pending
      #
      # @see #ebook_history
      #
      def pending_ebooks(ident, api: JSS.api)
        ebook_history(ident, :pending, api: api)
      end
      alias pending_managed_ebooks pending_ebooks

      # shortcut for ebook_history where status = :failed
      #
      # @see #ebook_history
      #
      def failed_ebooks(ident, api: JSS.api)
        ebook_history(ident, :failed, api: api)
      end
      alias failed_managed_ebooks failed_ebooks

    end # module ClassMethods

    # Extend ourself when included
    # @see {JSS::ManagementHistory::ClassMethods}
    #
    # See https://codereview.stackexchange.com/questions/23637/mixin-both-instance-and-class-methods-in-ruby
    # for discussion of this technique for mixing in both
    # Class and Instance methods when including a module.
    def self.included(klass)
      klass.extend JSS::ManagementHistory::ClassMethods
    end

    # Mixin Instance Methods
    ###########################
    # See https://codereview.stackexchange.com/questions/23637/mixin-both-instance-and-class-methods-in-ruby
    # for discussion of this technique for mixing in both
    # Class and Instance methods when including a module.

    # The raw management history data for this object
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def management_history(subset = nil)
      self.class.management_history(@id, subset, api: @api)
    end
    alias history management_history

    # The audit_history for this object
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def audit_history
      self.class.audit_history(@id, api: @api)
    end
    alias audits audit_history

    # The user_location_history for this object
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def user_location_history
      self.class.user_location_history(@id, api: @api)
    end

    # The mdm_command_history for this object
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def mdm_command_history(status = nil)
      self.class.mdm_command_history(@id, status, api: @api)
    end
    alias commands mdm_command_history
    alias management_command_history mdm_command_history

    # The completed_mdm_commands for this object
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def completed_mdm_commands
      self.class.completed_mdm_commands(@id, api: @api)
    end # completed_mdm_commands
    alias completed_commands completed_mdm_commands

    # The time of the last completed mdm command for this object
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def last_mdm_contact
      self.class.last_mdm_contact(@id, api: @api)
    end # completed_mdm_commands

    # The pending_mdm_commands for this object
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def pending_mdm_commands
      self.class.pending_mdm_commands(@id, api: @api)
    end # completed_mdm_commands
    alias pending_commands pending_mdm_commands

    # The failed_mdm_commands for this object
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def failed_mdm_commands
      self.class.failed_mdm_commands(@id, api: @api)
    end # completed_mdm_commands
    alias failed_commands failed_mdm_commands

    # The mac_app_store_app_history for this computer
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def mac_app_store_app_history(status = nil)
      self.class.mac_app_store_app_history(@id, status, api: @api)
    end

    # The mobile_device_app_history for this mobile device
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def mobile_device_app_history(status = nil)
      self.class.mobile_device_app_history(@id, status, api: @api)
    end

    # Wrapper for app store history for both computers and mobile devices
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def app_store_app_history(status = nil)
      self.class.app_store_app_history(@id, status, api: @api)
    end
    alias managed_app_history app_store_app_history

    # shortcut for app_store_app_history where status = :installed
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def installed_app_store_apps
      self.class.installed_app_store_apps(@id, api: @api)
    end
    alias installed_managed_apps installed_app_store_apps

    # shortcut for app_store_app_history where status = :pending
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def pending_app_store_apps
      self.class.pending_app_store_apps(@id, api: @api)
    end
    alias pending_managed_apps pending_app_store_apps

    # shortcut for app_store_app_history where status = :failed
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def failed_app_store_apps
      self.class.failed_app_store_apps(@id, api: @api)
    end
    alias failed_managed_apps failed_app_store_apps

    # The casper_imaging_logs for this computer
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def casper_imaging_logs
      self.class.casper_imaging_logs(@id, api: @api)
    end

    # The casper_remote_logs for this computer
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def casper_remote_logs
      self.class.casper_remote_logs(@id, api: @api)
    end

    # The computer_usage_logs for this computer
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def computer_usage_logs
      self.class.computer_usage_logs(@id, api: @api)
    end
    alias usage_logs computer_usage_logs

    # The screen_sharing_logs for this computer
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def screen_sharing_logs
      self.class.screen_sharing_logs(@id, api: @api)
    end

    # The policy_logs for this computer
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def policy_logs
      self.class.policy_logs(@id, api: @api)
    end

    # The array from .policy_logs, limited to status = :completed
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def completed_policies
      self.class.completed_policies(@id, api: @api)
    end

    # The array from .policy_logs, limited to status = :failed
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def failed_policies
      self.class.failed_policies(@id, api: @api)
    end

    # The ebook_history for this mobile device
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def ebook_history(status = nil)
      self.class.ebook_history(@id, status, api: @api)
    end
    alias managed_ebook_history ebook_history

    # shortcut for ebook_history where status = :installed
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def installed_ebooks
      self.class.installed_ebooks(@id, api: @api)
    end
    alias installed_managed_ebooks installed_ebooks

    # shortcut for ebook_history where status = :pending
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def pending_ebooks
      self.class.pending_ebooks(@id, api: @api)
    end
    alias pending_managed_ebooks pending_ebooks

    # shortcut for ebook_history where status = :failed
    #
    # @see the matching method in  {JSS::ManagementHistory::ClassMethods}
    #
    def failed_ebooks
      self.class.failed_ebooks(@id, api: @api)
    end
    alias failed_managed_ebooks failed_ebooks

  end # module ManagementHistory

end # module JSS

require 'jss/api_object/management_history/hashlike'
require 'jss/api_object/management_history/audit_event'
require 'jss/api_object/management_history/casper_imaging_log'
require 'jss/api_object/management_history/casper_remote_log'
require 'jss/api_object/management_history/computer_usage_log'
require 'jss/api_object/management_history/ebook'
require 'jss/api_object/management_history/mac_app_store_app'
require 'jss/api_object/management_history/mdm_command'
require 'jss/api_object/management_history/mobile_device_app'
require 'jss/api_object/management_history/policy_log'
require 'jss/api_object/management_history/screen_sharing_log'
require 'jss/api_object/management_history/user_location_change'
