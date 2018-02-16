#
module JSS

  #
  module ManagementHistory

    # MDMCommand - an issued MDM command in a Jamf Object's Management History
    #
    # This should only be instantiated by the ManagementHistory.mdm_commands method
    # when mixed in to Computers or Mobile devices.
    #
    # That method will return an array of these objects.
    #
    # NOTE: some attributes will be nil for some statuses
    # (e.g. no error message if not failed, no completed time if not completed)
    #
    class MDMCommand < ImmutableStruct.new(

      :name,
      :username,
      :status,
      :error,
      :issued_epoch,
      :failed_epoch,
      :completed_epoch,
      :last_push_epoch
    )
      include JSS::ManagementHistory::HashLike

      def initialize(args = {})
        args[:completed_epoch] ||= args[:date_time_completed_epoch]
        args[:issued_epoch] ||= args[:date_time_issued_epoch]
        args[:failed_epoch] ||= args[:date_time_failed_epoch]
        super args
      end

      # @!attribute [r] name
      #   @return [String] the name of the command.

      # @!attribute [r] username
      #   @return [String] the username of associated with the command.

      # @!attribute [r] status
      #   @return [Symbol] :completed, :pending, or :failed

      # @!attribute [r] error
      #   @return [String] The error message if status == :failed

      # @!attribute [r] issued_epoch
      #   @return [Integer] When the command was issued, as
      #    a unix epoch timestamp with milliseconds

      # @!attribute [r] failed_epoch
      #   @return [Integer] When the command failed, as
      #   a unix epoch timestamp with milliseconds

      # @!attribute [r] completed_epoch
      #   @return [Integer] When the command was completed, as
      #   a unix epoch timestamp with milliseconds

      # @!attribute [r] last_push_epoch
      #   @return [Integer] When the most recent attempt was made on a
      #   pending command, a unix epoch timestamp with milliseconds

      # @return [Time] When the command was issued, as a ruby
      #   Time object
      #
      def issued
        JSS.epoch_to_time @issued_epoch if @issued_epoch
      end

      # @return [Time] When the command failed, as a ruby
      #   Time object
      #
      def failed
        JSS.epoch_to_time @failed_epoch if @failed_epoch
      end

      # @return [Time] When the command completed, as a ruby
      #   Time object
      #
      def completed
        JSS.epoch_to_time @completed_epoch if @completed_epoch
      end

      # @return [Time] When the most recent attempt was made on a pending
      #   command, as a ruby Time object
      #
      def last_push
        JSS.epoch_to_time @last_push_epoch if @last_push_epoch
      end

    end # MDMCommand

  end #   module ManagementHistory

end # module JSS
