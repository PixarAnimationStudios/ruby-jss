### Copyright 2022 Pixar

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
      include Jamf::ManagementHistory::HashLike

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

end # module Jamf
