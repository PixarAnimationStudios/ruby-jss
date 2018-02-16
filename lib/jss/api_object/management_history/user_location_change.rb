#
module JSS

  #
  module ManagementHistory

    # UserLocationChange - a change in a device's assigned user or location
    #
    # This should only be instantiated by the ManagementHistory.user_location_history method
    # when mixed in to Computers or Mobile devices.
    #
    # That method will return an array of these objects.
    #
    class UserLocationChange < ImmutableStruct.new(

      :date_time_epoch,
      :username,
      :full_name,
      :email_address,
      :phone_number,
      :department,
      :building,
      :room,
      :position
    )
      include JSS::ManagementHistory::HashLike

      # @!attribute [r] date_time_epoch
      #   @return [Integer] When the change occurred

      # @!attribute [r] username
      #   @return [String] The username for this change

      # @!attribute [r] full_name
      #   @return [String] The user's full name for this change

      # @!attribute [r] email_address
      #   @return [String] The email_address for this change

      alias email email_address

      # @!attribute [r] phone_number
      #   @return [String] The phone_number for this change

      # @!attribute [r] department
      #   @return [String] The department for this change

      alias dept department

      # @!attribute [r] building
      #   @return [String] The building for this change

      # @!attribute [r] room
      #   @return [String] The room for this change

      # @!attribute [r] position
      #   @return [String] The position for this change

      # @return [Time] When the change occurred, as a ruby Time object
      #
      def date_time
        JSS.epoch_to_time @date_time_epoch if @date_time_epoch
      end

    end # UserLocationChange

  end # module ManagementHistory

end # module JSS
