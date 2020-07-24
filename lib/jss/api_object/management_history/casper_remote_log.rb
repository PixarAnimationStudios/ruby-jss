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
