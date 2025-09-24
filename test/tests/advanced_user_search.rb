# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module JamfTest

  class AdvancedUserSearch < JamfTest::APITest

    include JamfTest::AdvancedSearchTests

    COLLECTION_CLASS = Jamf::AdvancedUserSearch

  end # class

end # module JamfTest
