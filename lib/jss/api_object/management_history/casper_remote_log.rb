#
module JSS

  #
  module ManagementHistory

    # CasperRemoteEvent - an casper remote event in a Jamf Computer's Management History
    #
    # This should only be instantiated by the ManagementHistory.usage_logs method
    # when mixed in to Computers devices.
    #
    # That method will return an array of these objects.
    #
    class CasperRemoteLog < ImmutableStruct.new(

      :status,
      :date_time_epoch
    )
      include JSS::ManagementHistory::HashLike

      # @!attribute [r] status
      #  @return [String] The status of the event.

      # @!attribute [r] date_time_epoch
      #  @return [Integer] When the event occured on the server, as
      #    a unix epoch timestamp with milliseconds

      #  @return [Time] When the event occured on the server, as a ruby Time object
      #
      def date_time
        JSS.epoch_to_time @date_time_epoch if @date_time_epoch
      end

    end # CasperRemoteEvent

  end #   module ManagementHistory

end # module JSS
