### Copyright 2025 Pixar

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
      include Jamf::ManagementHistory::HashLike

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

end # module Jamf
