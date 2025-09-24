# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###

module Jamf

  module ManagementHistory

    # This is mixed in to the history event classes to
    # provide hash-like access to their attributes, so that
    #    some_event[:date_time]
    # works the same as
    #     some_event.date_time
    # just as with OpenStruct objects
    #
    module HashLike

      def [](attr)
        send attr.to_sym
      end

    end # HashLike

  end # module ManagementHistory

end # module Jamf
