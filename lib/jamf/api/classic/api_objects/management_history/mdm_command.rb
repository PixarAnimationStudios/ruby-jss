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

#
module Jamf

  #
  module ManagementHistory

    # MdmCommand - an issued MDM command in a Jamf Object's Management History
    #
    # This should only be instantiated by the ManagementHistory.mdm_commands method
    # when mixed in to Computers or Mobile devices.
    #
    # That method will return an array of these objects.
    #
    # NOTE: some attributes will be nil for some statuses
    # (e.g. no error message if not failed, no completed time if not completed)
    #
    class MdmCommand < ImmutableStruct.new(

      :name,
      :username,
      :status,
      :error,
      :issued_epoch,
      :failed_epoch,
      :completed_epoch,
      :last_push_epoch
    )
      include Jamf::ManagementHistory::HashLike

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

    end # MdmCommand

  end #   module ManagementHistory

end # module Jamf
