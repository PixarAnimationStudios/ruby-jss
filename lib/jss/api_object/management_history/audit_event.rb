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
module JSS

  #
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
      include JSS::ManagementHistory::HashLike

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

end # module JSS
