#
module JSS

  #
  module ManagementHistory

    # PolicyLog - A Computer policy log history entry
    #
    # This should only be instantiated by the ManagementHistory.policy_logs method
    # when mixed in to Computers.
    #
    # That method will return an array of these objects.
    #
    class PolicyLog < ImmutableStruct.new(

      :policy_id,
      :policy_name,
      :username,
      :date_completed_epoch,
      :status
    )

      def initialize(args = {})
        # we want the status as a Symbol
        args[:status] &&= args[:status].downcase.to_sym
        super
      end

      # @!attribute [r] policy_id
      #   @return [Integer]  the jss id of the poolicy

      alias id policy_id

      # @!attribute [r] policy_name
      #   @return [String] the name of the policy.

      alias name policy_name

      # @!attribute [r] username
      #   @return [String] The username active for the policy

      # @!attribute [r] date_completed_epoch
      #   @return [Integer] When the policy completed, as
      #   a unix epoch timestamp with milliseconds

      # @!attribute [r] status
      #   @return [Symbol] :completed or :failed

      # @return [Time] When the policy completed, as a ruby
      #   Time object
      def date_completed
        JSS.epoch_to_time(@date_completed_epoch) if @date_completed_epoch
      end
      alias completed date_completed

    end # PolicyLog

  end # module ManagementHistory

end # module JSS
