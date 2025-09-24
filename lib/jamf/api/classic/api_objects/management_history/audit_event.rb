# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###

module Jamf

  module ManagementHistory

    # AuditEvent - an auditiable event in a Jamf Object's Management History
    #
    # This should only be instantiated by the ManagementHistory.audits method
    # when mixed in to Computers or Mobile devices.
    #
    # That method will return an array of these objects.
    #
    class AuditEvent < ImmutableStruct.new(
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

      alias admin username

      # @!attribute [r] date_time_epoch
      #  @return [Integer] When the event occured on the server, as
      #    a unix epoch timestamp with milliseconds

      #  @return [Time] When the event occured on the server, as a ruby Time object
      #
      def date_time
        JSS.epoch_to_time @date_time_epoch if @date_time_epoch
      end

    end # AuditEvent

  end #   module ManagementHistory

end # module Jamf
