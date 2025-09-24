# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module JamfTest

  class AdvancedComputerSearch < JamfTest::APITest

    include JamfTest::AdvancedSearchTests

    COLLECTION_CLASS = Jamf::AdvancedComputerSearch

  end # class

end # module JamfTest
