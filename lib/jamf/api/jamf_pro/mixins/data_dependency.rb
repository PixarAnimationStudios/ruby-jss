# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # This mixin implements the .../data-dependency endpoints that
  # some collection resources have (and eventually all will??)
  # It should be included into classes representing those resources
  #
  # data-dependencies list other Jamf Pro objects that use the current object,
  # e.g. Advanced Searches or Smart Groups that use an Extension Attribute in their
  # criteria.
  #
  module DataDependency

    DATA_DEPENDENCY_ENDPOINT = 'data-dependency'.freeze

    # when this module is included, also extend our Class Methods
    def self.included(includer)
      Jamf.load_msg "--> #{includer} is including Jamf::DataDependency"
      includer.extend(ClassMethods)
    end

    # Get the dependencies for the current object. This is a list of objects that use this object
    # and would prevent if from being deleted
    #
    # @return [Array<Hash>] Info about any objects that would prevent deletion of the specified object(s).
    #
    def data_dependency
      self.class.data_dependency(id, cnx: @cnx)
    end

    # Class Methods
    #####################################
    module ClassMethods

      def self.extended(extender)
        Jamf.load_msg "--> #{extender} is extending Jamf::DataDependency::ClassMethods"
      end

      # Get the dependencies for the specified id. This is a list of objects that use this object
      # and would prevent if from being deleted
      #
      # @param ident [String,Integer] The name, id or other identifier to get dependencies for.
      #
      # @param cnx [Jamf::Connection] The connection to use, default: Jamf.cnx
      #
      # @return [Array<Hash>] Info about any objects that would prevent deletion of the specified object(s).
      #
      def data_dependency(ident, cnx: Jamf.cnx)
        id = valid_id(ident)
        cnx.jp_get("#{self::LIST_PATH}/#{id}/#{DATA_DEPENDENCY_ENDPOINT}")[:results]
      end

    end # ClassMethods

  end # DataDependency

end # Jamf
