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

    # Ebook - an app deployed to a MobileDevice
    #
    # This should only be instantiated by the ManagementHistory.ebooks method
    # when mixed in to Mobile devices.
    #
    # That method will return an array of these objects.
    #
    # NOTE: some attributes will be nil for some statuses
    # (e.g. no source data if not installed)
    #
    class Ebook < ImmutableStruct.new(

      :title,
      :author,
      :version,
      :kind,
      :management_status,
      :source
    )
      include Jamf::ManagementHistory::HashLike

      # @!attribute [r] title
      #  @return [String] The name of the ebook.

      alias name title

      # @!attribute [r] version
      #  @return [String] The version of the ebook.

      # @!attribute [r] author
      #  @return [String] The author of the ebook.

      # @!attribute [r] kind
      #  @return [String] 'IBOOK', 'PDF', etc..

      # @!attribute [r] management_status
      #  @return [String] The raw status, used for #managed? and #status

      # @!attribute [r] source
      #  @return [Symbol] :in_house or :ibookstore

      # @return [Symbol] :installed, :pending, :failed, or :unknown
      #
      def status
        case @management_status
        when HIST_RAW_STATUS_INSTALLED then :installed
        when HIST_RAW_STATUS_MANAGED then :installed
        when HIST_RAW_STATUS_UNMANAGED then :installed
        when HIST_RAW_STATUS_PENDING then :pending
        when HIST_RAW_STATUS_FAILED then :failed
        else :unknown
        end
      end

      #  @return [Boolean] If :installed and :in_house, is it managed?
      #
      def managed?
        @management_status == HIST_RAW_STATUS_MANAGED
      end

    end # Ebook

  end #   module ManagementHistory

end # module Jamf
