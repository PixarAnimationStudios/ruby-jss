#
module JSS

  #
  module ManagementHistory

    # MacAppStoreApp - an app store app deployed to a Computer
    #
    # This should only be instantiated by the ManagementHistory.app_store_app_history method
    # when mixed in to Computers.
    #
    # That method will return an array of these objects.
    #
    # NOTE: some attributes will be nil for some statuses
    # (e.g. no size data if not installed)
    #
    class MacAppStoreApp < ImmutableStruct.new(

      :name,
      :version,
      :status,
      :deployed_epoch,
      :last_update_epoch,
      :size_mb
    )

      # @!attribute [r] name
      #   @return [String] the name of the app.

      # @!attribute [r] version
      #   @return [String] The version of the app

      # @!attribute [r] status
      #   @return [Symbol] :installed, :pending, or :failed

      # @!attribute [r] deployed_epoch
      #   @return [Integer] If :pending, when was it first deployed as
      #   a unix epoch timestamp with milliseconds

      # @!attribute [r] last_update_epoch
      #   @return [Integer] If :pending, when as the last attempt to
      #   install it, as a unix epoch timestamp with milliseconds

      alias last_push_epoch last_update_epoch

      # @!attribute [r] size_mb
      #   @return [Integer] If :installed, its size in Mb

      # @return [Time]  If :pending, when was it first deployed as
      #   as a ruby Time object
      #
      def deployed
        JSS.epoch_to_time @deployed_epoch if @deployed_epoch
      end


      # @return [Time]  If :pending, when as the last attempt to
      #   install it, as a ruby Time object
      #
      def last_update
        JSS.epoch_to_time @last_update_epoch if @last_update_epoch
      end
      alias last_push last_update

    end # MobileDeviceApp

  end # module ManagementHistory

end # module JSS
