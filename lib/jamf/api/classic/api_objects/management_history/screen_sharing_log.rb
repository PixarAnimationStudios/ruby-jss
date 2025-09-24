# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###

module Jamf

  module ManagementHistory

    # ScreenSharingLog - an casper screen sharing event in a Jamf Compter's Management History
    #
    # This should only be instantiated by the ManagementHistory.screen_sharing_logs method
    # when mixed in to Computers devices.
    #
    # That method will return an array of these objects.
    #
    class ScreenSharingLog < ImmutableStruct.new(
      :status,
      :date_time_epoch,
      :details
    )
      include Jamf::ManagementHistory::HashLike

      # @!attribute [r] status
      #  @return [String] The status of the event.

      # @!attribute [r] details
      #  @return [String] The details of the event.

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

end # module Jamf
