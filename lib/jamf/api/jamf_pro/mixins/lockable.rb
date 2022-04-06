# Copyright 2020 Pixar
#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

module Jamf

  # TODO may not be needed anymore

  # Classes mixing this in have a 'versionLock' attribute and implement
  # 'Optimistic Locking'
  #  https://stackoverflow.com/questions/129329/optimistic-vs-pessimistic-locking/129397#129397
  #
  # When the object is saved, the versionLock is sent back with the data
  # and if it doesn't match whats on the server, then the object has been updated
  # from elsewhere since we fetched it, and a 409 Conflict error is raised with
  # the reason OPTIMISTIC_LOCK_FAILED.
  #
  # If that happens, the save doesnt happen, the object must be re-fetched,
  # and the user can try again.
  #
  module Lockable

    # when this module is included, also extend our Class Methods
    def self.included(includer)
      includer.extend(ClassMethods)
    end

    #  Class Methods
    #####################################
    module ClassMethods

      def lockable?
        true
      end

    end # module class methods

    attr_reader :versionLock

    def initialize(**data)
      @versionLock = data[:versionLock]
      super(**data)
    end

    def to_jamf
      data = super
      data[:versionLock] = @versionLock
      data
    end

    def lockable?
      self.class.lockable?
    end

  end # Lockable

end # Jamf
