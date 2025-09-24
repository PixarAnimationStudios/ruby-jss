# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###

module Jamf

  module ManagementHistory

    # ComputerUsageEvent - an usage event in a Jamf Compter's Management History
    #
    # This should only be instantiated by the ManagementHistory.usage_logs method
    # when mixed in to Computers devices.
    #
    # That method will return an array of these objects.
    #
    class ComputerUsageLog < ImmutableStruct.new(
      :event,
      :username,
      :date_time_epoch
    )
      include Jamf::ManagementHistory::HashLike

      # @!attribute [r] event
      #  @return [String] The description of the event.

      alias description event

      # @!attribute [r] username
      #  @return [String] The name of the JSS user who caused the event

      # @!attribute [r] date_time_epoch
      #  @return [Integer] When the event occured on the server, as
      #    a unix epoch timestamp with milliseconds

      #  @return [Time] When the event occured on the server, as a ruby Time object
      #
      def date_time
        JSS.epoch_to_time @date_time_epoch if @date_time_epoch
      end

    end # ComputerUsageEvent

  end #   module ManagementHistory

end # module Jamf
