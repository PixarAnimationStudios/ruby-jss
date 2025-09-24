# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

module JamfTest

  class MobileDevicePrestage < JamfTest::APITest

    include JamfTest::PrestageTests

    COLLECTION_CLASS = Jamf::MobileDevicePrestage

  end # class

end # module JamfTest
