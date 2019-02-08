### Copyright 2019 Pixar

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

    # MacAppStoreApp - an app store app deployed to a Computer
    #
    # This should only be instantiated by the ManagementHistory.app_store_app_history method
    # when mixed in to Computers.
    #
    # That method will return an array of these objects.
    #
    # NOTE: some attributes will be nil for some statuses
    # (e.g. no size data if not installed)
    #
    class MacAppStoreApp < ImmutableStruct.new(

      :name,
      :version,
      :status,
      :deployed_epoch,
      :last_update_epoch,
      :size_mb
    )
      include JSS::ManagementHistory::HashLike

      # @!attribute [r] name
      #   @return [String] the name of the app.

      # @!attribute [r] version
      #   @return [String] The version of the app

      # @!attribute [r] status
      #   @return [Symbol] :installed, :pending, or :failed

      # @!attribute [r] deployed_epoch
      #   @return [Integer] If :pending, when was it first deployed as
      #   a unix epoch timestamp with milliseconds

      # @!attribute [r] last_update_epoch
      #   @return [Integer] If :pending, when as the last attempt to
      #   install it, as a unix epoch timestamp with milliseconds

      alias last_push_epoch last_update_epoch

      # @!attribute [r] size_mb
      #   @return [Integer] If :installed, its size in Mb

      # @return [Time]  If :pending, when was it first deployed as
      #   as a ruby Time object
      #
      def deployed
        JSS.epoch_to_time @deployed_epoch if @deployed_epoch
      end


      # @return [Time]  If :pending, when as the last attempt to
      #   install it, as a ruby Time object
      #
      def last_update
        JSS.epoch_to_time @last_update_epoch if @last_update_epoch
      end
      alias last_push last_update

    end # MobileDeviceApp

  end # module ManagementHistory

end # module JSS
