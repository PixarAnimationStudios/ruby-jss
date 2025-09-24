# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # TODO: may not be needed anymore

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
      Jamf.load_msg "--> #{includer} is including Jamf::Lockable"
      includer.extend(ClassMethods)
    end

    #  Class Methods
    #####################################
    module ClassMethods

      def self.extended(extender)
        Jamf.load_msg "--> #{extender} is extending Jamf::Lockable"
      end

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
