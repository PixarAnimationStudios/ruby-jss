#
module JSS

  #
  module ManagementHistory

    # EBook - an app deployed to a MobileDevice
    #
    # This should only be instantiated by the ManagementHistory.ebooks method
    # when mixed in to Mobile devices.
    #
    # That method will return an array of these objects.
    #
    # NOTE: some attributes will be nil for some statuses
    # (e.g. no source data if not installed)
    #
    class EBook < ImmutableStruct.new(

      :title,
      :author,
      :version,
      :kind,
      :management_status,
      :source
    )

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

    end # EBook

  end #   module ManagementHistory

end # module JSS
